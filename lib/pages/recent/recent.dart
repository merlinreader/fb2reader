import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:merlin/UI/router.dart';
import 'package:merlin/functions/book.dart';
import 'package:merlin/style/text.dart';
import 'package:merlin/style/colors.dart';
import 'package:merlin/pages/recent/imageloader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart';
import 'package:path_provider/path_provider.dart';

import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:merlin/pages/reader/reader.dart';

class RecentPage extends StatefulWidget {
  const RecentPage({super.key});
  @override
  State<RecentPage> createState() => RecentPageState();
}

class ImageInfo {
  Uint8List? imageBytes;
  String title;
  String author;
  String fileName;
  double progress;

  ImageInfo({this.imageBytes, required this.title, required this.author, required this.fileName, required this.progress});

  Map<String, dynamic> toJson() {
    return {
      'imageBytes': imageBytes,
      'title': title,
      'author': author,
      'fileName': fileName,
      'progress': progress,
    };
  }

  factory ImageInfo.fromJson(Map<String, dynamic> json) {
    return ImageInfo(
      imageBytes: Uint8List.fromList(List<int>.from(json['imageBytes'])),
      title: json['title'],
      author: json['author'],
      fileName: json['fileName'],
      progress: json['progress']?.toDouble() ?? 0.0,
    );
  }
}

class RecentPageState extends State<RecentPage> {
  final ImageLoader imageLoader = ImageLoader();
  final ScrollController _scrollController = ScrollController();
  Uint8List? imageBytes;
  List<ImageInfo> images = [];
  List<Book> books = [];
  String? firstName;
  String? lastName;
  String? name;
  String? title;
  bool _isOperationInProgress = false;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [
        SystemUiOverlay.top,
        SystemUiOverlay.bottom,
      ],
    );

    super.initState();
    _initData();
  }

  @override
  void didChangeDependencies() {
    // print("Start didChangeDependencies...");
    super.didChangeDependencies();
    // // updateFromJSON();
    // print('ОЧИСТКА');
    // updateFromJSON();
    setState(() {});
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> updateFromJSON() async {
    print('Start updateFromJSON...');

    await _initData();
  }

  Future<void> _fetchFromJSON() async {
    print('_fetchFromJSON...');
    String path = '/storage/emulated/0/Android/data/com.example.merlin/files/';
    List<FileSystemEntity> files = Directory(path).listSync();
    int length = books.length;
    int index = 0;
    for (FileSystemEntity file in files) {
      if (file is File) {
        if (index > length) {
          return;
        } else {
          String content = await file.readAsString();
          Map<String, dynamic> jsonMap = jsonDecode(content);

          if (jsonMap['customTitle'] != books[index].customTitle) {
            books[index].customTitle = jsonMap['customTitle'];
            print('Updating customTitle...');
          }
          if (jsonMap['author'] != books[index].author) {
            books[index].author = jsonMap['author'];
            print('Updating author...');
          }
          if (jsonMap['progress'] != books[index].progress) {
            print('Updating progress...');
            print('Inside Book ${books[index].progress}');
            print('Inside JSON ${jsonMap['progress']}');
            setState(() {
              books[index].progress = jsonMap['progress'];
            });
          }
        }
        index = index + 1;
      }
    }
    for (var item in books) {
      print('Book ${item.customTitle} = ${item.progress}');
    }
    setState(() {
      books;
    });
  }

  Future<void> _initData() async {
    print('Start _initData => processFiles');
    await processFiles();
    setState(() {});
  }

  Future<void> processFiles() async {
    print('Start processFiles...');
    String path = '/storage/emulated/0/Android/data/com.example.merlin/files/';

    List<FileSystemEntity> files = Directory(path).listSync();
    List<Future<Book>> futures = [];

    for (FileSystemEntity file in files) {
      if (file is File) {
        Future<Book> futureBook = _readBookFromFile(file);
        futures.add(futureBook);
      }
    }

    List<Book> loadedBooks = await Future.wait(futures);

    books.addAll(loadedBooks);

    print('Длина books ${books.length}');
  }

  Future<Book> _readBookFromFile(File file) async {
    try {
      String content = await file.readAsString();
      Map<String, dynamic> jsonMap = jsonDecode(content);
      Book book = Book.fromJson(jsonMap);
      return book;
    } catch (e) {
      print('Error reading file: $e');
      return Book(filePath: '', text: '', title: '', author: '', lastPosition: 0, imageBytes: null, progress: 0, customTitle: '');
    }
  }

  bool isSended = false;

  Future<void> sendFileTitle(String title) async {
    final prefs = await SharedPreferences.getInstance();
    bool success = await prefs.setString('fileTitle', title);
    if (success == true) {
      isSended = true;
    }
  }

  void showInputDialog(BuildContext context, String yourVariable, int index) {
    String updatedValue = "";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            title: Text(yourVariable == 'authorInput' ? 'Изменить автора' : 'Изменить название'),
            content: TextField(
              onChanged: (value) {
                updatedValue = value;
              },
            ),
            actions: <Widget>[
              TextButton(
                child: const TextForTable(
                  text: 'Отмена',
                  textColor: MyColors.black,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Сохранить', style: TextStyle(color: Colors.blue)),
                onPressed: () async {
                  if (updatedValue.isEmpty) {
                    Fluttertoast.showToast(
                      msg: 'Введите значение перед сохранением',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                  } else {
                    if (yourVariable == 'authorInput') {
                      await books[index].updateAuthorInFile(updatedValue);
                      await _fetchFromJSON();
                    } else if (yourVariable == 'bookNameInput') {
                      await books[index].updateTitleInFile(updatedValue);
                      await _fetchFromJSON();
                    }
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Offset _tapPosition = Offset.zero;

  void _getTapPosition(TapDownDetails tapPosition) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    setState(() {
      _tapPosition = renderBox.globalToLocal(tapPosition.globalPosition);
    });
  }

  bool checkBooks() {
    if (books.isNotEmpty) {
      return false;
    } else {
      return true;
    }
  }

  void _showBlurMenu(context, int index) async {
    final RenderObject? overlay = Overlay.of(context).context.findRenderObject();
    final result = await showMenu(
      context: context,
      color: const Color.fromARGB(255, 73, 73, 73).withAlpha(200),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      position: RelativeRect.fromRect(
        Rect.fromLTWH(
          _tapPosition.dx,
          _tapPosition.dy,
          10,
          10,
        ),
        Rect.fromLTWH(
          0,
          0,
          overlay!.paintBounds.size.width,
          overlay.paintBounds.size.height,
        ),
      ),
      items: [
        const PopupMenuItem(
          value: 'change-author',
          child: Text(
            "Изменить автора",
            style: TextStyle(color: MyColors.white, fontSize: 13),
          ),
        ),
        const PopupMenuItem(
          value: 'change-title',
          child: Text(
            "Изменить название",
            style: TextStyle(color: MyColors.white, fontSize: 13),
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Text(
            "Удалить",
            style: TextStyle(color: Colors.red, fontSize: 13),
          ),
        ),
      ],
    );

    switch (result) {
      case 'change-author':
        showInputDialog(context, 'authorInput', index);
        break;
      case 'change-title':
        showInputDialog(context, 'bookNameInput', index);
        break;
      case 'delete':
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                title: Text(books[index].customTitle),
                content: const Text("Вы уверены, что хотите удалить книгу?"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const TextForTable(
                      text: "Отмена",
                      textColor: MyColors.black,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      books[index].deleteFileByTitle(books[index].title);
                      books.removeAt(index);
                      setState(() {});
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      "Удалить",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );
          },
        );
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    double bookWidth = MediaQuery.of(context).size.shortestSide > 600 ? 150 * 1.5 : 150;
    double bookHeight = MediaQuery.of(context).size.shortestSide > 600 ? 230 * 1.5 : 230;
    int booksInWidth = ((MediaQuery.of(context).size.width - 2 * 18 + 10) / (bookWidth + 10)).floor();
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 20, 24, 16),
              child: Text24(
                text: "Последнее",
                textColor: MyColors.black,
              ),
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [if (books.isEmpty) TextTektur(text: "Пока вы не добавили никаких книг", fontsize: 16, textColor: MyColors.grey)],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 72),
              child: OrientationBuilder(builder: (context, orientation) {
                return DynamicHeightGridView(
                  controller: _scrollController,
                  itemCount: books.length,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  crossAxisCount: booksInWidth,
                  builder: (ctx, index) {
                    return GestureDetector(
                      onTap: () async {
                        if (!_isOperationInProgress) {
                          _isOperationInProgress = true;
                          try {
                            await sendFileTitle(books[index].title);
                            if (isSended) {
                              isSended = false;
                              // await Navigator.pushNamed(context, RouteNames.reader);
                              Navigator.of(context).pushNamed(RouteNames.reader).then((value) async => await _fetchFromJSON());
                            }
                          } catch (e) {
                            // Обработка ошибок, если необходимо
                          } finally {
                            _isOperationInProgress = false;
                            // if (mounted) setState(() {});
                          }
                        }
                      },
                      onTapDown: (position) {
                        _getTapPosition(position);
                      },
                      onLongPress: () {
                        // onTapLongPressOne(context, index);
                        _showBlurMenu(context, index);
                      },
                      child: Column(
                        children: [
                          if (books[index].imageBytes != null)
                            Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                books[index].imageBytes?.first != 0
                                    ? Image.memory(
                                        books[index].imageBytes!,
                                        width: bookWidth,
                                        height: bookHeight,
                                        fit: BoxFit.fill,
                                      )
                                    : SvgPicture.asset(
                                        'assets/icon/no_name_book.svg',
                                        width: bookWidth,
                                        height: bookHeight,
                                        fit: BoxFit.fitHeight,
                                      ),
                                Positioned.fill(
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                            Colors.black.withOpacity(0.8),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                    bottom: 10,
                                    left: 10,
                                    right: 10,
                                    child: LinearProgressIndicator(
                                      minHeight: 4,
                                      value: books[index].progress,
                                      backgroundColor: Colors.white,
                                      valueColor: const AlwaysStoppedAnimation<Color>(MyColors.purple),
                                    )),
                              ],
                            ),
                          const SizedBox(height: 4),
                          Text(books[index].author.length > 15
                              ? '${books[index].author.substring(0, books[index].author.length ~/ 1.5)}...'
                              : books[index].author),
                          Text(
                            books[index].customTitle.length > 20
                                ? books[index].customTitle.length > 15
                                    ? '${books[index].customTitle.substring(0, books[index].customTitle.length ~/ 2.5)}...'
                                    : '${books[index].customTitle.substring(0, books[index].customTitle.length ~/ 2)}...'
                                : books[index].customTitle,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
