import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:merlin/pages/reader/reader.dart';
import 'package:merlin/pages/recent/recent.dart';
import 'package:path_provider/path_provider.dart';

class LastPosition {
  int paragraph;
  double offset;

  LastPosition({required this.paragraph, required this.offset});

  Map<String, dynamic> toJson() {
    return {'paragraph': paragraph, 'offset': offset};
  }

  factory LastPosition.fromJson(Map<String, dynamic> json) {
    return LastPosition(
      paragraph: json['paragraph'],
      offset: json['offset'],
    );
  }
}

class BookInfo {
  String filePath;
  String fileText;
  String title;
  String author;
  double? lastPosition; // маяк BookInfo
  int version;
  LastPosition? lp;

  BookInfo(
      {required this.filePath,
      required this.fileText,
      required this.title,
      required this.author,
      this.version = 1,
      this.lastPosition = 0,
      this.lp});

  Map<String, dynamic> toJson() {
    return {
      'filePath': filePath,
      'fileText': fileText,
      'title': title,
      'author': author,
      'lastPosition': lastPosition,
      'lp': lp
    };
  }

  void setPosZero() {
    lastPosition = 0;
  }

  factory BookInfo.fromJson(Map<String, dynamic> json) {
    return BookInfo(
      filePath: json['filePath'],
      fileText: json['fileText'],
      title: json['title'],
      author: json['author'],
      lastPosition: json['lastPosition'],
      lp: LastPosition.fromJson(json['lp'])
    );
  }
}

class Book {
  String filePath;
  String text;
  String title;
  String customTitle;
  String author;
  double? lastPosition = 0;
  Uint8List? imageBytes;
  double? progress;
  LastPosition? lp;
  int version;

  Book(
      {required this.filePath,
      required this.text,
      required this.title,
      required this.customTitle,
      required this.author,
      required this.lastPosition,
      this.imageBytes,
      this.progress,
      this.lp,
      this.version = 0});

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
        version: bookInfo.version);
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
      'version': 2,
      'lp': lp?.toJson()
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
        imageBytes: json['imageBytes'] != null
            ? Uint8List.fromList(json['imageBytes'].cast<int>())
            : null,
        lp: LastPosition.fromJson(json['lp'] ?? {'paragraph': 0, 'offset': 0.0}),
        version: json['version']);
  }

  Future<void> saveJsonToFile(
      Map<String, dynamic> jsonData, String fileName) async {
    try {
      // print('Saving inside book class file...');
      final appDir = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationDocumentsDirectory();
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
      final appDir = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationDocumentsDirectory();
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
      final appDir = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationDocumentsDirectory();
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
      final appDir = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationDocumentsDirectory();
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
      final appDir = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationDocumentsDirectory();
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
      final appDir = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationDocumentsDirectory();
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

      final appDir = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationDocumentsDirectory();
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

  Future<void> updateStageInFile(
      double newProgress, double newLastPosition, int pg) async {
    try {
      // print('Updating STAGE inside book class file...');

      final appDir = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationDocumentsDirectory();
      final filePath = '${appDir?.path}/books/$title.json';
      // print(filePath);

      final file = File(filePath);
      String content = await file.readAsString();
      Map<String, dynamic> jsonMap = jsonDecode(content);

      jsonMap['progress'] = newProgress;
      jsonMap['lastPosition'] = newLastPosition;
      jsonMap['lp'] = <String, dynamic>{};
      jsonMap['lp']['offset'] = newLastPosition;
      jsonMap['lp']['paragraph'] = pg;

      await file.writeAsString(jsonEncode(jsonMap));
    } catch (e) {
      // print('Ошибка при обновлении прогресса и позиции в файле: $e');
    }
  }
}
