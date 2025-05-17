import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:merlin/UI/router.dart';
import 'package:merlin/UI/theme/theme.dart';
import 'package:merlin/components/books_page_header.dart';
import 'package:merlin/components/button/button.dart';
import 'package:merlin/domain/books_repository.dart';
import 'package:merlin/domain/scan_books_task.dart';
import 'package:merlin/domain/workmanager.dart';
import 'package:merlin/functions/book.dart';
import 'package:merlin/functions/recent_book.dart';
import 'package:merlin/pages/books/book_item.dart';
import 'package:merlin/pages/recent/bookloader.dart';
import 'package:merlin/style/colors.dart';
import 'package:merlin/style/text.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

class BooksPage extends StatefulWidget {
  const BooksPage({super.key});

  @override
  State<BooksPage> createState() => BooksPageState();
}

class BooksPageState extends State<BooksPage> {
  final BooksRepository _booksRepo = BooksRepository();
  final BookLoader imageLoader = BookLoader();
  final ScrollController _scrollController = ScrollController();
  Uint8List? imageBytes;
  List<ImageInfo> images = [];
  List<BookItem> books = [];
  List<BookItem> _booksFiltered = [];
  String? firstName;
  String? lastName;
  String? name;
  String? title;
  bool _isOperationInProgress = false;
  bool _isStoragePermissionGranted = true;
  StreamSubscription? _wmStreamSubscription;
  bool _isLoadingBooksProgress = true;
  bool _isScanningBooksProgress = false;
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

    _wmStreamSubscription = wmScanBooksStream?.listen((stateIndex) async {
      final state = ScanBooksTaskState.values[stateIndex];
      switch (state) {
        case ScanBooksTaskState.inProgress:
          setState(() {
            _isScanningBooksProgress = true;
          });
        case ScanBooksTaskState.completed:
          _isScanningBooksProgress = false;
          if (!_isLoadingBooksProgress) {
            if (books.isEmpty) {
              await _initData();
            } else {
              await _fetchFromJSON();
            }
          }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final isGranted = await _checkStoragePermissionGranted();
      setState(() {
        _isStoragePermissionGranted = isGranted;
      });
      if (mounted && !isGranted) {
        final result = await showDialog<bool>(
            context: context,
            builder: (context) => const _StoragePermissionDialog());
        if (result == true) {
          final isGranted = await _requestStoragePermission();
          if (isGranted) {
            Workmanager().registerOneOffTask(
                ScanBooksTask.oneOffTaskId, ScanBooksTask.name,
                existingWorkPolicy: ExistingWorkPolicy.replace);
          }
          setState(() {
            _isStoragePermissionGranted = isGranted;
          });
        }
      }

      await _initData();
    });

    super.initState();
  }

  Future<Permission> _getStoragePermission() async {
    if (Platform.isAndroid) {
      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      final AndroidDeviceInfo info = await deviceInfoPlugin.androidInfo;
      if ((info.version.sdkInt) >= 33) {
        return Permission.manageExternalStorage;
      } else {
        return Permission.storage;
      }
    } else {
      return Permission.storage;
    }
  }

  Future<bool> _checkStoragePermissionGranted() async {
    final permission = await _getStoragePermission();
    switch (await permission.status) {
      case PermissionStatus.denied:
        return false;
      case PermissionStatus.granted:
        return true;
      case PermissionStatus.restricted:
        return false;
      case PermissionStatus.limited:
        return true;
      case PermissionStatus.permanentlyDenied:
        return false;
      case PermissionStatus.provisional:
        return true;
    }
  }

  Future<bool> _requestStoragePermission() async {
    final permission = await _getStoragePermission();
    final status = await permission.request();

    switch (status) {
      case PermissionStatus.denied:
        return false;
      case PermissionStatus.granted:
        return true;
      case PermissionStatus.restricted:
        return false;
      case PermissionStatus.limited:
        return true;
      case PermissionStatus.permanentlyDenied:
        return false;
      case PermissionStatus.provisional:
        return true;
    }
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
    _wmStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchFromJSON() {
    // print('_fetchFromJSON...');
    return Future.delayed(const Duration(milliseconds: 200), () async {
      final Directory? externalDir = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationDocumentsDirectory();
      final String path = '${externalDir?.path}/books';
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
    final str = prefs.getString("booksSort");
    if (str == null) {
      _selectedSort = BooksSort.dateAddedDesc;
    } else {
      _selectedSort = BooksSort.fromString(str);
    }

    try {
      await processFiles();
    } finally {
      setState(() => _isLoadingBooksProgress = false);
    }
  }

  Future<void> processFiles() async {
    final Directory? externalDir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    final String path = '${externalDir?.path}/books';
    final Directory booksDir = Directory(path);

    // Проверяем, существует ли уже директория, если нет - создаем
    if (!await booksDir.exists()) {
      await booksDir.create(recursive: true);
    }

    List<FileSystemEntity> files = Directory(path).listSync();
    List<Future<BookItem>> futures = [];

    // print(files);
    for (FileSystemEntity file in files) {
      if (file is File) {
        final futureBook = _readBookFromFile(file);
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

  bool isSaved = false;

  Future<void> saveToRecent(String bookTitle) async {
    final prefs = await SharedPreferences.getInstance();
    bool success = await prefs.setString('fileTitle', bookTitle);
    if (success == true) {
      await _booksRepo.saveRecent(RecentBook(title: bookTitle));
      isSaved = true;
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
                      final title = _booksFiltered[index].title;
                      _booksFiltered[index].delete();
                      _booksFiltered.removeAt(index);
                      _deleteRecent(title);
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

  Future<void> _deleteRecent(String title) async {
    try {
      final book = await _booksRepo.getRecentByTitle(title);
      if (book != null) {
        await _booksRepo.deleteRecent(book);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Unable to delete recent book: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double bookWidth =
        MediaQuery.of(context).size.shortestSide > 600 ? 33 * 1.5 : 33;
    double bookHeight =
        MediaQuery.of(context).size.shortestSide > 600 ? 50 * 1.5 : 50;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            BooksPageHeader(
              title: "Книги",
              sort: _selectedSort,
              onSortChanged: (sort) async {
                _selectedSort = sort;
                _filterAndSort();
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString("booksSort", sort.name);
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
                  if (_booksFiltered.isEmpty)
                    if (_isLoadingBooksProgress || _isScanningBooksProgress)
                      const CircularProgressIndicator(
                        color: MyColors.purple,
                      )
                    else
                      TextTektur(
                          text: "Пока вы не добавили никаких книг",
                          fontsize: 16,
                          textColor: MyColors.grey)
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 72),
              child: OrientationBuilder(builder: (context, orientation) {
                return ListView.separated(
                  controller: _scrollController,
                  itemCount: _booksFiltered.length + 1,
                  separatorBuilder: (context, index) => const SizedBox(
                    height: 8.0,
                  ),
                  itemBuilder: (ctx, index) {
                    if (index == 0) {
                      if (_isStoragePermissionGranted) {
                        return const SizedBox.shrink();
                      } else {
                        return _RequestPermissionButton(onClick: () async {
                          await _requestStoragePermission();
                          final isGranted =
                              await _checkStoragePermissionGranted();
                          if (isGranted) {
                            Workmanager().registerOneOffTask(
                                ScanBooksTask.oneOffTaskId, ScanBooksTask.name,
                                existingWorkPolicy: ExistingWorkPolicy.replace);
                          }
                          setState(() {
                            _isStoragePermissionGranted = isGranted;
                          });
                        });
                      }
                    } else {
                      index = index - 1;
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () async {
                          if (!_isOperationInProgress) {
                            _isOperationInProgress = true;
                            try {
                              await saveToRecent(_booksFiltered[index].title);
                              if (isSaved) {
                                isSaved = false;
                                // ignore: use_build_context_synchronously
                                Navigator.of(context)
                                    .pushNamed(RouteNames.reader)
                                    .then((value) async =>
                                        await _fetchFromJSON());
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
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _booksFiltered[index].customTitle.length >
                                              40
                                          ? _booksFiltered[index]
                                                      .customTitle
                                                      .length >
                                                  20
                                              ? '${_booksFiltered[index].customTitle.substring(0, _booksFiltered[index].customTitle.length ~/ 2.5)}...'
                                              : '${_booksFiltered[index].customTitle.substring(0, _booksFiltered[index].customTitle.length ~/ 2)}...'
                                          : _booksFiltered[index].customTitle,
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      _booksFiltered[index].author.length > 15
                                          ? '${_booksFiltered[index].author.substring(0, _booksFiltered[index].author.length ~/ 1.5)}...'
                                          : _booksFiltered[index].author,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    if (_booksFiltered[index].sequence !=
                                        null) ...[
                                      const SizedBox(height: 8.0),
                                      _Sequence(
                                          sequence:
                                              _booksFiltered[index].sequence!)
                                    ],
                                    const SizedBox(height: 8.0),
                                    _TypeAndSize(
                                      book: _booksFiltered[index],
                                    ),
                                    const SizedBox(height: 8.0),
                                    LinearProgressIndicator(
                                      minHeight: 4,
                                      value: _booksFiltered[index].progress,
                                      backgroundColor: MyColors.lightGray,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                              MyColors.purple),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    }
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

class _Sequence extends StatelessWidget {
  final BookSequence sequence;

  const _Sequence({required this.sequence});

  @override
  Widget build(BuildContext context) {
    final BookSequence(:name, :number) = sequence;
    final nameFormated = name.length > 40
        ? name.length > 20
            ? '${name.substring(0, name.length ~/ 2.5)}...'
            : '${name.substring(0, name.length ~/ 2)}...'
        : name;
    return Text(number == null ? nameFormated : '$nameFormated №$number',
        maxLines: 1,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall);
  }
}

class _TypeAndSize extends StatelessWidget {
  final BookItem book;

  const _TypeAndSize({required this.book});

  @override
  Widget build(BuildContext context) {
    return Text('${book.bookTypeName}, ${getFileSizeStr(book.fileSize, 1)}',
        maxLines: 1,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall);
  }

  String getFileSizeStr(int bytes, int decimals) {
    if (bytes <= 0) {
      return "0 Б";
    }
    const suffixes = ["Б", "КБ", "МБ", "ГБ", "ТБ", "ПБ", "ЭБ", "ЗБ", "ЙБ"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }
}

class _RequestPermissionButton extends StatelessWidget {
  const _RequestPermissionButton({required this.onClick});

  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: grayButton(),
        child: Button(
          text: 'Запросить разрешение на чтение',
          width: 320,
          height: 48,
          horizontalPadding: 62,
          verticalPadding: 12,
          textColor: MyColors.black,
          fontSize: 14,
          onPressed: onClick,
          fontWeight: FontWeight.bold,
        ));
  }
}

class _StoragePermissionDialog extends StatelessWidget {
  const _StoragePermissionDialog();

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: AlertDialog(
        title: const Text("Предоставьте разрешение"),
        content: const Text(
          """Чтобы добавлять ваши книги в приложение автоматически, необходимо дать доступ для чтения фалов на устройстве.

Вы можете дать разрешение позже в разделе Книги.""",
        ),
        actions: <Widget>[
          TextButton(
            child: const TextForTable(
              text: 'Позже',
              textColor: MyColors.black,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Ок', style: TextStyle(color: Colors.blue)),
            onPressed: () async {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
    );
  }
}
