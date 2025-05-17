import 'package:merlin/functions/book.dart';
import 'package:path/path.dart' as path;

class BookItem extends Book {
  final int fileSize;

  String get bookTypeName =>
      path.extension(filePath, 2).replaceFirst('.', '').toUpperCase();

  BookItem(
      {required this.fileSize,
      required super.filePath,
      required super.text,
      required super.title,
      required super.customTitle,
      required super.author,
      required super.lastPosition,
      required super.sequence,
      required super.dateAdded,
      super.imageBytes,
      super.progress,
      super.lp,
      super.version = 0});
}
