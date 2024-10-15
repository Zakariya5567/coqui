import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

import '../models/file_model.dart';

class DatabaseHelper {
  // Singleton instance
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  // Getter to get the database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDb() async {
    // Get the path to the documents directory
    final documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'pdf_library.db');

    // Open the database, creating it if necessary
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Create table schema
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE files(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        author TEXT,
        description TEXT,
        filePath TEXT,
        thumbnailPath TEXT
      )
    ''');
  }

  // Insert a new file into the database
  Future<void> saveFileToDatabase({
    required String title,
    required String author,
    required String description,
    required String filePath,
    Uint8List? thumbnailPath,
  }) async {
    final db = await database;
    // Prepare the file data to insert
    Map<String, dynamic> fileData = {
      'title': title,
      'author': author,
      'description': description,
      'filePath': filePath,
      'thumbnailPath': thumbnailPath
    };

    // Insert or replace the file record
    await db.insert(
      'files',
      fileData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fetch all files from the database
  Future<List<FileModel>> fetchAllFilesFromDatabase() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('files');

    // Convert each map to a FileModel object
    return List.generate(maps.length, (i) {
      return FileModel.fromMap(maps[i]);
    });
  }

  // Fetch files from the database based on search criteria
  Future<List<FileModel>> fetchSearchFilesFromDatabase({
    required String searchText,
    required bool searchByTitle,
  }) async {
    final db = await database;

    String searchField = searchByTitle ? 'title' : 'author';
    final List<Map<String, dynamic>> maps = await db.query(
      'files',
      where: '$searchField LIKE ?',
      whereArgs: ['%$searchText%'],
    );

    // Convert each map to a FileModel object
    return List.generate(maps.length, (i) {
      return FileModel.fromMap(maps[i]);
    });
  }

  // Delete a file by ID
  Future<void> deleteFile(int id) async {
    final db = await database;
    await db.delete(
      'files',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Check if the file already exists in the database
  Future<bool> isFileInDatabase(String filePath) async {
    final db = await database;
    final result = await db.query(
      'files',
      where: 'filePath = ?',
      whereArgs: [filePath],
    );

    return result.isNotEmpty;
  }

  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('files');
    print('Database cleared: All files have been deleted.');
  }


  // Modified method to fetch files with search and filter functionality
  Future<List<Map<String, dynamic>>> searchFilesFromDatabase({
    String? title,
    String? author,
  }) async {
    final db = await database;

    // Build the query based on search criteria
    String whereClause = '';
    List<dynamic> whereArgs = [];

    // If title is provided, add it to the where clause
    if (title != null && title.isNotEmpty) {
      whereClause = 'title LIKE ?';
      whereArgs.add('%$title%');
    }

    // If author is provided, add it to the where clause
    if (author != null && author.isNotEmpty) {
      if (whereClause.isNotEmpty) {
        whereClause += ' AND ';
      }
      whereClause += 'author LIKE ?';
      whereArgs.add('%$author%');
    }

    // Execute the query with the where clause if any filters are applied
    if (whereClause.isNotEmpty) {
      return await db.query(
        'files',
        where: whereClause,
        whereArgs: whereArgs,
      );
    }

    // If no filters, return all files
    return await db.query('files');
  }

}
