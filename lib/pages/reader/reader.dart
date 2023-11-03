import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:merlin/UI/icon/custom_icon.dart';
import 'package:merlin/UI/router.dart';
import 'package:merlin/UI/theme/theme.dart';
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

  void setPosZero() {
    lastPosition = 0;
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

  bool visible = false;

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
      final filePath = textes.first.filePath;
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
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Future<void> didChangeDependencies() async {
    final prefs = await SharedPreferences.getInstance();
    final bgColor = prefs.getInt('backgroundColor') ?? MyColors.white.value;
    final textColor = prefs.getInt('textColor') ?? MyColors.black.value;
    getBgcColor = Color(bgColor);
    getTextColor = Color(textColor);
    super.didChangeDependencies();
  }

  Future<void> resetPositionForBook(String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    final readingPositionsJson = prefs.getString('readingPositions');
    Map<String, double> readingPositions = {};

    if (readingPositionsJson != null) {
      final readingPositionsMap = jsonDecode(readingPositionsJson);
      if (readingPositionsMap is Map<String, dynamic>) {
        readingPositions = readingPositionsMap.cast<String, double>();
      }
    }

    readingPositions[filePath] = 0;
    await prefs.setString('readingPositions', jsonEncode(readingPositions));
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
  }

  Future<void> getReadingPosition(String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    final readingPositionsJson = prefs.getString('readingPositions');
    if (readingPositionsJson != null) {
      final readingPositions =
          Map<String, dynamic>.from(jsonDecode(readingPositionsJson));
      if (readingPositions.containsKey(filePath)) {
        final position = readingPositions[filePath];
        setState(() {
          lastPosition = position;
          isLast = true;
          _scrollPosition = position;
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
    if (textes.isEmpty) {
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: 'Нет последней книги',
        toastLength: Toast.LENGTH_SHORT, // Длительность отображения
        gravity: ToastGravity.BOTTOM,
      );
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

  List<DeviceOrientation> orientations = [
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeRight,
  ];

  int currentOrientationIndex = 0;

  void switchOrientation() {
    currentOrientationIndex =
        (currentOrientationIndex + 1) % orientations.length;
    SystemChrome.setPreferredOrientations(
        [orientations[currentOrientationIndex]]);
  }

  @override
  Widget build(BuildContext context) {
    double pageSize = MediaQuery.of(context).size.height * 3;
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    List<String> textPages = getPages(getText, pageSize.toInt());

    if (!visible) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    }


    return Scaffold(
      appBar: visible
          ? PreferredSize(
              preferredSize: Size(MediaQuery.of(context).size.width, 50),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                child: AppBar(
                  leading: GestureDetector(
                      onTap: () {
                        Navigator.pop(context, true);
                      },
                      child: Theme(
                          data: lightTheme(),
                          child: const Icon(
                            CustomIcons.chevronLeft,
                            size: 40,
                            //color: Theme.of(context).iconTheme,
                          ))),
                  backgroundColor: Theme.of(context).primaryColor,
                  shadowColor: Colors.transparent,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextTektur(
                        text: textes.isNotEmpty
                            ? (textes.first.author.toString().length > 8
                                ? (textes.first.title.toString().length > 8
                                    ? '${textes[0].author.toString()}. ${textes[0].title.toString().substring(0, 3)}...'
                                    : '${textes[0].author.toString()}. ${textes[0].title.length >= 4 ? textes[0].title.toString() : textes[0].title.toString()}...')
                                : textes[0].title.toString())
                            : 'Нет автора',
                        fontsize: 18,
                        textColor: MyColors.black,
                        fontWeight: FontWeight.w600,
                      ),
                      GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                                    context, RouteNames.readerSettings)
                                .then((value) => loadStylePreferences());
                          },
                          child: Theme(
                              data: lightTheme(),
                              child: const Icon(
                                CustomIcons.sliders,
                                size: 40,
                                //color: Theme.of(context).iconTheme,
                              )))
                    ],
                  ),
                ),
              ),
            )
          : null,
      body: Container(
        color: getBgcColor,
        child: SafeArea(
          left: false,
          top: false,
          right: false,
          bottom: false,
          minimum: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Stack(
            children: [
              ListView.builder(
                  controller: _scrollController,
                  itemCount: textPages.length,
                  itemBuilder: (context, index) {
                    if (textes.isNotEmpty) {
                      return _scrollController.hasClients
                          ? () {
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
                              child: Text(
                                'Нет текста для отображения',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: getTextColor,
                                ),
                              ),
                            );
                    }
                    return null;
                  }),
              GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    // Скролл вниз / следующая страница
                    _scrollController.animateTo(
                        _scrollController.position.pixels + screenHeight * 0.8,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.ease);
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: IgnorePointer(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        color: const Color.fromRGBO(100, 150, 100, 0),
                      ),
                    ),
                  )),
              Positioned(
                left: screenWidth / 6,
                top: screenHeight / 5,
                child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onDoubleTap: () {
                      // Режим слова
                      Fluttertoast.showToast(
                        msg: 'Здесь будет режим слова',
                        toastLength:
                            Toast.LENGTH_SHORT, // Длительность отображения
                        gravity: ToastGravity.BOTTOM,
                      );
                    },
                    onTap: () {
                      setState(() {
                        visible = !visible;
                      });
                      if (visible) {
                        SystemChrome.setSystemUIOverlayStyle(
                            const SystemUiOverlayStyle(
                                systemNavigationBarColor: MyColors.white,
                                statusBarColor: Colors.transparent));
                        SystemChrome.setEnabledSystemUIMode(
                            SystemUiMode.edgeToEdge);
                      } else {
                        SystemChrome.setEnabledSystemUIMode(
                            SystemUiMode.immersive);
                      }
                    },
                    child: IgnorePointer(
                      child: Container(
                        width: MediaQuery.of(context).size.width / 1.5,
                        height: MediaQuery.of(context).size.height / 2,
                        color: const Color.fromRGBO(250, 100, 100, 0),
                      ),
                    )),
              ),
              Positioned(
                left: screenWidth / 6,
                child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      // Сролл вверх / предыдущая страница
                      _scrollController.animateTo(
                          _scrollController.position.pixels -
                              screenHeight * 0.8,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.ease);
                    },
                    child: IgnorePointer(
                      child: Container(
                        width: MediaQuery.of(context).size.width / 1.5,
                        height: MediaQuery.of(context).size.height / 5,
                        color: const Color.fromRGBO(100, 150, 200, 0),
                      ),
                    )),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: visible ? 130 : 30,
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
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: visible ? 100 : 0,
                  child: Container(
                      alignment: AlignmentDirectional.topEnd,
                      color: MyColors.white,
                      child: Column(
                        children: [
                          _scrollController.hasClients
                              ? Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 0, 16, 0),
                                  child: Slider(
                                    value: _scrollController.position.pixels,
                                    min: 0,
                                    max: _scrollController
                                        .position.maxScrollExtent,
                                    onChanged: (value) {
                                      _scrollController.jumpTo(value);
                                    },
                                    activeColor:
                                        const Color.fromRGBO(29, 29, 33, 1),
                                    inactiveColor:
                                        const Color.fromRGBO(96, 96, 96, 1),
                                    thumbColor:
                                        const Color.fromRGBO(29, 29, 33, 1),
                                  ),
                                )
                              : const Text("Загрузка..."),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  switchOrientation();
                                },
                                child: const Icon(
                                  CustomIcons.turn,
                                  size: 40,
                                ),
                              ),
                              const Icon(
                                CustomIcons.theme,
                                size: 40,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Fluttertoast.showToast(
                                    msg: 'Здесь будет режим слова',
                                    toastLength: Toast
                                        .LENGTH_SHORT, // Длительность отображения
                                    gravity: ToastGravity.BOTTOM,
                                  );
                                },
                                child: const Icon(
                                  CustomIcons.wm,
                                  size: 40,
                                ),
                              )
                            ],
                          )
                        ],
                      ))),
            )
          ],
        ),
      ),
    );
  }
}
