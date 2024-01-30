import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:merlin/pages/reader/reader.dart';
import 'package:merlin/pages/recent/imageloader.dart';
import 'package:merlin/pages/recent/recent.dart';
import 'package:path_provider/path_provider.dart';

class Book {
  String filePath;
  String text;
  String title;
  String author;
  double lastPosition = 0;
  Uint8List? imageBytes;
  double progress;

  Book({
    required this.filePath,
    required this.text,
    required this.title,
    required this.author,
    required this.lastPosition,
    required this.imageBytes,
    required this.progress,
  });

  factory Book.combine(BookInfo bookInfo, ImageInfo imageInfo) {
    return Book(
      filePath: bookInfo.filePath,
      text: bookInfo.fileText,
      title: bookInfo.title,
      author: bookInfo.author,
      lastPosition: bookInfo.lastPosition,
      imageBytes: imageInfo.imageBytes,
      progress: imageInfo.progress,
    );
  }

  @override
  String toString() {
    return 'Book {filePath: $filePath, title: $title, author: $author, lastPosition: $lastPosition, progress: $progress, text: $text}';
  }

  Map<String, dynamic> toJson() {
    return {
      'filePath': filePath,
      'text': text,
      'title': title,
      'author': author,
      'lastPosition': lastPosition,
      'imageBytes': imageBytes,
      'progress': progress,
    };
  }

  Future<void> saveJsonToFile(Map<String, dynamic> jsonData, String fileName) async {
    try {
      final appDir = await getExternalStorageDirectory();
      print(appDir?.path);
      final filePath = '${appDir?.path}/$fileName.json';

      final file = File(filePath);
      await file.writeAsString(jsonEncode(jsonData));

      print('Файл успешно сохранен по пути: $filePath');
    } catch (e) {
      print('Ошибка при сохранении файла: $e');
    }
  }
}
