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
      'imageBytes': imageBytes?.toList(),
      'progress': progress,
    };
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      filePath: json['filePath'],
      text: json['text'],
      title: json['title'],
      author: json['author'],
      lastPosition: json['lastPosition'],
      imageBytes: json['imageBytes'] != null ? Uint8List.fromList(json['imageBytes'].cast<int>()) : null,
      progress: json['progress'],
    );
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

  Future<void> updateTextInFile(String newText) async {
    try {
      final appDir = await getExternalStorageDirectory();
      final filePath = '${appDir?.path}/${this.filePath}.json';

      final file = File(filePath);
      String content = await file.readAsString();
      Map<String, dynamic> jsonMap = jsonDecode(content);

      // Изменяем значение текста внутри JSON
      jsonMap['text'] = newText;

      // Записываем обновленные данные обратно в файл
      await file.writeAsString(jsonEncode(jsonMap));
    } catch (e) {
      print('Ошибка при обновлении текста в файле: $e');
    }
  }

  Future<void> updateTitleInFile(String newTitle) async {
    try {
      final appDir = await getExternalStorageDirectory();
      final filePath = '${appDir?.path}/${this.filePath}.json';

      final file = File(filePath);
      String content = await file.readAsString();
      Map<String, dynamic> jsonMap = jsonDecode(content);

      // Изменяем значение заголовка внутри JSON
      jsonMap['title'] = newTitle;

      // Записываем обновленные данные обратно в файл
      await file.writeAsString(jsonEncode(jsonMap));
    } catch (e) {
      print('Ошибка при обновлении заголовка в файле: $e');
    }
  }

  Future<void> updateAuthorInFile(String newAuthor) async {
    try {
      final appDir = await getExternalStorageDirectory();
      final filePath = '${appDir?.path}/${this.filePath}.json';

      final file = File(filePath);
      String content = await file.readAsString();
      Map<String, dynamic> jsonMap = jsonDecode(content);

      // Изменяем значение автора внутри JSON
      jsonMap['author'] = newAuthor;

      // Записываем обновленные данные обратно в файл
      await file.writeAsString(jsonEncode(jsonMap));
    } catch (e) {
      print('Ошибка при обновлении автора в файле: $e');
    }
  }

  Future<void> updateLastPositionInFile(double newLastPosition) async {
    try {
      final appDir = await getExternalStorageDirectory();
      final filePath = '${appDir?.path}/${this.filePath}.json';

      final file = File(filePath);
      String content = await file.readAsString();
      Map<String, dynamic> jsonMap = jsonDecode(content);

      // Изменяем значение последней позиции внутри JSON
      jsonMap['lastPosition'] = newLastPosition;

      // Записываем обновленные данные обратно в файл
      await file.writeAsString(jsonEncode(jsonMap));
    } catch (e) {
      print('Ошибка при обновлении последней позиции в файле: $e');
    }
  }

  Future<void> updateProgressInFile(double newProgress) async {
    try {
      final appDir = await getExternalStorageDirectory();
      final filePath = '${appDir?.path}/$title.json';
      print(filePath);

      final file = File(filePath);
      String content = await file.readAsString();
      Map<String, dynamic> jsonMap = jsonDecode(content);

      // Изменяем значение прогресса внутри JSON
      jsonMap['progress'] = newProgress;

      // Записываем обновленные данные обратно в файл
      await file.writeAsString(jsonEncode(jsonMap));
    } catch (e) {
      print('Ошибка при обновлении прогресса в файле: $e');
    }
  }
}
