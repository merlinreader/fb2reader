import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:merlin/UI/router.dart';
import 'package:merlin/components/books_page_header.dart';
import 'package:merlin/domain/books_repository.dart';
import 'package:merlin/functions/book.dart';
import 'package:merlin/functions/recent_book.dart';
import 'package:merlin/pages/books/book_item.dart';
import 'package:merlin/pages/recent/bookloader.dart';
import 'package:merlin/style/colors.dart';
import 'package:merlin/style/text.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecentPage extends StatefulWidget {
  const RecentPage({super.key});

  @override
  State<RecentPage> createState() => RecentPageState();
}

class RecentPageState extends State<RecentPage> {
  final BooksRepository _booksRepo = BooksRepository();
  final BookLoader imageLoader = BookLoader();
  final ScrollController _scrollController = ScrollController();
  Uint8List? imageBytes;
  List<ImageInfo> images = [];
  List<BookItem> books = [];
  List<BookItem> _booksFiltered = [];
  List<RecentBook> recentBooksInfo = [];
  String? firstName;
  String? lastName;
  String? name;
  String? title;
  bool _isOperationInProgress = false;
  bool _isLoadingBooksProgress = true;
  String? _searchQuery;
  BooksSort _selectedSort = BooksSort.dateAddedDesc;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [
        SystemUiOverlay.top,
        SystemUiOverlay.bottom,
      ],
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initData();
    });

    super.initState();
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

  Future<void> _fetchFromJSON() {
    // print('_fetchFromJSON...');
    return Future.delayed(const Duration(milliseconds: 200), () async {
      final recentBooks = await _booksRepo.getAllRecent();

      final Directory? externalDir = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationDocumentsDirectory();
      final String path = '${externalDir?.path}/books/';
      List<FileSystemEntity> files = Directory(path).listSync();

      int length = books.length;
      int index = 0;
      for (final recent in recentBooks) {
        final title = recent.title;
        String fileName = '$title.json';
        FileSystemEntity? file;
        try {
          file = files.firstWhere(
            (file) => file is File && file.uri.pathSegments.last == fileName,
          );
        } catch (e) {
          continue;
        }
        if (file is File && await file.exists()) {
          if (index > length) {
            return;
          } else {
            recentBooksInfo[index] = recent;

            String content = await file.readAsString();
            Map<String, dynamic> jsonMap = jsonDecode(content);

            if (jsonMap['customTitle'] != books[index].customTitle) {
              books[index].customTitle = jsonMap['customTitle'];
              // print('Updating customTitle...');
            }
            if (jsonMap['author'] != books[index].author) {
              books[index].author = jsonMap['author'];
              // print('Updating author...');
            }
            if (jsonMap['progress'] != books[index].progress) {
              // print('Updating progress...');
              // print('Inside Book ${books[index].progress}');
              // print('Inside JSON ${jsonMap['progress']}');
              setState(() {
                books[index].progress = jsonMap['progress'];
              });
            }
          }
          index = index + 1;
        }
      }

      _filterAndSort();
      setState(() {
        books;
      });
    });
  }

  Future<void> _initData() async {
    setState(() => _isLoadingBooksProgress = true);

    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString("booksRecentSort");
    if (str == null) {
      _selectedSort = BooksSort.dateAddedDesc;
    } else {
      _selectedSort = BooksSort.fromString(str);
    }

    try {
      await loadRecent();
    } finally {
      setState(() => _isLoadingBooksProgress = false);
    }
  }

  Future<void> loadRecent() async {
    final books = await _booksRepo.getAllRecent();
    await processFiles(books);
  }

  Future<void> processFiles(List<RecentBook> recentBooks) async {
    final Directory? externalDir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    final String path = '${externalDir?.path}/books/';
    final Directory booksDir = Directory(path);

    // Проверяем, существует ли уже директория, если нет - создаем
    if (!await booksDir.exists()) {
      await booksDir.create(recursive: true);
    }

    List<FileSystemEntity> files = booksDir.listSync();

    List<Future<BookItem>> futures = [];

    for (final recent in recentBooks) {
      recentBooksInfo.add(recent);

      final title = recent.title;
      String targetFileName = '$title.json';
      FileSystemEntity? targetFile;
      try {
        targetFile = files.firstWhere(
          (file) =>
              file is File && file.uri.pathSegments.last == targetFileName,
        );
      } catch (e) {
        continue;
      }
      if (targetFile is File && await targetFile.exists()) {
        final futureBook = _readBookFromFile(targetFile);
        futures.add(futureBook);
      }
    }

    final loadedBooks = await Future.wait(futures);

    books.addAll(loadedBooks);
    _filterAndSort();
  }

  Future<BookItem> _readBookFromFile(File file) async {
    try {
      String content = await file.readAsString();
      Map<String, dynamic> jsonMap = jsonDecode(content);
      final book = Book.fromJson(jsonMap);
      return BookItem(
          fileSize: await file.length(),
          filePath: book.filePath,
          text: book.text,
          title: book.title,
          customTitle: book.customTitle,
          author: book.author,
          lastPosition: book.lastPosition,
          sequence: book.sequence,
          imageBytes: book.imageBytes,
          progress: book.progress,
          lp: book.lp,
          version: book.version,
          dateAdded: book.dateAdded);
    } catch (e) {
      print('Error reading file: $e');
      return BookItem(
          fileSize: 0,
          filePath: '',
          text: '',
          title: '',
          author: '',
          lastPosition: 0,
          imageBytes: null,
          progress: 0,
          customTitle: '',
          sequence: null,
          dateAdded: DateTime.fromMillisecondsSinceEpoch(0));
    }
  }

  void _filterAndSort() {
    final query = _searchQuery?.toLowerCase();
    _booksFiltered =
        books.where((book) => book.filterByMetadata(query)).toList();
    _booksFiltered.sort((a, b) => _selectedSort.sort(a, b));
    setState(() {});
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
            title: Text(yourVariable == 'authorInput'
                ? 'Изменить автора'
                : 'Изменить название'),
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
                child: const Text('Сохранить',
                    style: TextStyle(color: Colors.blue)),
                onPressed: () async {
                  if (updatedValue.isEmpty) {
                    Fluttertoast.showToast(
                      msg: 'Введите значение перед сохранением',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                  } else {
                    if (yourVariable == 'authorInput') {
                      await _booksFiltered[index]
                          .updateAuthorInFile(updatedValue);
                      await _fetchFromJSON();
                    } else if (yourVariable == 'bookNameInput') {
                      await _booksFiltered[index]
                          .updateTitleInFile(updatedValue);
                      await _fetchFromJSON();
                    }
                    // ignore: use_build_context_synchronously
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
    if (_booksFiltered.isNotEmpty) {
      return false;
    } else {
      return true;
    }
  }

  void _showBlurMenu(context, int index) async {
    final RenderObject? overlay =
        Overlay.of(context).context.findRenderObject();
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
            "Удалить из последних",
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                title: Text(_booksFiltered[index].customTitle),
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
                      _booksRepo.deleteRecent(recentBooksInfo[index]);
                      _booksFiltered.removeAt(index);
                      recentBooksInfo.removeAt(index);
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
    double bookWidth =
        MediaQuery.of(context).size.shortestSide > 600 ? 150 * 1.5 : 150;
    double bookHeight =
        MediaQuery.of(context).size.shortestSide > 600 ? 230 * 1.5 : 230;
    int booksInWidth =
        ((MediaQuery.of(context).size.width - 2 * 18 + 10) / (bookWidth + 10))
            .floor();
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            BooksPageHeader(
              title: "Последнее",
              sort: _selectedSort,
              onSortChanged: (sort) async {
                _selectedSort = sort;
                _filterAndSort();
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString("booksRecentSort", sort.name);
              },
              onSearch: (query) {
                _searchQuery = query;
                _filterAndSort();
              },
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isLoadingBooksProgress)
                    const CircularProgressIndicator(
                      color: MyColors.purple,
                    ),
                  if (_booksFiltered.isEmpty && !_isLoadingBooksProgress)
                    if (_booksFiltered.isEmpty)
                      TextTektur(
                          text: "Пока вы не прочли никаких книг",
                          fontsize: 16,
                          textColor: MyColors.grey)
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 72),
              child: OrientationBuilder(builder: (context, orientation) {
                return DynamicHeightGridView(
                  controller: _scrollController,
                  itemCount: _booksFiltered.length,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 20,
                  crossAxisCount: booksInWidth,
                  builder: (ctx, index) {
                    return GestureDetector(
                      onTap: () async {
                        if (!_isOperationInProgress) {
                          _isOperationInProgress = true;
                          try {
                            await sendFileTitle(_booksFiltered[index].title);
                            if (isSended) {
                              isSended = false;
                              // ignore: use_build_context_synchronously
                              Navigator.of(context)
                                  .pushNamed(RouteNames.reader)
                                  .then(
                                      (value) async => await _fetchFromJSON());
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
                          if (_booksFiltered[index].imageBytes != null)
                            Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                _booksFiltered[index].imageBytes?.first != 0
                                    ? Image.memory(
                                        _booksFiltered[index].imageBytes!,
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
                                      value: _booksFiltered[index].progress,
                                      backgroundColor: Colors.white,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                              MyColors.purple),
                                    )),
                              ],
                            ),
                          const SizedBox(height: 4),
                          Text(
                            _booksFiltered[index].author.length > 15
                                ? '${_booksFiltered[index].author.substring(0, _booksFiltered[index].author.length ~/ 1.5)}...'
                                : _booksFiltered[index].author,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _booksFiltered[index].customTitle.length > 40
                                ? _booksFiltered[index].customTitle.length > 30
                                    ? '${_booksFiltered[index].customTitle.substring(0, _booksFiltered[index].customTitle.length ~/ 2.5)}...'
                                    : '${_booksFiltered[index].customTitle.substring(0, _booksFiltered[index].customTitle.length ~/ 2)}...'
                                : _booksFiltered[index].customTitle,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(height: 1.2),
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
