import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
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

  ImageInfo(
      {this.imageBytes,
      required this.title,
      required this.author,
      required this.fileName,
      required this.progress});

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

  @override
  void initState() {
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
      images = (jsonDecode(imageDataJson) as List)
          .map((item) => ImageInfo.fromJson(item))
          .toList();
      setState(() {});
    }
    setState(() {});
  }

  Future<void> delDataFromLocalStorage(String key, String path) async {
    final prefs = await SharedPreferences.getInstance();
    String? imageDataToAdd = prefs.getString(key);
    List<ImageInfo> imageDatas = [];
    if (imageDataToAdd != null) {
      imageDatas = (jsonDecode(imageDataToAdd) as List)
          .map((item) => ImageInfo.fromJson(item))
          .toList();
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
      imageDatas = (jsonDecode(imageDataToAdd) as List)
          .map((item) => BookInfo.fromJson(item))
          .toList();

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
        filePath: images[index].fileName,
        fileText: text.toString(),
        title: images[index].title,
        author: images[index].author,
        lastPosition: 0);
    bookDatas.add(bookData);
    String textDataString = jsonEncode(bookDatas);

    final prefs = await SharedPreferences.getInstance();
    bool success = await prefs.setString(key, textDataString);
    if (success == true) {
      isSended = true;
    }
  }

  Future<void> changeDataFromLocalStorage(
      String key, String path, String changeField, String updatedValue) async {
    final prefs = await SharedPreferences.getInstance();
    String? imageDataToAdd = prefs.getString('booksKey');
    List<ImageInfo> imageDatas = [];
    if (imageDataToAdd != null) {
      imageDatas = (jsonDecode(imageDataToAdd) as List)
          .map((item) => ImageInfo.fromJson(item))
          .toList();
      var index =
          imageDatas.indexWhere((element) => element.fileName.startsWith(path));
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
            title: const Text('Изменить значение'),
            content: TextField(
              onChanged: (value) {
                updatedValue = value;
              },
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Отмена'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Сохранить'),
                onPressed: () {
                  if (updatedValue.isEmpty) {
                    Fluttertoast.showToast(
                      msg: 'Введите значение перед сохранением',
                      toastLength:
                          Toast.LENGTH_SHORT, // Длительность отображения
                      gravity: ToastGravity.BOTTOM, // Расположение уведомления
                    );
                  } else {
                    if (yourVariable == 'authorInput') {
                      changeDataFromLocalStorage('booksKey',
                          images[index].fileName, 'author', updatedValue);
                      images[index].author = updatedValue;
                      setState(() {
                        images[index].author = updatedValue;
                      });
                    } else if (yourVariable == 'bookNameInput') {
                      changeDataFromLocalStorage('booksKey',
                          images[index].fileName, 'title', updatedValue);
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
            title: const Text("Действия"),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    showInputDialog(context, 'authorInput', index);
                  },
                  child: const Text("Изменить автора"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    showInputDialog(context, 'bookNameInput', index);
                  },
                  child: const Text("Изменить название"),
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
                            content: const Text(
                                "Вы уверены, что хотите удалить книгу?"),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Закрыть диалоговое окно
                                },
                                child: const Text("Отмена"),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Выполните удаление элемента
                                  delDataFromLocalStorage(
                                      'booksKey', images[index].fileName);
                                  delTextFromLocalStorage(
                                      'textKey', images[index].fileName);
                                  images.removeAt(index);
                                  setState(() {});
                                  Navigator.of(context)
                                      .pop(); // Закрыть диалоговое окно
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
              children: [
                if (images.isEmpty)
                  TextTektur(
                      text: "Пока вы не добавили никаких книг",
                      fontsize: 16,
                      textColor: MyColors.grey)
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: 72), // Верхний отступ для DynamicHeightGridView
            child: DynamicHeightGridView(
              controller: _scrollController,
              itemCount: images.length,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: 2,
              builder: (ctx, index) {
                return GestureDetector(
                  onLongPress: () {
                    onTapLongPressOne(context, index);
                  },
                  child: Column(
                    children: [
                      if (images[index].imageBytes != null)
                        GestureDetector(
                            onTap: () async {
                              await sendDataFromLocalStorage('textKey', index);
                              if (isSended) {
                                isSended = false;
                                // ignore: use_build_context_synchronously
                                Navigator.pushNamed(context, RouteNames.reader);
                              } else {
                                Fluttertoast.showToast(
                                  msg: 'Ошибка загрузки книги',
                                  toastLength: Toast
                                      .LENGTH_SHORT, // Длительность отображения
                                  gravity: ToastGravity
                                      .BOTTOM, // Расположение уведомления
                                );
                                return;
                              }
                            },
                            child: Column(
                              children: [
                                Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    Image.memory(
                                      images[index].imageBytes!,
                                      width: MediaQuery.of(context).size.width /
                                          2.5,
                                      fit: BoxFit.fitHeight,
                                    ),
                                    Positioned.fill(
                                      child: Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                          height: 50, // Высота виньетки
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
                                              width: images[index].progress *
                                                          100 >=
                                                      99.9
                                                  ? MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      2.846
                                                  : MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      2.85 *
                                                      images[index].progress,
                                              height: 4,
                                              decoration: const BoxDecoration(
                                                  color: MyColors.purple),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )),
                      const SizedBox(height: 4),
                      Text(images[index].author.length > 20
                          ? '${images[index].author.substring(0, 20)}...'
                          : images[index].author),
                      Text(
                        images[index].title.length > 20
                            ? '${images[index].title.substring(0, 20)}...'
                            : images[index].title,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
