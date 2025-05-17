import 'dart:io';
import 'dart:ui';

import 'package:external_path/external_path.dart';
import 'package:flutter/foundation.dart';
import 'package:merlin/domain/books_repository.dart';
import 'package:path/path.dart' as p;

enum ScanBooksTaskState {
  inProgress,
  completed,
}

class ScanBooksTask {
  static const oneOffTaskId = "scan_books";
  static const periodicTaskId = "scan_books_periodic";
  static const name = "scanBooks";

  final BooksRepository _booksRepo;

  ScanBooksTask() : _booksRepo = BooksRepository();

  Future<bool> run() async {
    if (!Platform.isAndroid) {
      return Future.error('Platform not supported');
    }

    final sendPort = IsolateNameServer.lookupPortByName(name);
    sendPort?.send(ScanBooksTaskState.inProgress.index);

    try {
      final dirs = await ExternalPath.getExternalStorageDirectories();
      if (dirs == null) {
        return Future.error('No external storages');
      }

      final books = [];
      for (final dir in dirs) {
        books.addAll(scanningBooksRecursive(Directory(dir)));
      }

      if (books.isEmpty) {
        if (kDebugMode) {
          print('Books not found');
        }
        return Future.value(true);
      }

      for (final book in books) {
        try {
          final result = await _booksRepo.save(book.path);
          if (kDebugMode) {
            print('Save result: ${result.runtimeType} | Book: ${book.path}');
          }
        } catch (e, stackTrace) {
          print(e);
          print(stackTrace);
        }
      }
    } catch (e) {
      return Future.error(e);
    } finally {
      sendPort?.send(ScanBooksTaskState.completed.index);
    }

    return Future.value(true);
  }
}

Iterable<File> scanningBooksRecursive(Directory dir) sync* {
  var dirList = dir.listSync();
  for (final FileSystemEntity entity in dirList) {
    try {
      final isBook = BooksRepository.supportedExtensions
          .contains(p.extension(entity.path));
      if (entity is File && isBook) {
        yield entity;
      } else if (entity is Directory) {
        yield* scanningBooksRecursive(Directory(entity.path));
      }
    } catch (e) {
      continue;
    }
  }
}
