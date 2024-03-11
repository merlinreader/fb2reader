// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';

// для получаения картинки из файла книги
import 'package:merlin/functions/book.dart';
import 'package:merlin/pages/reader/reader.dart';
import 'package:merlin/pages/recent/recent.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:merlin/pages/reader/reader.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:archive/archive.dart';

class ImageLoader {
  String title = "Название не найдено";
  String firstName = "";
  String lastName = "";
  String name = "Автор не найден";
  List text = [];

  late Uint8List decodedBytes;

  Future<void> loadImage() async {
    final prefs = await SharedPreferences.getInstance();

    var check = await requestStoragePermission();
    if (check == true) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle: "Выберите книгу fb2",
        allowMultiple: false,
      );

      if (result?.files.first.extension != 'fb2' && result?.files.first.extension != 'zip') {
        Fluttertoast.showToast(
          msg: 'Формат книги должен быть fb2 или zip',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        await prefs.setBool('success', false);
        return;
      }

      if (result?.count == null) {
        Fluttertoast.showToast(
          msg: 'Никакой файл не выбран',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        await prefs.setBool('success', false);
        return;
      }

      String fileContent = '';
      String path = '';
      if (result?.files.first.extension == 'zip') {
        path = await extractFB2FromZip(result!.files.single.path!);
        if (path != '') {
          // print('НАЙДЕН FB2');
          fileContent = utf8.decode((File(path).readAsBytesSync()));
        } else {
          // print("Файл fb2 не найден в архиве");
          return;
        }
      } else {
        path = result!.files.single.path!;
        fileContent = await File(path).readAsString();
      }

      XmlDocument document = XmlDocument.parse(fileContent);
      try {
        final XmlElement binaryInfo = document.findAllElements('binary').first;
        final String binary = binaryInfo.text;
        final String cleanedBinary = binary.replaceAll(RegExp(r"\s+"), "");
        decodedBytes = base64.decode(cleanedBinary);
      } catch (e) {
        decodedBytes = Uint8List.fromList([0]);
        Fluttertoast.showToast(
          msg: 'Книга не содержит обложку',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }

      try {
        final XmlElement titleInfo = document.findAllElements('title-info').first;
        final XmlElement titleInfoTag = titleInfo.findElements('book-title').first;
        final String titleFromInfo = titleInfoTag.text;
        title = titleFromInfo;
      } catch (e) {
        title = "Название не найдено";
      }

      try {
        final XmlElement authorInfo = document.findAllElements('author').first;
        final XmlElement firstNameInfo = authorInfo.findElements('first-name').first;
        final String firstNameFromInfo = firstNameInfo.text;

        final XmlElement lastNameInfo = authorInfo.findElements('last-name').first;
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

      ImageInfo imageData = ImageInfo(imageBytes: decodedBytes, title: title, author: name, fileName: path, progress: 0.0);

      BookInfo bookData = BookInfo(filePath: path, fileText: text.toString(), title: title, author: name, lastPosition: 0);
      Book book = Book.combine(bookData, imageData);
      Map<String, dynamic> jsonData = book.toJson();
      final Directory? externalDir = await getExternalStorageDirectory();
      final String pathWithJsons = '${externalDir?.path}/books';
      String targetFileName = '$title.json';
      final Directory directory = Directory(pathWithJsons);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      final File targetFile = File('${directory.path}/$targetFileName');
      var temp = await targetFile.exists();

      if (!await targetFile.exists()) {
        await targetFile.create();
      }
      print('ImageLoader temp $temp');
      if (temp == false) {
        await book.saveJsonToFile(jsonData, title);
        await prefs.setString('fileTitle', title);
        await prefs.setBool('success', true);
      } else {
        Fluttertoast.showToast(
          msg: 'Данная книга уже есть в приложении',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        await prefs.setString('fileTitle', title);
        await prefs.setBool('success', true);
        return;
      }
    } else {
      Fluttertoast.showToast(
        msg: 'Вы не дали доступ к хранилищу',
        toastLength: Toast.LENGTH_SHORT, // Длительность отображения
        gravity: ToastGravity.BOTTOM, // Расположение уведомления
      );
      await prefs.setBool('success', false);
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
        return true;
    }
  }

  extractFB2FromZip(String zipFilePath) async {
    try {
      File zipFile = File(zipFilePath);
      List<int> bytes = await zipFile.readAsBytes();

      final tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;

      String unzipPath = '$tempPath/unzipped/';
      Directory(unzipPath).createSync();

      Archive archive = ZipDecoder().decodeBytes(bytes);

      for (ArchiveFile file in archive) {
        String fileName = file.name;
        if (fileName.toLowerCase().endsWith('.fb2')) {
          String filePath = '$unzipPath$fileName';
          File fb2File = File(filePath);
          fb2File = await fb2File.create(recursive: true);
          await fb2File.writeAsBytes(file.content);
          // print('Найден файл FB2: $fileName, путь: $filePath');
          return filePath;
        }
      }
    } catch (e) {
      // print('Error extracting FB2 from zip: $e');
    }

    return null;
  }
}
