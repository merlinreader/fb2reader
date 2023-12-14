import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:merlin/UI/router.dart';
import 'package:merlin/style/text.dart';
import 'package:merlin/style/colors.dart';
import 'package:merlin/pages/recent/imageloader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart';

// для получаения картинки из файла книги
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
      ],
    );
    super.initState();

    getDataFromLocalStorage('booksKey');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getDataFromLocalStorage('booksKey');
  }

  @override
  void didUpdateWidget(RecentPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    getDataFromLocalStorage('booksKey');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> getDataFromLocalStorage(String key) async {
    final prefs = await SharedPreferences.getInstance();
    String? imageDataJson = prefs.getString(key);
    if (imageDataJson != null) {
      images = (jsonDecode(imageDataJson) as List).map((item) => ImageInfo.fromJson(item)).toList();
      setState(() {});
    }
    setState(() {});
  }

  Future<void> delDataFromLocalStorage(String key, String path) async {
    final prefs = await SharedPreferences.getInstance();
    String? imageDataToAdd = prefs.getString(key);
    List<ImageInfo> imageDatas = [];
    if (imageDataToAdd != null) {
      imageDatas = (jsonDecode(imageDataToAdd) as List).map((item) => ImageInfo.fromJson(item)).toList();
      imageDatas.removeWhere((element) => element.fileName == path);
      String imageDatasString = jsonEncode(imageDatas);
      await prefs.setString(key, imageDatasString);
      setState(() {});
    }
  }

  Future<void> delTextFromLocalStorage(String key, String path) async {
    final prefs = await SharedPreferences.getInstance();
    String? imageDataToAdd = prefs.getString(key);
    List<BookInfo> imageDatas = [];

    if (imageDataToAdd != null) {
      imageDatas = (jsonDecode(imageDataToAdd) as List).map((item) => BookInfo.fromJson(item)).toList();

      // Сначала устанавливаем позицию 0 для книги, которую удаляем
      for (var bookInfo in imageDatas) {
        if (bookInfo.filePath == path) {
          bookInfo.setPosZero();
          break;
        }
      }

      imageDatas.removeWhere((element) => element.filePath == path);
      String imageDatasString = jsonEncode(imageDatas);
      await prefs.setString(key, imageDatasString);

      // Обновляем информацию о позиции в кеше
      await Reader().resetPositionForBook(path);

      setState(() {});
    }
  }

  bool isSended = false;

  Future<void> sendDataFromLocalStorage(String key, int index) async {
    List text = [];
    List<BookInfo> bookDatas = [];
    String fileContent = await File(images[index].fileName).readAsString();
    XmlDocument document = XmlDocument.parse(fileContent);
    final Iterable<XmlElement> textInfo = document.findAllElements('body');
    for (var element in textInfo) {
      text.add(element.innerText.replaceAll(RegExp(r'\[.*?\]'), ''));
    }
    BookInfo bookData = BookInfo(
        filePath: images[index].fileName, fileText: text.toString(), title: images[index].title, author: images[index].author, lastPosition: 0);
    bookDatas.add(bookData);
    String textDataString = jsonEncode(bookDatas);

    final prefs = await SharedPreferences.getInstance();
    bool success = await prefs.setString(key, textDataString);
    if (success == true) {
      isSended = true;
    }
  }

  Future<void> changeDataFromLocalStorage(String key, String path, String changeField, String updatedValue) async {
    final prefs = await SharedPreferences.getInstance();
    String? imageDataToAdd = prefs.getString('booksKey');
    List<ImageInfo> imageDatas = [];
    if (imageDataToAdd != null) {
      imageDatas = (jsonDecode(imageDataToAdd) as List).map((item) => ImageInfo.fromJson(item)).toList();
      var index = imageDatas.indexWhere((element) => element.fileName.startsWith(path));
      if (changeField == 'author') {
        imageDatas[index].author = updatedValue;
      } else if (changeField == 'title') {
        imageDatas[index].title = updatedValue;
      }

      String imageDatasString = jsonEncode(imageDatas);
      await prefs.setString('booksKey', imageDatasString);
      setState(() {});
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
                onPressed: () {
                  if (updatedValue.isEmpty) {
                    Fluttertoast.showToast(
                      msg: 'Введите значение перед сохранением',
                      toastLength: Toast.LENGTH_SHORT, // Длительность отображения
                      gravity: ToastGravity.BOTTOM, // Расположение уведомления
                    );
                  } else {
                    if (yourVariable == 'authorInput') {
                      changeDataFromLocalStorage('booksKey', images[index].fileName, 'author', updatedValue);
                      images[index].author = updatedValue;
                      setState(() {
                        images[index].author = updatedValue;
                      });
                    } else if (yourVariable == 'bookNameInput') {
                      changeDataFromLocalStorage('booksKey', images[index].fileName, 'title', updatedValue);
                      images[index].title = updatedValue;
                      setState(() {
                        images[index].title = updatedValue;
                      });
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

  void onTapLongPressOne(BuildContext context, int index) {
    // Создание окна с кнопками и текстом
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            title: const Text(
              "Действия",
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    showInputDialog(context, 'authorInput', index);
                  },
                  child: const TextForTable(
                    text: "Изменить автора",
                    textColor: MyColors.black,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    showInputDialog(context, 'bookNameInput', index);
                  },
                  child: const TextForTable(
                    text: "Изменить название",
                    textColor: MyColors.black,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: AlertDialog(
                            title: Text(images[index].title),
                            content: const Text("Вы уверены, что хотите удалить книгу?"),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // Закрыть диалоговое окно
                                },
                                child: const TextForTable(
                                  text: "Отмена",
                                  textColor: MyColors.black,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Выполните удаление элемента
                                  delDataFromLocalStorage('booksKey', images[index].fileName);
                                  delTextFromLocalStorage('textKey', images[index].fileName);
                                  images.removeAt(index);
                                  setState(() {});
                                  Navigator.of(context).pop(); // Закрыть диалоговое окно
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
                  },
                  child: const Text(
                    "Удалить",
                    style: TextStyle(color: Colors.red),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  bool checkImages() {
    if (images.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  Offset _tapPosition = Offset.zero;

  void _getTapPosition(TapDownDetails tapPosition) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    setState(() {
      _tapPosition = renderBox.globalToLocal(tapPosition.globalPosition);
    });
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
                title: Text(images[index].title),
                content: const Text("Вы уверены, что хотите удалить книгу?"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Закрыть диалоговое окно
                    },
                    child: const TextForTable(
                      text: "Отмена",
                      textColor: MyColors.black,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Выполните удаление элемента
                      delDataFromLocalStorage('booksKey', images[index].fileName);
                      delTextFromLocalStorage('textKey', images[index].fileName);
                      images.removeAt(index);
                      setState(() {});
                      Navigator.of(context).pop(); // Закрыть диалоговое окно
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
    return Scaffold(
      body: Stack(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 20, 24, 16),
            child: Text24(
              text: "Последнее",
              textColor: MyColors.black,
              //fontWeight: FontWeight.w600,
            ),
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [if (images.isEmpty) TextTektur(text: "Пока вы не добавили никаких книг", fontsize: 16, textColor: MyColors.grey)],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 72),
            child: OrientationBuilder(builder: (context, orientation) {
              return DynamicHeightGridView(
                controller: _scrollController,
                itemCount: images.length,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                crossAxisCount: orientation == Orientation.portrait ? 2 : 5,
                builder: (ctx, index) {
                  return GestureDetector(
                    onTap: () async {
                      if (!_isOperationInProgress) {
                        _isOperationInProgress = true;
                        try {
                          await sendDataFromLocalStorage('textKey', index);
                          if (isSended) {
                            isSended = false;
                            await Navigator.pushNamed(context, RouteNames.reader).then((_) {
                              getDataFromLocalStorage('booksKey');
                            });
                          }
                        } catch (e) {
                          // Обработка ошибок, если необходимо
                        } finally {
                          _isOperationInProgress = false;
                          getDataFromLocalStorage('booksKey');
                          if (mounted) setState(() {});
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
                        if (images[index].imageBytes != null)
                          Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              images[index].imageBytes?.first != 0
                                  ? Image.memory(
                                      images[index].imageBytes!,
                                      width: orientation == Orientation.portrait
                                          ? MediaQuery.of(context).size.width / 2.5
                                          : MediaQuery.of(context).size.width / 6.6,
                                      height: orientation == Orientation.portrait
                                          ? MediaQuery.of(context).size.height / 3.3
                                          : MediaQuery.of(context).size.height / 2,
                                      fit: BoxFit.fill,
                                    )
                                  : SvgPicture.asset(
                                      'assets/icon/no_name_book.svg',
                                      width: orientation == Orientation.portrait
                                          ? MediaQuery.of(context).size.width / 2.5
                                          : MediaQuery.of(context).size.width / 6.6,
                                      height: orientation == Orientation.portrait
                                          ? MediaQuery.of(context).size.height / 3.3
                                          : MediaQuery.of(context).size.height / 2,
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
                                child: Container(
                                  height: 4,
                                  decoration: const BoxDecoration(
                                    color: MyColors.white,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: images[index].progress * 100 >= 99.9
                                            ? MediaQuery.of(context).size.width / 2.846
                                            : MediaQuery.of(context).size.width / 2.85 * images[index].progress,
                                        height: 4,
                                        decoration: const BoxDecoration(color: MyColors.purple),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 4),
                        Text(images[index].author.length > 20 ? '${images[index].author.substring(0, 20)}...' : images[index].author),
                        Text(
                          images[index].title.length > 20 ? '${images[index].title.substring(0, 20)}...' : images[index].title,
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
    );
  }
}
