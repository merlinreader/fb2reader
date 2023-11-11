// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';

// для получаения картинки из файла книги
import 'package:merlin/pages/recent/recent.dart';
import 'package:xml/xml.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:merlin/pages/reader/reader.dart';
import 'package:device_info_plus/device_info_plus.dart';

class ImageLoader {
  String title = "Название не найдено";
  String firstName = "";
  String lastName = "";
  String name = "Автор не найден";
  List text = [];

  late Uint8List decodedBytes;

  Future<void> loadImage() async {
    var check = await requestStoragePermission();
    if (check == true) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle: "Выберите книгу fb2",
        allowMultiple: false,
      );

      if (result?.files.first.extension != 'fb2') {
        Fluttertoast.showToast(
          msg: 'Формат книги должен быть fb2',
          toastLength: Toast.LENGTH_SHORT, // Длительность отображения
          gravity: ToastGravity.BOTTOM, // Расположение уведомления
        );
        return;
      }

      String path = result!.files.single.path!;

      final prefs = await SharedPreferences.getInstance();
      String? imageDataToAdd = prefs.getString('booksKey');
      List<ImageInfo> imageDatas = [];
      List<BookInfo> bookDatas = [];

      if (imageDataToAdd != null) {
        imageDatas = (jsonDecode(imageDataToAdd) as List)
            .map((item) => ImageInfo.fromJson(item))
            .toList();
      }
      if (imageDatas.any((imageData) => imageData.fileName == path)) {
        Fluttertoast.showToast(
          msg: 'Данная книга уже есть в приложении',
          toastLength: Toast.LENGTH_LONG, // Длительность отображения
          gravity: ToastGravity.BOTTOM, // Расположение уведомления
        );
        return;
      }

      String fileContent = await File(path).readAsString();

      XmlDocument document = XmlDocument.parse(fileContent);
      final XmlElement binaryInfo = document.findAllElements('binary').first;
      final String binary = binaryInfo.text;
      final String cleanedBinary = binary.replaceAll(RegExp(r"\s+"), "");
      decodedBytes = base64.decode(cleanedBinary);

      try {
        final XmlElement titleInfo =
            document.findAllElements('title-info').first;
        final XmlElement titleInfoTag =
            titleInfo.findElements('book-title').first;
        final String titleFromInfo = titleInfoTag.text;
        title = titleFromInfo;
      } catch (e) {
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
        name = "Автор не найден";
      }

      final Iterable<XmlElement> textInfo = document.findAllElements('body');
      for (var element in textInfo) {
        text.add(element.innerText.replaceAll(RegExp(r'\[.*?\]'), ''));
      }

      ImageInfo imageData = ImageInfo(
          imageBytes: decodedBytes,
          title: title,
          author: name,
          fileName: path,
          progress: 0.0);
      imageDatas.add(imageData);

      BookInfo bookData = BookInfo(
          filePath: path,
          fileText: text.toString(),
          title: title,
          author: name,
          lastPosition: 0);
      bookDatas.add(bookData);
      String imageDatasString = jsonEncode(imageDatas);
      String textDataString = jsonEncode(bookDatas);
      await prefs.setString('textKey', textDataString);

      await prefs.setString('booksKey', imageDatasString);
    } else {
      Fluttertoast.showToast(
        msg: 'Вы не дали доступ к хранилищу',
        toastLength: Toast.LENGTH_SHORT, // Длительность отображения
        gravity: ToastGravity.BOTTOM, // Расположение уведомления
      );
      return;
    }
  }

  requestStoragePermission() async {
    PermissionStatus status;
    if (Platform.isAndroid) {
      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      final AndroidDeviceInfo info = await deviceInfoPlugin.androidInfo;
      if ((info.version.sdkInt) >= 33) {
        status = await Permission.manageExternalStorage.request();
      } else {
        status = await Permission.storage.request();
      }
    } else {
      status = await Permission.storage.request();
    }

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
      // TODO: Handle this case.
    }
  }
}
