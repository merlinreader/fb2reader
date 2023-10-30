import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:merlin/UI/icon/custom_icon.dart';
import 'package:merlin/UI/router.dart';
import 'package:merlin/style/colors.dart';
import 'package:merlin/pages/achievements/achievements.dart';
import 'package:merlin/style/text.dart';
import 'package:merlin/pages/loading.dart';
import 'package:merlin/pages/recent/recent.dart';
import 'package:merlin/components/svg/svg_asset.dart';
import 'package:merlin/pages/recent/imageloader.dart';
import 'package:merlin/pages/statistic/statistic.dart';

class AppPage extends StatefulWidget {
  const AppPage({Key? key}) : super(key: key);

  @override
  Page createState() => Page();
}

class Page extends State {
  int _selectedPage = 1;
  static const List<Widget> _widgetOptions = <Widget>[
    LoadingScreen(),
    RecentPage(),
    AchievementsPage(),
    StatisticPage(),
    //Profile()
  ];

  void onSelectTab(int index) async {
    if (index == _selectedPage) return;
    setState(() {
      _selectedPage = index;
    });
    if (index == 0) {
      await ImageLoader().loadImage();
      setState(() {
        _selectedPage = 1;
      });
    }
  }

  final ImageLoader imageLoader = ImageLoader();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //верхний бар
      appBar: AppBar(
          backgroundColor: MyColors.white,
          // Theme.of(context).primaryColor,
          elevation: 0.5,
          title: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, RouteNames.profile);
            },
            child: Row(
              children: [
                Padding(
                    padding: const EdgeInsets.only(left: 24, right: 16),
                    child: SvgPicture.asset(SvgAsset.merlinLogo)),
                const Text24(text: 'Merlin', textColor: MyColors.black)
              ],
            ),
          )),
      //Нижний бар
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedPage,
        backgroundColor: MyColors.white,
        type: BottomNavigationBarType.fixed,
        //elevation: 5,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CustomIcons.bookOpen),
            label: 'Проводник',
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
          onSelectTab(index);
        },
        selectedItemColor: MyColors.purple,
        unselectedItemColor: MyColors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
            fontSize: 11, fontFamily: 'Tektur', fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(
            fontSize: 11, fontFamily: 'Tektur', fontWeight: FontWeight.bold),
      ),
      body: _widgetOptions[_selectedPage],
    );
  }
}
