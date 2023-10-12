import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';

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
}
