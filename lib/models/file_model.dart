
import 'dart:typed_data';

class FileModel {
  final int? id;
  final String? title;
  final String? author;
  final String? description;
  final String? filePath;
  final Uint8List? thumbnailPath;

  FileModel({
    this.id,
    this.title,
    this.author,
    this.description,
    this.filePath,
    this.thumbnailPath,
  });

  // Convert a map from the database to a FileModel object
  factory FileModel.fromMap(Map<String, dynamic> map) {
    return FileModel(
      id: map['id'],
      title: map['title'],
      author: map['author'],
      description: map['description'],
      filePath: map['filePath'],
      thumbnailPath: map['thumbnailPath'],
    );
  }

  // Convert a FileModel object to a map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'filePath': filePath,
      'thumbnailPath': thumbnailPath,
    };
  }
}
