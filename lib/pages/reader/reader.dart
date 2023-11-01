import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:merlin/UI/icon/custom_icon.dart';
import 'package:merlin/UI/router.dart';
import 'package:merlin/style/colors.dart';
import 'package:merlin/style/text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:battery/battery.dart';

class BookInfo {
  String filePath;
  String fileText;
  String title;
  String author;
  double lastPosition = 0;

  BookInfo({
    required this.filePath,
    required this.fileText,
    required this.title,
    required this.author,
    required this.lastPosition,
  });

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

class ReaderPage extends StatefulWidget {
  const ReaderPage({Key? key}) : super(key: key);

  @override
  Reader createState() => Reader();
}

class Reader extends State {
  final Battery _battery = Battery();
  int _batteryLevel = 0;
  final ScrollController _scrollController = ScrollController();
  double lastPosition = 0;
  bool isLast = false;

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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      final filePath =
          textes.first.filePath; // Используйте путь из текущей книги
      // ignore: unnecessary_null_comparison
      if (filePath != null) {
        final readingPositionsJson = prefs.getString('readingPositions');
        if (readingPositionsJson != null) {
          final readingPositions = jsonDecode(readingPositionsJson);
          if (readingPositions.containsKey(filePath)) {
            lastPosition = readingPositions[filePath];
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                lastPosition,
                duration: const Duration(milliseconds: 500),
                curve: Curves.linear,
              );
            }
            setState(() {
              isLast = true;
            });
          }
        }
      }
    });
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

  Future<void> saveReadingPosition(double position, String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    final readingPositionsJson = prefs.getString('readingPositions');
    Map<String, double> readingPositions = {};

    if (readingPositionsJson != null) {
      final readingPositionsMap = jsonDecode(readingPositionsJson);
      if (readingPositionsMap is Map<String, dynamic>) {
        readingPositions = readingPositionsMap.cast<String, double>();
      }
    }

    readingPositions[filePath] = position;
    await prefs.setString('readingPositions', jsonEncode(readingPositions));
    print('saveReadingPosition $position for $filePath');
  }

  Future<void> getReadingPosition(String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    final readingPositionsJson = prefs.getString('readingPositions');
    if (readingPositionsJson != null) {
      final readingPositions =
          Map<String, dynamic>.from(jsonDecode(readingPositionsJson));
      if (readingPositions.containsKey(filePath)) {
        final position = readingPositions[filePath];
        print('getReadingPosition position $position');
        setState(() {
          lastPosition = position;
          isLast = true;
        });
      }
    }
  }

  void _updateScrollPercentage() async {
    if (_scrollController.position.maxScrollExtent == 0) {
      return;
    }
    double percentage = (_scrollController.position.pixels /
            _scrollController.position.maxScrollExtent) *
        100;
    setState(() {
      _scrollPosition = percentage;
    });
    await saveReadingPosition(
        _scrollController.position.pixels, textes.first.filePath);
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

    List<String> textPages = getPages(getText, pageSize.toInt());
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context, true);
            },
            child: const Icon(CustomIcons.chevronLeft, size: 40)),
        backgroundColor: MyColors.white,
        shadowColor: Colors.transparent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextTektur(
              text: textes.isNotEmpty
                  ? (textes.first.author.toString().length > 8
                      ? (textes.first.title.toString().length > 8
                          ? '${textes[0].author.toString()}. ${textes[0].title.toString().substring(0, 5)}...'
                          : '${textes[0].author.toString()}. ${textes[0].title.toString().substring(0, 5)}...')
                      : textes[0].title.toString())
                  : 'Нет автора',
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
                  CustomIcons.sliders,
                  size: 40,
                ))
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
                    if (textes.isNotEmpty) {
                      return _scrollController.hasClients
                          ? () {
                              if (!isLast) {
                                // Ваш код для скроллинга к позиции чтения
                              }
                              return Center(
                                child: SelectableText(
                                  getText,
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    color: getTextColor,
                                  ),
                                ),
                              );
                            }()
                          : Center(
                              child: SelectableText(
                                'Нет текста для отображения',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: getTextColor,
                                ),
                              ),
                            );
                    }
                    return null;
                  }))),
      bottomNavigationBar: BottomAppBar(
        child: SizedBox(
          height: 30.0,
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
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: TextTektur(
                    text: textes.isNotEmpty
                        ? (textes[0].title.toString().length > 28
                            ? '${textes[0].title.toString().substring(0, 28)}...'
                            : textes[0].title.toString())
                        : 'Нет названия',
                    fontsize: 12,
                    textColor: MyColors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 3, 24, 0),
                child: TextTektur(
                  text: '${_scrollPosition.toStringAsFixed(2)}%',
                  fontsize: 12,
                  textColor: MyColors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
