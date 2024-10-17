import 'dart:convert';
import 'package:coqui/helper/database_helper.dart';
import 'package:coqui/view/widgets/custom_snackbar.dart';
import 'package:dropbox_client/dropbox_client.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:xml/xml.dart';
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
    }
  }

  Future<bool?> authorize() async {
    final result = await Dropbox.authorize();
    await Future.delayed(const Duration(seconds: 30));
    print('result');
    return result;
  }

  Future<String?> getAccessToken() async {
    final result = await Dropbox.getAccessToken();
    print('result');
    return result;
  }

  Future<bool?> authorizeWithAccessToken(String token) async {
    String accessToken = token;
    final result = await Dropbox.authorizeWithAccessToken(accessToken);
    print("Authorized with token : $result");
    return result;
  }

  Future getAccountName() async {
    final user = await Dropbox.getAccountName();
    print('user = $user');
  }

  Future listFolder(path) async {
    List list = [];
    final result = await Dropbox.listFolder(path);
    list.clear();
    list.addAll(result);
  }

  Future<String> getExternalStoragePath() async {
    // Get the path to external storage
    final directory = await getExternalStorageDirectory();
    return directory!.path;
  }

  Future<bool> syncDropboxFiles() async {
    bool filesDownloadedAndAdded = false;
    try {
      // Start from the app's folder in Dropbox
      var authorFolders =
          await Dropbox.listFolder(""); // Access 'calTablet' directory
      final dir = await getApplicationDocumentsDirectory();

      int downloadedBooksCount = 0;
      for (var authorFolder in authorFolders) {
        var books = await Dropbox.listFolder(authorFolder['pathLower']);

        for (var bookFolder in books) {
          if (downloadedBooksCount >= 1) {
            // Stop downloading if 2 books have already been downloaded
            print('Limit of 2 books reached. Stopping further downloads.');
            return true;
          }

          var bookFiles = await Dropbox.listFolder(bookFolder['pathLower']);

          String? coverPath;
          String? epubPath;
          String? opfPath;

          // Retrieve files (cover image, EPUB, and OPF metadata)
          for (var file in bookFiles) {
            String fileName = file['name'];
            String filePath = file['pathLower'];

            if (fileName.endsWith('.jpg') || fileName.endsWith('.png')) {
              coverPath = filePath;
            } else if (fileName.endsWith('.epub')) {
              epubPath = filePath;
            } else if (fileName.endsWith('.opf')) {
              opfPath = filePath;
            }
          }

          // Proceed if all required files are found
          if (coverPath != null && epubPath != null && opfPath != null) {
            // Ensure dynamic directory exists before downloading
            final dynamicDirPath =
                '${dir.path}/${authorFolder['name']}/${bookFolder['name']}';
            final dynamicDir = Directory(dynamicDirPath);

            if (!await dynamicDir.exists()) {
              await dynamicDir.create(
                  recursive: true); // Create the directory if necessary
            }

            // Construct correct local paths
            String localCoverPath =
                '${dynamicDir.path}/${coverPath.split('/').last}';
            String localEpubPath =
                '${dynamicDir.path}/${epubPath.split('/').last}';
            String localOpfPath =
                '${dynamicDir.path}/${opfPath.split('/').last}';

            // Extract metadata from OFP file before downloading to check if the book exists

            bool? existsInDB = await db.isFileInDatabase(localOpfPath);
            if (existsInDB) {
              print('Book  already exists in the database. Skipping download.');
              continue; // Skip this book, no need to download
            }
            // Download files locally
            await Future.wait([
              Dropbox.download(coverPath, localCoverPath),
              Dropbox.download(epubPath, localEpubPath),
              Dropbox.download(opfPath, localOpfPath),
            ]);
            // Extract metadata from OPF file and store in SQLite
            await extractAndStoreMetadataFromOFP(
                localCoverPath, localEpubPath, localOpfPath);
            downloadedBooksCount++;
          }
        }
      }
      return true;
    } catch (e) {
      print('Error syncing with Dropbox: $e');
      return false;
    }
  }

  Future<String?> extractAndStoreMetadataFromOFP(
      String coverPath, String epubPath, String opfPath) async {
    try {
      final file = File(opfPath);
      if (await file.exists()) {
        // Read the OPF file content
        String opfContent = await file.readAsString();
        print("Metadata content: $opfContent");

        // Parse the OPF content as XML
        final document = XmlDocument.parse(opfContent);

        final titleElements = document.findAllElements('dc:title');
        final title = titleElements.isNotEmpty
            ? titleElements.first.text // Take the first title if multiple found
            : 'Untitled';

        // Extract all authors and concatenate them
        final authorElements = document.findAllElements('dc:creator');
        final author = authorElements.isNotEmpty
            ? authorElements
                .map((e) => e.text)
                .toList()
                .join(', ') // Join authors if multiple
            : 'Unknown Author';

        final descriptionElements = document.findAllElements('dc:description');
        String description = descriptionElements.isNotEmpty
            ? descriptionElements.first.text
            : 'No description available';

        // Clean up the description by removing any HTML tags
        description = description.replaceAll(
            RegExp(r'<[^>]*>'), ''); // Removes all HTML tags

        final publishedDateString =
            document.findAllElements('dc:date').single.text;

        // Parse the published date and format it
        DateTime publishedDateTime = DateTime.parse(publishedDateString);

        String publishedDate =
            DateFormat("MMM d, yyyy").format(publishedDateTime);

        // Extract the readStatus
        // final readStatusMeta = document.findElements('meta').where((meta) {
        //   return meta.getAttribute('name') ==
        //       'calibre:user_metadata:#read_status';
        // }).first;
        //
        // final readStatus = readStatusMeta.getAttribute('content') == 'true';
        //
        // // Extract pages
        // final pagesMeta = document.findElements('meta').where((meta) {
        //   return meta.getAttribute('name') == 'calibre:user_metadata:#pages';
        // }).first;
        //
        // final pages = int.tryParse(pagesMeta.getAttribute('content') ?? '0');

        // Use current timestamp as the download date and format it as "May 2, 2024"
        String downloadDate = DateFormat("MMM d, yyyy").format(DateTime.now());

        // Store the metadata and cover image path in the database
        await db.saveFileToDatabase(
          title: title.isEmpty ? 'Unknown Title' : title,
          author: author.isEmpty ? 'Unknown Author' : author,
          description:
              description.isEmpty ? 'No description available' : description,
          publishedDate: publishedDate.isEmpty ? 'Unknown' : publishedDate,
          readStatus: "0",
          downloadDate: downloadDate,
          filePath: epubPath,
          fileMetaPath: opfPath,
          totalPages: 0,
          coverImagePath: coverPath, // Store the cover image path
        );

        print("Metadata extraction and database save successful.");
      } else {
        print("OPF file not found at: $opfPath");
      }
    } catch (e) {
      print('Error extracting metadata from OPF: $e');
    }
  }
}
