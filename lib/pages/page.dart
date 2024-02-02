import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:merlin/UI/icon/custom_icon.dart';
import 'package:merlin/UI/router.dart';
import 'package:merlin/pages/loading/loading.dart';
import 'package:merlin/pages/profile/profile.dart';
import 'package:merlin/pages/profile/profile_view_model.dart';
import 'package:merlin/pages/reader/reader.dart';
import 'package:merlin/style/colors.dart';
import 'package:merlin/pages/achievements/achievements.dart';
import 'package:merlin/style/text.dart';
import 'package:merlin/pages/recent/recent.dart';
import 'package:merlin/components/svg/svg_asset.dart';
import 'package:merlin/pages/recent/imageloader.dart';
import 'package:merlin/pages/statistic/statistic.dart';
import 'package:merlin/functions/location.dart';
import 'package:provider/provider.dart';
import 'package:merlin/pages/recent/recent.dart' as recent;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart';

class AppPage extends StatefulWidget {
  const AppPage({Key? key}) : super(key: key);

  @override
  Page createState() => Page();
}

class Page extends State<AppPage> {
  int _selectedPage = 1;
  String bookName = '';

  static const List<Widget> _widgetOptions = <Widget>[
    LoadingScreen(),
    RecentPage(),
    AchievementsPage(),
    StatisticPage(),
  ];

  @override
  void initState() {
    getBookName();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getBookName();
  }

  Future<dynamic> getBookName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      bookName = prefs.getString('fileTitle') ?? '';
    });
  }

  void onSelectTab(int index) async {
    //if (index == _selectedPage) return;
    setState(() {
      profile = false;
      _widgetOptions[index];
      _selectedPage = index;
    });
    if (index == 0) {
      await ImageLoader().loadImage();
      await Navigator.pushNamed(context, RouteNames.reader);
      setState(() {
        profile = false;
        _selectedPage = 1;
        _widgetOptions[1];
      });
    }
  }

  bool profile = false;
  final ImageLoader imageLoader = ImageLoader();

  @override
  Widget build(BuildContext context) {
    getLocation();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0.5,
        title: GestureDetector(
          onTap: () {
            setState(() {
              profile = true;
            });
          },
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 6, right: 16),
                child: SvgPicture.asset(
                  SvgAsset.merlinLogo,
                ),
              ),
              const Text24(text: 'Merlin', textColor: MyColors.black),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedPage,
        backgroundColor: Theme.of(context).colorScheme.primary,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CustomIcons.bookOpen),
            label: 'Книги',
          ),
          BottomNavigationBarItem(
            icon: Icon(CustomIcons.clock),
            label: 'Последнее',
          ),
          BottomNavigationBarItem(
            icon: Icon(CustomIcons.trophy),
            label: 'Достижения',
          ),
          BottomNavigationBarItem(
            icon: Icon(CustomIcons.chart),
            label: 'Статистика',
          ),
        ],
        onTap: (index) {
          onSelectTab(index);
        },
        selectedItemColor: profile == true ? MyColors.grey : MyColors.purple,
        unselectedItemColor: MyColors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontFamily: 'Tektur',
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontFamily: 'Tektur',
          fontWeight: FontWeight.bold,
        ),
      ),
      body: profile == true
          ? ChangeNotifierProvider(
              create: (context) => ProfileViewModel(context),
              child: const Profile(),
            )
          : _widgetOptions[_selectedPage],
      floatingActionButton: profile == false
          ? FloatingActionButton(
              onPressed: () {
                try {
                  // if (RecentPageState().checkBooks() == true) {
                  //   Fluttertoast.showToast(
                  //     msg: 'Нет последней книги',
                  //     toastLength: Toast.LENGTH_SHORT, // Длительность отображения
                  //     gravity: ToastGravity.BOTTOM,
                  //   ); // Расположение уведомления
                  // } else {
                  if (bookName == '') {
                    Fluttertoast.showToast(
                      msg: 'Нет последней книги',
                      toastLength: Toast.LENGTH_SHORT, // Длительность отображения
                      gravity: ToastGravity.BOTTOM,
                    );
                  } else {
                    Navigator.pushNamed(context, RouteNames.reader);
                  }
                  return;
                } catch (e) {
                  Fluttertoast.showToast(
                    msg: 'Нет последней книги',
                    toastLength: Toast.LENGTH_SHORT, // Длительность отображения
                    gravity: ToastGravity.BOTTOM, // Расположение уведомления
                  );
                }
              },
              backgroundColor: MyColors.purple,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.zero)),
              autofocus: true,
              child: Icon(
                CustomIcons.bookOpen,
                color: Theme.of(context).colorScheme.background,
              ),
            )
          : null,
    );
  }
}
