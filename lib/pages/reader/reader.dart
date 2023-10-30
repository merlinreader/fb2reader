import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:merlin/UI/router.dart';
import 'package:merlin/style/colors.dart';
import 'package:merlin/style/text.dart';

import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:battery/battery.dart';

class BookInfo {
  String filePath;
  String fileText;
  String title;
  String author;

  double lastPosition = 0;

  BookInfo(
      {required this.filePath,
      required this.fileText,
      required this.title,
      required this.author,
      required this.lastPosition});
  Map<String, dynamic> toJson() {
    return {
      'filePath': filePath,
      'fileText': fileText,
      'title': title,
      'author': author,
      'lastPosition': lastPosition,
    };
  }

  factory BookInfo.fromJson(Map<String, dynamic> json) {
    return BookInfo(
      filePath: json['filePath'],
      fileText: json['fileText'],
      title: json['title'],
      author: json['author'],
      lastPosition: json['lastPosition'],
    );
  }
}

class TranslationDialog extends StatelessWidget {
  final String translatedText;

  const TranslationDialog(this.translatedText, {super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SimpleDialog(
        title: const Text('Перевод'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              translatedText,
              style: const TextStyle(
                  fontSize: 24.0), // настройте стиль по своему усмотрению
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('ОК'),
          onPressed: () {
            Navigator.of(context).pop(); // Закрыть диалоговое окно
          },
        ),
      ],
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
  final ScrollController _scrollController = ScrollController();

  double _scrollPosition = 0.0;

  void _getBatteryLevel() async {
    final batteryLevel = await _battery.batteryLevel;
    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  @override
  void initState() {
    getDataFromLocalStorage('textKey');
    _getBatteryLevel();
    _scrollController.addListener(_updateScrollPercentage);
    super.initState();
  }

  @override
  Future<void> didChangeDependencies() async {
    final prefs = await SharedPreferences.getInstance();
    final bgColor = prefs.getInt('backgroundColor') ?? MyColors.mint.value;
    final textColor = prefs.getInt('textColor') ?? MyColors.black.value;
    getBgcColor = Color(bgColor);
    getTextColor = Color(textColor);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    saveReadingPosition(_scrollPosition);
    super.dispose();
  }

  @override
  void deactivate() {
    saveReadingPosition(_scrollPosition);
    super.deactivate();
  }

  void saveReadingPosition(double position) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('readingPosition', position);
  }

  Future<void> getReadingPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final position = prefs.getDouble('readingPosition');
    if (position != null) {
      setState(() {
        _scrollController.animateTo(position,
            duration: const Duration(milliseconds: 250), curve: Curves.ease);
      });
    }
  }

  void _updateScrollPercentage() {
    if (_scrollController.position.maxScrollExtent == 0) {
      return;
    }
    double percentage = (_scrollController.position.pixels /
            _scrollController.position.maxScrollExtent) *
        100;
    setState(() {
      _scrollPosition = percentage;
    });
    saveReadingPosition(_scrollController.position.pixels);
  }

  Color getTextColor = MyColors.black;
  Color getBgcColor = MyColors.white;

  Future<void> loadStylePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final bgColor = prefs.getInt('backgroundColor') ?? MyColors.mint.value;
    final textColor = prefs.getInt('textColor') ?? MyColors.black.value;
    setState(() {
      getBgcColor = Color(bgColor);
      getTextColor = Color(textColor);
    });
  }

  String getText = "";
  List<BookInfo> textes = [];

  Future<void> getDataFromLocalStorage(String key) async {
    getText = "";
    final prefs = await SharedPreferences.getInstance();
    String? textDataJson = prefs.getString(key);
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

  double pagePercent = 0;

  @override
  Widget build(BuildContext context) {
    double pageSize = MediaQuery.of(context).size.height * 3;
    // double pageSize = MediaQuery.of(context).size.width * 2.7;
    // double pageHeight = MediaQuery.of(context).size.height;

    List<String> textPages = getPages(getText, pageSize.toInt());
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: MyColors.black),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: SvgPicture.asset(
            'assets/images/chevron-left.svg',
            width: 16,
            height: 16,
          ),
        ),
        backgroundColor: MyColors.white,
        shadowColor: Colors.transparent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextTektur(
              text: textes.first.author.toString().length > 18
                  ? '${textes[0].author.toString()}. ${textes[0].title.toString().substring(0, 3)}...'
                  : textes[0].title.toString(),
              fontsize: 18,
              textColor: MyColors.black,
              fontWeight: FontWeight.w600,
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, RouteNames.readerSettings)
                    .then((value) => loadStylePreferences());
              },
              child: const Icon(
                Icons.settings,
                color: MyColors.black,
              ),
            )
          ],
        ),
      ),
      body: Container(
          color: getBgcColor,
          child: SafeArea(
              left: false,
              top: false,
              right: false,
              bottom: false,
              minimum: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: ListView.builder(
                  controller: _scrollController,
                  itemCount: textPages.length,
                  itemBuilder: (context, index) {
                    return Center(
                        child: SelectableText(getText,
                            style: TextStyle(
                              fontSize: 18.0,
                              color: getTextColor,
                            )));
                  }))),
      bottomNavigationBar: BottomAppBar(
        child: SizedBox(
          height: 30.0, // Высота вашей навигационной панели
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: const EdgeInsets.fromLTRB(24, 3, 24, 0),
                  child: TextTektur(
                    text: '${_batteryLevel.toString()}%',
                    fontsize: 12,
                    textColor: MyColors.black,
                    fontWeight: FontWeight.w600,
                  )),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                child: Align(
                    alignment: Alignment
                        .topCenter, // Центрирование только этого элемента
                    child: TextTektur(
                      text: textes[0].title.toString().length > 28
                          ? '${textes[0].title.toString().substring(0, 28)}...'
                          : textes[0].title.toString(),
                      fontsize: 12,
                      textColor: MyColors.black,
                      fontWeight: FontWeight.w600,
                    )),
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(24, 3, 24, 0),
                  child: TextTektur(
                    text: '${_scrollPosition.toStringAsFixed(2)}%',
                    fontsize: 12,
                    textColor: MyColors.black,
                    fontWeight: FontWeight.w600,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
