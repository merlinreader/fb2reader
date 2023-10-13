import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
// import 'package:open_file/open_file.dart';

import 'package:merlin/UI/icon/custom_icon.dart';
import 'package:merlin/style/colors.dart';

class CustomNavBar extends StatelessWidget {
  const CustomNavBar({super.key});
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: MyColors.white,
      //одинаковое расстояние между иконками
      type: BottomNavigationBarType.fixed,
      //тень
      elevation: 1,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(CustomIcons.clock), label: 'Последнее'),
        BottomNavigationBarItem(
          icon: Icon(CustomIcons.bookOpen),
          label: 'Книги',
        ),
        BottomNavigationBarItem(
            icon: Icon(CustomIcons.trophy), label: 'Достижения'),
        BottomNavigationBarItem(
            icon: Icon(
              CustomIcons.chart,
            ),
            label: 'Статистика'),
      ],
      onTap: (index) async {
        if (index == 1) {
          pickFile();
        }
      },
      // Цвет выбранного элемента
      selectedItemColor: MyColors.puple,
      // Цвет не выбранных элементов
      unselectedItemColor: MyColors.grey,
      // Показывать текст для не выбранных элементов
      showUnselectedLabels: true,
      //стили текста для нав. меню
      selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontFamily: 'Tektur',
          height: 2.2,
          fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(
          fontSize: 11, fontFamily: 'Tektur', fontWeight: FontWeight.bold),
    );
  }

  void pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );
    //if (result == null) return;

    if (result != null) {
      final _fileName = result.files.first.name;
      print('Имя файла');
      print(_fileName);
      final pickedfile = result.files.first;
      final fileToDisplay = File(pickedfile.path.toString());
      //FilePickerResult fileToDisplay = File(result.files.single.path);
      print(fileToDisplay);
      print(fileToDisplay);
      print(fileToDisplay);
    }
  }
}
