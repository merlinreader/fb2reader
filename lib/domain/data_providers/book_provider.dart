// НЕЛИКВИДНЫЙ ФАЙЛ
// ФУЛЛ ПЕРЕПИСЬ ИЛИ УДАЛЕНИЕ
// НЕЛИКВИДНЫЙ ФАЙЛ
// ФУЛЛ ПЕРЕПИСЬ ИЛИ УДАЛЕНИЕ
// НЕЛИКВИДНЫЙ ФАЙЛ
// ФУЛЛ ПЕРЕПИСЬ ИЛИ УДАЛЕНИЕ
// НЕЛИКВИДНЫЙ ФАЙЛ
// ФУЛЛ ПЕРЕПИСЬ ИЛИ УДАЛЕНИЕ
// НЕЛИКВИДНЫЙ ФАЙЛ
// ФУЛЛ ПЕРЕПИСЬ ИЛИ УДАЛЕНИЕ
// НЕЛИКВИДНЫЙ ФАЙЛ
// ФУЛЛ ПЕРЕПИСЬ ИЛИ УДАЛЕНИЕ
// НЕЛИКВИДНЫЙ ФАЙЛ
// ФУЛЛ ПЕРЕПИСЬ ИЛИ УДАЛЕНИЕ

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class _BookKeys {
  static String filePath = 'book_path';
  static String fileText = 'book_text';
  static String title = 'book_title';
  static String author = 'book_author';
  static String lastPosition = 'book_position';
  static String imageBytes = 'book_bytes';
  static String progress = 'book_progress';
}

class BookProvider {
  static final BookProvider _instance = BookProvider._();

  factory BookProvider() {
    return _instance;
  }

  String? _fileText;
  String? _title;
  String? _author;
  String? _lastPosition;
  Uint8List? _imageBytes;
  double? _progress;
  final String _filePath = '/storage/emulated/0/Android/data/com.example.merlin/';

  BookProvider._();

  Future<void> initAsync() async {}

  Future<void> updateTitle(String fileName, String newTitle) async {
    try {
      File file = File('$_filePath$fileName.json');
      Map<String, dynamic> jsonData = jsonDecode(await file.readAsString());
      jsonData[_BookKeys.title] = newTitle;
      await file.writeAsString(jsonEncode(jsonData));
      print('Title успешно обновлен в файле по пути: $_filePath$fileName.json');
    } catch (e) {
      print('Ошибка при обновлении title в файле: $e');
    }
  }

  Future<void> updateAuthor(String fileName, String newAuthor) async {
    try {
      File file = File('$_filePath$fileName.json');
      Map<String, dynamic> jsonData = jsonDecode(await file.readAsString());
      jsonData[_BookKeys.author] = newAuthor;
      await file.writeAsString(jsonEncode(jsonData));
      print('Author успешно обновлен в файле по пути: $_filePath$fileName.json');
    } catch (e) {
      print('Ошибка при обновлении author в файле: $e');
    }
  }

  Future<String?> getFilePath() async {
    return _filePath;
  }

  Future<String?> getFileText() async {
    return _fileText;
  }

  Future<String?> getTitle(String fileName) async {
    File file = File('$_filePath$fileName.json');
    Map<String, dynamic> jsonData = jsonDecode(await file.readAsString());
    String? title = jsonData[_BookKeys.title];
    return title;
  }

  Future<String?> getAuthor() async {
    return _author;
  }

  Future<String?> getLastPosition() async {
    return _lastPosition;
  }

  Future<Uint8List?> getImage() async {
    return _imageBytes;
  }

  Future<double?> getProgress() async {
    return _progress;
  }
}
