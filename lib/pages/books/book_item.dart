import 'package:equatable/equatable.dart';
import 'package:merlin/domain/books_repository.dart';
import 'package:merlin/functions/book.dart';
import 'package:path/path.dart' as path;

class BookItem extends Book with EquatableMixin {
  final int fileSize;

  String get bookTypeName {
    final extension =
        path.extension(filePath, 2).replaceFirst('.', '').toUpperCase();
    if (BooksRepository.supportedExtensions.contains(extension)) {
      return extension;
    } else {
      return path.extension(filePath, 1).replaceFirst('.', '').toUpperCase();
    }
  }

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

  @override
  List<Object?> get props => [
        fileSize,
        filePath,
        title,
        customTitle,
        author,
        lastPosition,
        sequence,
        dateAdded,
        progress,
        lp
      ];
}
