import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:merlin/style/text.dart';
import 'package:merlin/style/colors.dart';
import 'package:merlin/UI/icon/custom_icon.dart';
import 'package:path_provider/path_provider.dart';

// для получаения картинки из файла книги
import 'package:xml/xml.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

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
  State<RecentPage> createState() => _RecentPage();
}

class _RecentPage extends State<RecentPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isVisible = true;
  String? firstName;
  String? lastName;
  String? name;
  String? title;
  String? base64Image;
  String? cachedImagePath;
  Uint8List? _cachedImageBytes;

  @override
  void initState() {
    super.initState();

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

  void showInputDialogTitle(BuildContext context, String yourVariable) {
    String updatedValue = yourVariable; // Создаем копию переменной для ввода

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Изменить значение'),
          content: TextField(
            onChanged: (value) {
              updatedValue =
                  value; // Обновляем копию значения при изменении текста
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Отмена'),
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Закрываем диалоговое окно без сохранения изменений
              },
            ),
            TextButton(
              child: const Text('Сохранить'),
              onPressed: () {
                setState(() {
                  yourVariable = updatedValue; // Сохраняем измененное значение
                });
                updateTitle(updatedValue);
                Navigator.of(context).pop(); // Закрываем диалоговое окно
              },
            ),
          ],
        );
      },
    );
  }

  void showInputDialogName(BuildContext context, String yourVariable) {
    String updatedValue = yourVariable; // Создаем копию переменной для ввода

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Изменить значение'),
          content: TextField(
            onChanged: (value) {
              updatedValue =
                  value; // Обновляем копию значения при изменении текста
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Отмена'),
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Закрываем диалоговое окно без сохранения изменений
              },
            ),
            TextButton(
              child: const Text('Сохранить'),
              onPressed: () {
                setState(() {
                  yourVariable = updatedValue; // Сохраняем измененное значение
                });
                updateName(updatedValue);
                Navigator.of(context).pop(); // Закрываем диалоговое окно
              },
            ),
          ],
        );
      },
    );
  }

  void onTapLongPressOne(BuildContext context) {
    // Ваше действие по долгому тапу

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
                  showInputDialogName(context, name as String);
                },
                child: const Text("Изменить автора"),
              ),
              TextButton(
                onPressed: () {
                  showInputDialogTitle(context, title as String);
                },
                child: const Text("Изменить название"),
              ),
              TextButton(
                onPressed: () {
                  // Действие при нажатии на кнопку "О книге"
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

  Future<void> pickAndDisplayFile() async {
    await requestPermission();
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;
      String filePath = file.path.toString();

      String imageBase64 = await extractBase64Image(filePath);
      setState(() {
        base64Image = imageBase64;
        cachedImagePath = null; // Сбросить путь к изображению
      });
    }
  }

  Future<String> extractBase64Image(String filePath) async {
    File file = File(filePath);
    final String xmlString = await file.readAsString();
    final XmlDocument document = XmlDocument.parse(xmlString);

    // Найти элемент <binary>
    final XmlElement binaryInfo = document.findAllElements('binary').first;

    // Извлечь текст между тегами <binary> и </binary>
    final String binary = binaryInfo.text;
    print('Binary:$binary');

    final String cleanedBinary = binary.replaceAll(RegExp(r"\s+"), "");

    print('CleanedBinary:$cleanedBinary');

    extractTitleAuthorAndTitle(filePath);
    return cleanedBinary;
  }

  Future<void> extractTitleAuthorAndTitle(String filePath) async {
    try {
      File file = File(filePath);
      final String xmlString = await file.readAsString();
      final XmlDocument document = XmlDocument.parse(xmlString);

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
        name = "Нет названия";
      }

      final XmlElement titleInfo = document.findAllElements('title-info').first;
      final XmlElement titleInfoTag =
          titleInfo.findElements('book-title').first;
      final String titleFromInfo = titleInfoTag.text;

      firstName = name;
      title = titleFromInfo;
      print(name);
    } catch (e) {
      // Здесь вы можете обработать ошибку, например, вывести сообщение или выполнить другие действия
      print('Произошла ошибка: $e');
    }
  }

  String getFirstName() {
    if (firstName == null && lastName == null) {
      print("Pizda name");
      return "Pizda name";
    } else {
      return name as String;
    }
  }

  void updateName(String newName) {
    name = newName;
  }

  void updateTitle(String newTitle) {
    title = newTitle;
  }

  String getTitle() {
    if (title == null) {
      print("Pizda title");
      return "Pizda title";
    } else {
      return title as String;
    }
  }

  Image decodeAndDisplayImage(String base64String) {
    List<int> imageBytes = base64.decode(base64String);
    return Image.memory(Uint8List.fromList(imageBytes));
  }

  Future<Uint8List> imageToByteList(Uint8List imageBytes) async {
    final img.Image imgImage = img.decodeImage(imageBytes)!;
    final img.Image resizedImage = img.copyResize(imgImage, width: 200);
    final Uint8List resizedImageBytes =
        Uint8List.fromList(img.encodePng(resizedImage));
    return resizedImageBytes;
  }

  Future<Uint8List> extractAndConvertBase64Image(String filePath) async {
    String imageBase64 = await extractBase64Image(filePath);
    Uint8List imageBytes = base64.decode(imageBase64);
    return imageToByteList(imageBytes);
  }

  Future<void> saveToCache(Uint8List imageBytes) async {
    final String cacheDir = (await getTemporaryDirectory()).path;
    final String cachedImagePath = '$cacheDir/fetched_image.png';

    final File cachedImageFile = File(cachedImagePath);
    print('cachedImageFile:$cachedImageFile');
    await cachedImageFile.writeAsBytes(imageBytes);

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('cachedImagePath', cachedImagePath);
    print('imageBytes:$imageBytes');
    print('cachedImagePath:$cachedImagePath');
    setState(() {
      _cachedImageBytes = imageBytes;
    });
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

  Widget getCachedImage() {
    if (_cachedImageBytes == null) {
      print('Нет кэшированного изображения');
      return const Text('Нет кэшированного изображения');
    } else {
      final image = Image.memory(_cachedImageBytes!);
      return image;
    }
  }

  Future<void> showCachedImage() async {
    final prefs = await SharedPreferences.getInstance();
    cachedImagePath = prefs.getString('cachedImagePath');
    print('showCachedImage.cachedImagePath:$cachedImagePath');
    getCachedImage();
    if (cachedImagePath != null) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(24, 28, 24, 24),
          child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: ListView(
                controller: _scrollController,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TextTektur(
                          text: "Последнее",
                          fontsize: 32,
                          textColor: MyColors.black),
                      Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0, 10, 0, 10),
                          child: Row(
                            children: [
                              if (cachedImagePath != null)
                                Column(
                                  children: [
                                    GestureDetector(
                                      onLongPress: () {
                                        onTapLongPressOne(context);
                                      },
                                      child: Image.file(
                                        File(cachedImagePath!),
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2.35,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.58,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),
                                    TextTektur(
                                        text: getFirstName(),
                                        fontsize: 12,
                                        textColor: MyColors.black),
                                    TextTektur(
                                        text: getTitle(),
                                        fontsize: 10,
                                        textColor: MyColors.black),
                                  ],
                                )
                              else if (base64Image != null)
                                Column(
                                  children: [
                                    GestureDetector(
                                      onLongPress: () {
                                        onTapLongPressOne(context);
                                      },
                                      child: Image.memory(
                                        base64.decode(base64Image!),
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2.35,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.58,
                                        fit: BoxFit.fitHeight,
                                      ),
                                    ),
                                    TextTektur(
                                        text: getFirstName(),
                                        fontsize: 12,
                                        textColor: MyColors.black),
                                    TextTektur(
                                        text: getTitle(),
                                        fontsize: 10,
                                        textColor: MyColors.black),
                                  ],
                                ),
                            ],
                          )),
                    ],
                  ),
                ],
              ))),
      floatingActionButton: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: _isVisible ? 1.0 : 0.0,
        child: FloatingActionButton(
          onPressed: pickAndDisplayFile,
          backgroundColor: MyColors.puple,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.zero)),
          autofocus: true,
          child: const Icon(CustomIcons.bookOpen),
        ),
      ),
    );
  }
}

void testbutton() {
  print("123");
}
