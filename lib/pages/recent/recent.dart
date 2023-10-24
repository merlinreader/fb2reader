import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
//import 'package:merlin/components/navbar/navbar.dart';
import 'package:merlin/style/text.dart';
import 'package:merlin/style/colors.dart';
import 'package:merlin/UI/icon/custom_icon.dart';
import 'package:merlin/pages/recent/imageloader.dart';
import 'package:shared_preferences/shared_preferences.dart';

// для получаения картинки из файла книги
import 'package:xml/xml.dart';
import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Recent extends StatelessWidget {
  const Recent({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: RecentPage(),
    );
  }
}

class RecentPage extends StatefulWidget {
  const RecentPage({super.key});
  @override
  State<RecentPage> createState() => RecentPageState();
}

// class ImageInfo {
//   Uint8List? imageBytes;
//   String title;
//   String author;

//   ImageInfo({this.imageBytes, required this.title, required this.author});
// }

class ImageInfo {
  Uint8List? imageBytes;
  String title;
  String author;

  ImageInfo({this.imageBytes, required this.title, required this.author});

  Map<String, dynamic> toJson() {
    return {
      'imageBytes': imageBytes,
      'title': title,
      'author': author,
    };
  }

  factory ImageInfo.fromJson(Map<String, dynamic> json) {
    return ImageInfo(
      imageBytes: Uint8List.fromList(List<int>.from(json['imageBytes'])),
      title: json['title'],
      author: json['author'],
    );
  }
}

Future<void> requestPermission() async {
  PermissionStatus status = await Permission.manageExternalStorage.status;
  if (!status.isGranted) {
    status = await Permission.manageExternalStorage.request();
    if (!status.isGranted) {
      openAppSettings();
    }
  }
}

class RecentPageState extends State<RecentPage> {
  final ImageLoader imageLoader = ImageLoader();
  final ScrollController _scrollController = ScrollController();
  bool _isVisible = false;
  Uint8List? imageBytes;
  List<ImageInfo> images = [];
  String? firstName;
  String? lastName;
  String? name;
  String? title;

  void showImage(Uint8List? imageBytes, String title, String author) {
    print("recent: showImage started");
    // setState(() {
    //   images
    //       .add(ImageInfo(imageBytes: imageBytes, title: title, author: author));
    // });
    print("recent: showImage done");
    print(images);
  }

  @override
  void initState() {
    super.initState();

    getDataFromLocalStorage('booksKey');

    _scrollController.addListener(() {
      setState(() {
        _isVisible = _scrollController.position.userScrollDirection ==
            ScrollDirection.reverse;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // void testStorage() async {
  //   String data = await getDataFromLocalStorage('booksKey');
  //   print(data); // Выведет "Hello, World!"
  // }

  Future<void> getDataFromLocalStorage(String key) async {
    final prefs = await SharedPreferences.getInstance();
    String? imageDataJson = prefs.getString(key);
    if (imageDataJson != null) {
      ImageInfo imageData = ImageInfo.fromJson(json.decode(imageDataJson));
      print(
          'recent: imageData.imageBytes.length: ${imageData.imageBytes?.length}');
      print('recent: imageData.author: "${imageData.author}"');
      print('recent: imageData.title: "${imageData.title}"');

      images.add(ImageInfo(
          imageBytes: imageData.imageBytes,
          title: imageData.title,
          author: imageData.author));
      setState(() {});
    }
  }

  Future<void> loadImage() async {
    await requestPermission();
    // Выбор файла fb2
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      // Получение пути к файлу и чтение его содержимого
      String path = result.files.single.path!;
      String fileContent = await File(path).readAsString();

      // Парсинг файла и поиск тегов <binary>
      XmlDocument document = XmlDocument.parse(fileContent);
      final XmlElement binaryInfo = document.findAllElements('binary').first;
      final String binary = binaryInfo.text;
      final String cleanedBinary = binary.replaceAll(RegExp(r"\s+"), "");

      // Декодирование base64 в байты изображения
      Uint8List decodedBytes = base64.decode(cleanedBinary);

      try {
        final XmlElement titleInfo =
            document.findAllElements('title-info').first;
        final XmlElement titleInfoTag =
            titleInfo.findElements('book-title').first;
        final String titleFromInfo = titleInfoTag.text;
        title = titleFromInfo;
      } catch (e) {
        print('Произошла ошибка: нет названия: $e');
        title = "Название не найдено";
      }

      try {
        final XmlElement authorInfo = document.findAllElements('author').first;
        final XmlElement firstNameInfo =
            authorInfo.findElements('first-name').first;
        final String firstNameFromInfo = firstNameInfo.text;

        final XmlElement lastNameInfo =
            authorInfo.findElements('last-name').first;
        final String lastNameFromInfo = lastNameInfo.text;
        firstName = firstNameFromInfo;
        lastName = lastNameFromInfo;
        name = '$firstNameFromInfo $lastNameFromInfo';
      } catch (e) {
        print('Произошла ошибка: нет автора: $e');
        name = "Автор не найден";
      }

      setState(() {
        images.add(ImageInfo(
            imageBytes: decodedBytes,
            title: title as String,
            author: name as String));
      });
    }
  }

  void showInputDialog(BuildContext context, String yourVariable, int index) {
    String updatedValue = "";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
                    toastLength: Toast.LENGTH_SHORT, // Длительность отображения
                    gravity: ToastGravity.BOTTOM, // Расположение уведомления
                  );
                } else {
                  if (yourVariable == 'authorInput') {
                    images[index].author = updatedValue;
                    setState(() {
                      images[index].author = updatedValue;
                    });
                  } else if (yourVariable == 'bookNameInput') {
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
        );
      },
    );
  }

  void onTapLongPressOne(BuildContext context, int index) {
    // Создание окна с кнопками и текстом
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
                      return AlertDialog(
                        title: Text(images[index].title),
                        content:
                            const Text("Вы уверены, что хотите удалить книгу?"),
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
                24, 28, 24, 0), // Верхний отступ 0
            child: TextTektur(
              text: "Последнее",
              fontsize: 32,
              textColor: MyColors.black,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: 100), // Верхний отступ для DynamicHeightGridView
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
                        Image.memory(images[index].imageBytes!,
                            width: MediaQuery.of(context).size.width / 2.5,
                            fit: BoxFit.fitHeight),
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
      floatingActionButton: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: _isVisible ? 0.0 : 1.0,
        child: FloatingActionButton(
          onPressed: loadImage,
          backgroundColor: MyColors.purple,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.zero)),
          autofocus: true,
          child: const Icon(CustomIcons.bookOpen),
        ),
      ),
    );
  }
}
