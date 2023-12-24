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

  static const List<Widget> _widgetOptions = <Widget>[
    LoadingScreen(),
    RecentPage(),
    AchievementsPage(),
    StatisticPage(),
  ];

  void onSelectTab(int index) async {
    //if (index == _selectedPage) return;
    setState(() {
      profile = false;
      _widgetOptions[index];
      _selectedPage = index;
    });
    if (index == 0) {
      await ImageLoader().loadImage();
      var temp = await getIndex();
      var tempPro;
      print(temp);
      await getDataFromLocalStorage('booksKey');
      if (temp != 0) {
        await sendData('textKey', temp - 1);
      } else {
        await sendData('textKey', temp);
      }

      await Navigator.pushNamed(context, RouteNames.reader).then((_) {
        getDataFromLocalStorage('booksKey');
      });
      print('GOVNOOO');
      print('tempPro $tempPro');
      setState(() {
        profile = false;
        _selectedPage = 1;
        _widgetOptions[1];
      });
    }
  }

  List<recent.ImageInfo> tempImages = [];

  Future<void> saveImages(key) async {}

  Future<void> getDataFromLocalStorage(String key) async {
    final prefs = await SharedPreferences.getInstance();
    String? imageDataJson = prefs.getString(key);
    if (imageDataJson != null) {
      tempImages = (jsonDecode(imageDataJson) as List).map((item) => recent.ImageInfo.fromJson(item)).toList();
    }
    for (var e in tempImages) {
      print(e.title);
      print(e.progress);
    }
    await prefs.setString('booksKey', jsonEncode(tempImages));
  }

  Future<void> sendData(String key, int index) async {
    List text = [];
    List<BookInfo> bookDatas = [];
    String fileContent = await File(tempImages[index].fileName).readAsString();
    XmlDocument document = XmlDocument.parse(fileContent);
    final Iterable<XmlElement> textInfo = document.findAllElements('body');
    for (var element in textInfo) {
      text.add(element.innerText.replaceAll(RegExp(r'\[.*?\]'), ''));
    }
    BookInfo bookData = BookInfo(
        filePath: tempImages[index].fileName,
        fileText: text.toString(),
        title: tempImages[index].title,
        author: tempImages[index].author,
        lastPosition: 0);
    bookDatas.add(bookData);
    String textDataString = jsonEncode(bookDatas);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, textDataString);
  }

  Future<int> getIndex() async {
    final prefs = await SharedPreferences.getInstance();
    String? imageDataJson = prefs.getString('booksKey');

    // Проверяем, существует ли JSON строка
    if (imageDataJson != null) {
      // Парсим JSON строку в динамическую структуру данных
      dynamic data = json.decode(imageDataJson);
      // Подсчитываем количество объектов
      int count = countObjects(data);
      return count;
    } else {
      // Если JSON не найден, возвращаем 0 или выбрасываем исключение
      return 0;
    }
  }

  int countObjects(dynamic element) {
    int count = 0;
    void recurse(dynamic element) {
      if (element is Map) {
        count++;
        element.forEach((key, value) {
          recurse(value);
        });
      } else if (element is List) {
        element.forEach(recurse);
      }
    }

    recurse(element);
    return count;
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
                  if (RecentPageState().checkImages() == true) {
                    Fluttertoast.showToast(
                      msg: 'Нет последней книги',
                      toastLength: Toast.LENGTH_SHORT, // Длительность отображения
                      gravity: ToastGravity.BOTTOM,
                    ); // Расположение уведомления
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
