import 'package:file_picker/file_picker.dart';
import 'dart:io';

void pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null) {
      final fileName = result.files.first.name;
      print(fileName);
      final pickedfile = result.files.first;
      final fileToDisplay = File(pickedfile.path.toString());
      print(fileToDisplay);
    }
  }