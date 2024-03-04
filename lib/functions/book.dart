import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:merlin/pages/reader/reader.dart';
import 'package:merlin/pages/recent/recent.dart';
import 'package:path_provider/path_provider.dart';

class Book {
  String filePath;
  String text;
  String title;
  String customTitle;
  String author;
  double lastPosition = 0;
  Uint8List? imageBytes;
  double progress;

  Book({
    required this.filePath,
    required this.text,
    required this.title,
    required this.customTitle,
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
      customTitle: bookInfo.title,
      author: bookInfo.author,
      lastPosition: bookInfo.lastPosition,
      imageBytes: imageInfo.imageBytes,
      progress: imageInfo.progress,
    );
  }

  @override
  String toString() {
    return 'Book {filePath: $filePath, title: $title, author: $author, lastPosition: $lastPosition, progress: $progress, text: ${text.substring(0, (text.length * 0.1).toInt())}}';
  }

  Map<String, dynamic> toJson() {
    return {
      'filePath': filePath,
      'title': title,
      'customTitle': title,
      'author': author,
      'progress': progress,
      'lastPosition': lastPosition,
      'text': text,
      'imageBytes': imageBytes?.toList(),
    };
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      filePath: json['filePath'],
      title: json['title'],
      customTitle: json['customTitle'],
      author: json['author'],
      progress: json['progress'],
      lastPosition: json['lastPosition'],
      text: json['text'],
      imageBytes: json['imageBytes'] != null ? Uint8List.fromList(json['imageBytes'].cast<int>()) : null,
    );
  }

  Future<void> saveJsonToFile(Map<String, dynamic> jsonData, String fileName) async {
    try {
      // print('Saving inside book class file...');
      final appDir = await getExternalStorageDirectory();
      // print(appDir?.path);
      final filePath = '${appDir?.path}/books/$fileName.json';

      final file = File(filePath);
      await file.writeAsString(jsonEncode(jsonData));

      // print('Файл успешно сохранен по пути: $filePath');
    } catch (e) {
      // print('Ошибка при сохранении файла: $e');
    }
  }

  Future<void> deleteFileByTitle(String title) async {
    try {
      final appDir = await getExternalStorageDirectory();
      final filePath = '${appDir?.path}/books/$title.json';

      final file = File(filePath);

      if (await file.exists()) {
        await file.delete();
        // print('Файл $title успешно удален');
      } else {
        // print('Файл $title не найден');
      }
    } catch (e) {
      // print('Ошибка при удалении файла: $e');
    }
  }

  Future<void> updateTextInFile(String newText) async {
    try {
      final appDir = await getExternalStorageDirectory();
      final filePath = '${appDir?.path}/books/$title.json';

      final file = File(filePath);
      String content = await file.readAsString();
      Map<String, dynamic> jsonMap = jsonDecode(content);

      jsonMap['text'] = newText;

      await file.writeAsString(jsonEncode(jsonMap));
    } catch (e) {
      // print('Ошибка при обновлении текста в файле: $e');
    }
  }

  Future<void> updateTitleInFile(String newTitle) async {
    try {
      final appDir = await getExternalStorageDirectory();
      final filePath = '${appDir?.path}/books/$title.json';

      final file = File(filePath);
      String content = await file.readAsString();
      Map<String, dynamic> jsonMap = jsonDecode(content);

      jsonMap['customTitle'] = newTitle;

      await file.writeAsString(jsonEncode(jsonMap));
    } catch (e) {
      // print('Ошибка при обновлении заголовка в файле: $e');
    }
  }

  Future<void> updateAuthorInFile(String newAuthor) async {
    try {
      final appDir = await getExternalStorageDirectory();
      final filePath = '${appDir?.path}/books/$title.json';

      final file = File(filePath);
      String content = await file.readAsString();
      Map<String, dynamic> jsonMap = jsonDecode(content);

      jsonMap['author'] = newAuthor;

      await file.writeAsString(jsonEncode(jsonMap));
    } catch (e) {
      // print('Ошибка при обновлении автора в файле: $e');
    }
  }

  Future<void> updateLastPositionInFile(double newLastPosition) async {
    try {
      final appDir = await getExternalStorageDirectory();
      final filePath = '${appDir?.path}/books/$title.json';

      final file = File(filePath);
      String content = await file.readAsString();
      Map<String, dynamic> jsonMap = jsonDecode(content);

      jsonMap['lastPosition'] = newLastPosition;

      await file.writeAsString(jsonEncode(jsonMap));
    } catch (e) {
      // print('Ошибка при обновлении последней позиции в файле: $e');
    }
  }

  Future<void> updateProgressInFile(double newProgress) async {
    try {
      // print('Updating PROGRESS inside book class file...');

      final appDir = await getExternalStorageDirectory();
      final filePath = '${appDir?.path}/books/$title.json';
      // print(filePath);

      final file = File(filePath);
      String content = await file.readAsString();
      Map<String, dynamic> jsonMap = jsonDecode(content);

      jsonMap['progress'] = newProgress;

      await file.writeAsString(jsonEncode(jsonMap));
    } catch (e) {
      // print('Ошибка при обновлении прогресса в файле: $e');
    }
  }

  Future<void> updateStageInFile(double newProgress, double newLastPosition) async {
    try {
      // print('Updating STAGE inside book class file...');

      final appDir = await getExternalStorageDirectory();
      final filePath = '${appDir?.path}/books/$title.json';
      // print(filePath);

      final file = File(filePath);
      String content = await file.readAsString();
      Map<String, dynamic> jsonMap = jsonDecode(content);

      jsonMap['progress'] = newProgress;
      jsonMap['lastPosition'] = newLastPosition;

      await file.writeAsString(jsonEncode(jsonMap));
    } catch (e) {
      // print('Ошибка при обновлении прогресса и позиции в файле: $e');
    }
  }
}
