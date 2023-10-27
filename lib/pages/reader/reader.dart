import 'dart:convert';

import 'package:flutter/material.dart';

import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:battery/battery.dart';

class BookInfo {
  String filePath;
  String fileText;
  String title;

  double lastPosition = 0;

  BookInfo(
      {required this.filePath,
      required this.fileText,
      required this.title,
      required this.lastPosition});
  Map<String, dynamic> toJson() {
    return {
      'filePath': filePath,
      'fileText': fileText,
      'title': title,
      'lastPosition': lastPosition,
    };
  }

  factory BookInfo.fromJson(Map<String, dynamic> json) {
    return BookInfo(
      filePath: json['filePath'],
      fileText: json['fileText'],
      title: json['title'],
      lastPosition: json['lastPosition'],
    );
  }
}

class ReaderPage extends StatefulWidget {
  const ReaderPage({Key? key}) : super(key: key);

  @override
  Reader createState() => Reader();
}

class Reader extends State {
  final Battery _battery = Battery();
  int _batteryLevel = 0;
  final PageController _pageController = PageController();

  void _getBatteryLevel() async {
    final batteryLevel = await _battery.batteryLevel;
    print(batteryLevel);
    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  @override
  void initState() {
    getDataFromLocalStorage('textKey');
    _getBatteryLevel();
    super.initState();
  }

  String getText = "";
  List<BookInfo> textes = [];

  Future<void> getDataFromLocalStorage(String key) async {
    getText = "";
    final prefs = await SharedPreferences.getInstance();
    String? textDataJson = prefs.getString(key);
    print('recent textDataJson: $textDataJson');
    if (textDataJson != null) {
      textes = (jsonDecode(textDataJson) as List)
          .map((item) => BookInfo.fromJson(item))
          .toList();
      setState(() {});
    }
    getText = textes[0]
        .fileText
        .toString()
        .replaceAll(RegExp(r'\['), '')
        .replaceAll(RegExp(r'\]'), '');
    print('reader textes[0].fileText: ${textes[0].fileText.toString()}');
    print('reader getText: $getText');
  }

  List<String> getPages(String text, int pageSize) {
    List<String> pages = [];
    int textLength = text.length;
    int i = 0;

    while (i < textLength) {
      int endIndex = i + pageSize;
      if (endIndex > textLength) {
        endIndex = textLength;
      } else {
        while (endIndex > i && !text[endIndex - 1].contains(RegExp(r'\s'))) {
          endIndex--;
        }
      }
      pages.add(text.substring(i, endIndex));
      i = endIndex;
    }
    return pages;
  }

  int currentPage = 0;
  double pagePercent = 0;

  @override
  Widget build(BuildContext context) {
    double pageSize = MediaQuery.of(context).size.height * 1;
    // double pageSize = MediaQuery.of(context).size.width * 2.7;
    // double pageHeight = MediaQuery.of(context).size.height;

    List<String> textPages = getPages(getText, pageSize.toInt());

    _pageController.addListener(() {
      setState(() {});
      currentPage = _pageController.page!.toInt();
      pagePercent =
          (((currentPage.toDouble() + 1.0) / textPages.length.toDouble()) *
              100.0);
      setState(() {});
    });

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
            left: false,
            top: false,
            right: false,
            bottom: false,
            minimum: const EdgeInsets.all(16.0),
            child: ListView.builder(
                controller: _pageController,
                itemCount: textPages.length,
                itemBuilder: (context, index) {
                  currentPage = index;
                  return Center(
                      child: Text(
                    textPages[index],
                    softWrap: true,
                    style: const TextStyle(fontSize: 18.0),
                  ));
                })),
        bottomNavigationBar: BottomAppBar(
          child: SizedBox(
            height: 25.0, // Высота вашей навигационной панели
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                  child: Text(
                    '${_batteryLevel.toString()}%',
                    style: const TextStyle(
                        fontSize: 14.0, fontWeight: FontWeight.bold),
                  ),
                ),
                Align(
                  alignment:
                      Alignment.center, // Центрирование только этого элемента
                  child: Text(
                    textes[0].title.toString().length > 28
                        ? '${textes[0].title.toString().substring(0, 28)}...'
                        : textes[0].title.toString(),
                    style: const TextStyle(
                        fontSize: 14.0, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                  child: Text(
                    '${pagePercent.toStringAsFixed(2)}%', // Отображение счетчика страниц
                    style: const TextStyle(
                        fontSize: 14.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
