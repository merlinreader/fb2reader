import 'package:flutter/material.dart';
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
            icon: Icon(CustomIcons.bookOpen), label: 'Книги'),
        BottomNavigationBarItem(
            icon: Icon(CustomIcons.clock), label: 'Последнее'),
        BottomNavigationBarItem(
            icon: Icon(CustomIcons.trophy), label: 'Достижения'),
        BottomNavigationBarItem(
            icon: Icon(
              CustomIcons.chart,
            ),
            label: 'Мой профиль'),
      ],
      // Цвет выбранного элемента
      selectedItemColor: MyColors.puple,
      // Цвет не выбранных элементов
      unselectedItemColor: MyColors.grey,
      // Показывать текст для не выбранных элементов
      showUnselectedLabels: true,
      //стили текста для нав. меню
      selectedLabelStyle:
          const TextStyle(fontSize: 11, fontFamily: 'Tektur', height: 2.2),
      unselectedLabelStyle: const TextStyle(fontSize: 11, fontFamily: 'Tektur'),
    );
  }
}
