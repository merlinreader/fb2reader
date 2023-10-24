import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';

// для получаения картинки из файла книги
import 'package:xml/xml.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:merlin/pages/page.dart';

class ImageData {
  final Uint8List imageBytes;
  final String title;
  final String author;

  ImageData(this.imageBytes, this.title, this.author);
}

class ImageLoader {
  final imageController = StreamController<ImageData>();
  Stream<ImageData> get imageStream => imageController.stream;

  final testContoller = StreamController<String>();
  Stream<String> get testStream => testContoller.stream;

  String title = "Название не найдено";
  String firstName = "";
  String lastName = "";
  String name = "Автор не найден";

  Future<void> loadImage() async {
    await requestPermission();

    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      String path = result.files.single.path!;
      String fileContent = await File(path).readAsString();

      XmlDocument document = XmlDocument.parse(fileContent);
      final XmlElement binaryInfo = document.findAllElements('binary').first;
      final String binary = binaryInfo.text;
      final String cleanedBinary = binary.replaceAll(RegExp(r"\s+"), "");
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
      }

      imageController.add(ImageData(decodedBytes, title, name));
      testContoller.add("Hello");
      print("imageloader done");
    }
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
