import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:merlin/UI/icon/custom_icon.dart';
import 'package:merlin/style/colors.dart';
import 'package:merlin/pages/profile/profile.dart';
<<<<<<< HEAD
import 'package:merlin/pages/achievements.dart';
=======
import 'package:merlin/pages/achievements/achievements.dart';
//import 'package:merlin/pages/settings.dart';
import 'package:merlin/components/svg/svg_widget.dart';
>>>>>>> 5b57ec10bcd8e8746aedc36ac9c56279453d4579
import 'package:merlin/style/text.dart';
import 'package:merlin/functions/pickfile.dart';
<<<<<<< HEAD
import 'package:merlin/pages/statistic.dart';
=======
import 'package:merlin/pages/statistic/statistic.dart';

>>>>>>> 5b57ec10bcd8e8746aedc36ac9c56279453d4579
import 'package:merlin/pages/recent/recent.dart';
import 'package:merlin/components/svg/svg_asset.dart';

class AppPage extends StatefulWidget {
  const AppPage({Key? key}) : super(key: key);

  @override
  Page createState() => Page();
}

class Page extends State {
  int _selectedPage = 3;
  static const List<Widget> _widgetOptions = <Widget>[
    Profile(),
    Recent(),
    AchievementsPage(),
    StatisticPage()
  ];

  void onSelectTab(int index) {
    if (index == _selectedPage) return;
    setState(() {
      _selectedPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        //верхний бар
        appBar: AppBar(
          backgroundColor: MyColors.white,
          elevation: 0.5,
          title: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 16),
                child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPage = 0;
                      });
                    },
                    child: SvgPicture.asset(SvgAsset.merlinLogo)),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedPage = 0;
                  });
                },
                child: const Text24(
                  text: 'Merlin',
                  textColor: MyColors.black,
                ),
              )
            ],
          ),
        ),
        //Нижний бар
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedPage,
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
            if (index == 0) {
              pickFile();
              return;
            }
            onSelectTab(index);
          },
          selectedItemColor: MyColors.purple,
          unselectedItemColor: MyColors.grey,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(
              fontSize: 11,
              fontFamily: 'Tektur',
              height: 2.2,
              fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(
              fontSize: 11, fontFamily: 'Tektur', fontWeight: FontWeight.bold),
        ),
        body: _widgetOptions[_selectedPage],
      ),
    );
  }
}
