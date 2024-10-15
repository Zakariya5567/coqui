import 'dart:convert';
import 'package:coqui/helper/database_helper.dart';
import 'package:dropbox_client/dropbox_client.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:read_pdf_text/read_pdf_text.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../models/dropbox_config.dart';

class DropboxService {
  DatabaseHelper db = DatabaseHelper();


  Future<bool?> initDropbox() async {
    DropboxConfig dropboxConfig = await loadDropboxConfig();
     String dropboxClientId = dropboxConfig.clientId;
     String dropboxKey = dropboxConfig.key;
     String dropboxSecret = dropboxConfig.secret;

    try {
      final res =
          await Dropbox.init(dropboxClientId, dropboxKey, dropboxSecret);
      print("result");
      return res;
    } catch (e) {
      return false;
      print(e);
    }
  }

  Future authorize() async {
    final res = await Dropbox.authorize();
    print('res');
  }

  Future authorizeWithAccessToken() async {
    DropboxConfig dropboxConfig = await loadDropboxConfig();
    print(dropboxConfig.accessToken);
    String accessToken = dropboxConfig.accessToken;
    final result = Dropbox.authorizeWithAccessToken(accessToken);
    print(result);
  }

  Future getAccountName() async {
    //if (await checkAuthorized(true)) {
    final user = await Dropbox.getAccountName();
    print('user = $user');
    //}
  }

  Future listFolder(path) async {
    List list = [];
    final result = await Dropbox.listFolder(path);
    list.clear();
    list.addAll(result);
  }

  String? localFilePath;

  Future<bool> syncDropboxFiles() async {
    try {
      // Download files from Dropbox to local storage
      var files = await Dropbox.listFolder(""); // Root directory
      final dir = await getApplicationDocumentsDirectory();
      for (var file in files) {
        String fileName = file['name'];
        if (fileName.endsWith('.pdf')) {
          String localPath = '${dir.path}/$fileName';

          bool fileExistsInDb = await db.isFileInDatabase(localPath);
          // If file is not in the database, download it
          if (!fileExistsInDb) {
            // Extract metadata and store it in SQLite
            await Dropbox.download(file['pathLower'], localPath);
            print("Downloaded $fileName to $localPath");

            // Now `localPath` has the downloaded file
            // Extract metadata and store in SQLite (next steps)
            await extractAndStoreMetadata(localPath, fileName);
          } else {
            print(
                "File $fileName already exists in the database. Skipping download.");
          }
        }
      }
      return false;
    } catch (e) {
      return false;
      print('Error syncing with Dropbox: $e');
    }
  }

  Future uploadTest() async {
    var tempDir = await getTemporaryDirectory();
    var filepath = '${tempDir.path}/test_upload.txt';
    File(filepath).writeAsStringSync(
        'contents.. from ' + (Platform.isIOS ? 'iOS' : 'Android') + '\n');

    final result =
        await Dropbox.upload(filepath, '/test_upload.txt', (uploaded, total) {
      print('progress $uploaded / $total');
    });
    print(result);
  }

  Future downloadTest() async {
    var tempDir = await getTemporaryDirectory();
    var filepath = '${tempDir.path}/test_download.zip'; // for iOS only!!
    // print(filepath);
    final result = await Dropbox.download('/file_in_dropbox.zip', filepath,
        (downloaded, total) {
      print('progress $downloaded / $total');
    });
    print(result);
    print(File(filepath).statSync());
  }

  Future<String?> getTemporaryLink(path) async {
    final result = await Dropbox.getTemporaryLink(path);
    return result;
  }

  Future<Uint8List?> getThumbnail(path) async {
    try {
      final b64 = await Dropbox.getThumbnailBase64String(path);
      Uint8List thumbImage = base64Decode(b64!);
      return thumbImage;
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future getAccountInfo() async {
    final accountInfo = await Dropbox.getCurrentAccount();
    if (accountInfo != null) {
      print(accountInfo.name!.displayName);
      print(accountInfo.email!);
      print(accountInfo.rootInfo!.homeNamespaceId!);
      print(accountInfo.profilePhotoUrl!);
    }
  }

  Future<void> extractAndStoreMetadata(
      String localPath, String fileName) async {
    try {
      // Extract text from the first page
      String firstPageText = await extractFirstPageText(localPath);

      // Extract title and author from the text
      String? title = extractTitleFromText(firstPageText);
      String? author = extractAuthorFromText(firstPageText);

      String description = extractDescriptionFromText(firstPageText);

      Uint8List? thumbnail = await getThumbnail('/$fileName');

      // Step 3: Store metadata and thumbnail in SQLite
      await db.saveFileToDatabase(
          title: title ?? 'Unknown Title',
          author: author ?? 'Unknown Author',
          description: description,
          filePath: localPath,
          thumbnailPath: thumbnail);
    } catch (e) {
      print('Error extracting metadata: $e');
    }
  }

  String extractDescriptionFromText(String text) {
    try {
      // Replace newlines with spaces
      text = text.replaceAll('\n', ' ');
      // If the text has more than 200 characters, return the first 200 characters
      if (text.length > 200) {
        return text.substring(0, 200).trim();
      }
      return text.trim();
    } catch (e) {
      print('Error extracting description: $e');
      return 'No description available';
    }
  }

  String? extractTitleFromText(String text) {
    try {
      // Example: Assume the title is the first line of the text
      List<String> lines = text.split('\n');

      if (lines.isNotEmpty) {
        return "${lines[0].trim()} ${lines[1].trim()}"; // The first line as the title
      }
    } catch (e) {
      print(e);
    }
    return null; // Return null if no title is found
  }

  String? extractAuthorFromText(String text) {
    try {
      // Example: Assume the author's name is in the second line or somewhere near the start
      List<String> lines = text.split('\n');

      for (String line in lines) {
        if (line.toLowerCase().contains('author') ||
            line.toLowerCase().contains('by') ||
            line.toLowerCase().contains('published by') ||
            line.toLowerCase().contains("written by")) {
          // This is just a heuristic; it looks for lines containing the word 'author' or 'by'
          return line
              .replaceAll(RegExp(r'author|by', caseSensitive: false), '')
              .trim();
        }
      }
    } catch (e) {
      print(e);
    }
    // If no author info found, return null
    return null;
  }

  Future<String> extractFirstPageText(String localPath) async {
    try {
      // Load the PDF file using read_pdf_text
      final text = await ReadPdfText.getPDFtext(localPath);

      // Check if text extraction is successful
      if (text.isNotEmpty) {
        // Return the extracted text
        return text;
      } else {
        return 'No text found';
      }
    } catch (e) {
      print('Error extracting text: $e');
      return 'Error extracting text'; // Return a message in case of error
    }
  }
}
