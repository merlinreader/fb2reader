import 'package:flutter/material.dart';
import 'package:merlin/UI/icon/custom_icon.dart';
import 'package:merlin/style/colors.dart';

import 'package:merlin/pages/profile/profile.dart';
import 'package:merlin/pages/settings.dart';

class CustomNavBar extends StatefulWidget {
  const CustomNavBar({super.key});

  @override
  CustomNavBarState createState() => CustomNavBarState();
}

class CustomNavBarState extends State<CustomNavBar> {
  int selectedPage = 0;
  final List screen = [Profile, MySettings];
  
  void onItemTapped(int index) {
    setState(() {
      selectedPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedPage,
      backgroundColor: MyColors.white,
      type: BottomNavigationBarType.fixed,
      elevation: 1,
      
      items: const [
        BottomNavigationBarItem(
          icon: Icon(CustomIcons.bookOpen),
          label: 'Книги',
        ),
        BottomNavigationBarItem(
            icon: Icon(CustomIcons.clock), label: 'Последнее'),
        BottomNavigationBarItem(
            icon: Icon(CustomIcons.trophy), label: 'Достижения'),
        BottomNavigationBarItem(
            icon: Icon(
              CustomIcons.chart,
            ),
            label: 'Статистика'),
      ],
      onTap: (index) {
       
        onItemTapped(index); 
      },

      selectedItemColor: MyColors.puple,
      unselectedItemColor: MyColors.grey,
      showUnselectedLabels: true,
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