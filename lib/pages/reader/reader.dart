// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:merlin/UI/icon/custom_icon.dart';
import 'package:merlin/UI/router.dart';
import 'package:merlin/UI/theme/theme.dart';
import 'package:merlin/domain/data_providers/color_provider.dart';
import 'package:merlin/functions/post_statistic.dart';
import 'package:merlin/main.dart';
import 'package:merlin/pages/wordmode/models/word_entry.dart';
import 'package:merlin/pages/wordmode/wordmode.dart';
import 'package:merlin/style/colors.dart';
import 'package:merlin/style/text.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:battery/battery.dart';
import 'package:merlin/pages/recent/recent.dart' as recent;

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
  double position = 0;
  bool isLast = false;
  List<recent.ImageInfo> images = [];
  int pageCount = 0;
  int lastPageCount = 0;
  double pageSize = 0;
  Timer? _actionTimer;
  bool? isTrans = false;
  bool isBorder = false;

  double _scrollPosition = 0.0;

  bool visible = false;

  double fontSize = 18;

  void _getBatteryLevel() async {
    final batteryLevel = await _battery.batteryLevel;
    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  void saveDateTime(double pageSize) async {
    final prefs = await SharedPreferences.getInstance();
    DateTime currentTime = DateTime.now();
    prefs.setString('savedDateTime', currentTime.toIso8601String());
    prefs.setDouble('pageSize', pageSize);
  }

  @override
  void initState() {
    getDataFromLocalStorage('textKey');
    getImagesFromLocalStorage('booksKey');

    _getBatteryLevel();
    _scrollController.addListener(_updateScrollPercentage);

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      lastPageCount = prefs.getInt('pageCount-${textes.first.filePath}') ?? 0;
      prefs.setInt('lastPageCount-${textes.first.filePath}', lastPageCount);
      print('initState lastPageCount $lastPageCount');
      final filePath = textes.first.filePath;
      pageSize = MediaQuery.of(context).size.height;
      print('pageSize = $pageSize');
      saveDateTime(pageSize);
      final readingPositionsJson = prefs.getString('readingPositions');
      isTrans = prefs.getBool('${textes.first.filePath}-isTrans');
      setState(() {
        isTrans;
      });
      if (isTrans != null && isTrans == true) {
        var temp = await loadWordCountFromLocalStorage(textes.first.filePath);
        replaceWordsWithTranslation(temp.wordEntries);
      }
      if (readingPositionsJson != null) {
        final readingPositions = jsonDecode(readingPositionsJson);
        if (readingPositions.containsKey(filePath)) {
          lastPosition = readingPositions[filePath];
          Future.delayed(const Duration(milliseconds: 200), () {
            if (_scrollController.hasClients) {
              // _scrollController.animateTo(
              //   lastPosition,
              //   duration: const Duration(milliseconds: 100),
              //   curve: Curves.linear,
              // );
              _scrollController.jumpTo(lastPosition);
            }
          });
          setState(() {
            isLast = true;
            pageSize = MediaQuery.of(context).size.height / 5.35;
            position = _scrollController.position.pixels;
          });
        }
      }
      _loadPageCountFromLocalStorage();
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([orientations[0]]);
    getPageCount();
    super.dispose();
  }

  @override
  Future<void> didChangeDependencies() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
    loadStylePreferences();
    super.didChangeDependencies();
  }

  Future<void> _loadPageCountFromLocalStorage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      pageCount = (prefs.getInt('pageCount-${textes.first.filePath}') ?? 0);
      // print('pageCount-${textes.first.filePath}');
    });
  }

  Future<void> _savePageCountToLocalStorage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    pageCount = ((_scrollController.position.pixels / _scrollController.position.maxScrollExtent) *
            (_scrollController.position.maxScrollExtent / MediaQuery.of(context).size.height))
        .toInt();
    print(pageCount);
    prefs.setInt('pageCount-${textes.first.filePath}', pageCount);
  }

  bool _isDarkTheme = false;

  bool get isDarkTheme => _isDarkTheme;

  set isDarkTheme(bool value) {
    _isDarkTheme = value;
    setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: value ? MyColors.blackGray : MyColors.white,
    ));
  }

  void setSystemUIOverlayStyle(SystemUiOverlayStyle style) {
    SystemChrome.setSystemUIOverlayStyle(style);
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

  Future<void> getImagesFromLocalStorage(String key) async {
    final prefs = await SharedPreferences.getInstance();
    String? imageDataJson = prefs.getString(key);
    if (imageDataJson != null) {
      images = (jsonDecode(imageDataJson) as List).map((item) => recent.ImageInfo.fromJson(item)).toList();
      setState(() {});
    }
  }

  Future<void> saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    images.firstWhere((element) => element.fileName == textes.first.filePath).progress =
        _scrollController.position.pixels / _scrollController.position.maxScrollExtent;
    setState(() {});
    await prefs.setString('booksKey', jsonEncode(images));
    // print('SUCCESS PROGRESS');
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
      final readingPositions = Map<String, dynamic>.from(jsonDecode(readingPositionsJson));
      if (readingPositions.containsKey(filePath)) {
        setState(() {
          position = readingPositions[filePath];
          // print('getReadingPosition position $position');
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
    double percentage = (_scrollController.position.pixels / _scrollController.position.maxScrollExtent) * 100;
    setState(() {
      _scrollPosition = percentage;
      position = _scrollController.position.pixels;
      // print(position);
      // print(percentage);
      // print('max = ${_scrollController.position.maxScrollExtent}');
      // print(' ');
      _savePageCountToLocalStorage();
      print('lastPageCount $lastPageCount');
      print('pageCount $pageCount');
    });
    await saveReadingPosition(_scrollController.position.pixels, textes.first.filePath);
  }

  Color textColor = MyColors.black;
  Color backgroundColor = MyColors.white;
  final ColorProvider _colorProvider = ColorProvider();

  Future<void> loadStylePreferences() async {
    final backgroundColorFromStorage = await _colorProvider.getColor(ColorKeys.readerBackgroundColor);
    final textColorFromStorage = await _colorProvider.getColor(ColorKeys.readerTextColor);
    final prefs = await SharedPreferences.getInstance();

    final fontSizeFromStorage = prefs.getDouble('fontSize');
    setState(() {
      if (backgroundColorFromStorage != null) {
        backgroundColor = backgroundColorFromStorage;
      }
      if (textColorFromStorage != null) {
        textColor = textColorFromStorage;
      }
      if (fontSizeFromStorage != null) {
        fontSize = fontSizeFromStorage;
      }
    });
  }

  String getText = "";
  List<BookInfo> textes = [];

  Future<void> getDataFromLocalStorage(String key) async {
    getText = "";
    final prefs = await SharedPreferences.getInstance();
    String? textDataJson = prefs.getString(key);
    if (textDataJson != null) {
      textes = (jsonDecode(textDataJson) as List).map((item) => BookInfo.fromJson(item)).toList();
      setState(() {});
    }
    if (textes.isEmpty) {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: 'Нет последней книги',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }

    setState(() {
      getText = textes[0].fileText.toString().replaceAll(RegExp(r'\['), '').replaceAll(RegExp(r'\]'), '');
    });
  }

  List<DeviceOrientation> orientations = [
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeRight,
  ];

  int currentOrientationIndex = 0;

  void switchOrientation() {
    currentOrientationIndex = (currentOrientationIndex + 1) % orientations.length;
    SystemChrome.setPreferredOrientations([orientations[currentOrientationIndex]]);
  }

  // Метод для объединения прошлых и новых слов
  // Future<void> saveWordCountToLocalstorage(WordCount newWordCount) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   String key = '${newWordCount.filePath}-words';

  //   // Загрузка и декодирование существующих данных, если они есть.
  //   String? storedData = prefs.getString(key);
  //   List<WordCount> wordDatas = storedData != null
  //       ? (jsonDecode(storedData) as List)
  //           .map((item) => WordCount.fromJson(item))
  //           .toList()
  //       : [];

  //   // Поиск существующего WordCount.
  //   int index = wordDatas
  //       .indexWhere((element) => element.filePath == newWordCount.filePath);
  //   if (index != -1) {
  //     // Объединение новых слов с существующими.
  //     wordDatas[index].wordEntries = [
  //       ...wordDatas[index].wordEntries,
  //       ...newWordCount.wordEntries
  //     ];
  //   } else {
  //     // Добавление нового WordCount, если он не найден.
  //     wordDatas.add(newWordCount);
  //   }

  //   // Сериализация обновлённого списка в JSON и сохранение.
  //   String wordDatasString = jsonEncode(wordDatas);
  //   await prefs.setString(key, wordDatasString);
  // }

  Future<void> saveWordCountToLocalstorage(WordCount wordCount) async {
    final prefs = await SharedPreferences.getInstance();
    String key = '${wordCount.filePath}-words';

    // Загрузка и декодирование существующих данных, если они есть.
    String? storedData = prefs.getString(key);
    List<WordCount> wordDatas = storedData != null ? (jsonDecode(storedData) as List).map((item) => WordCount.fromJson(item)).toList() : [];

    // Поиск и обновление существующего WordCount, если он есть, иначе добавление нового.
    int index = wordDatas.indexWhere((element) => element.filePath == wordCount.filePath);
    if (index != -1) {
      wordDatas[index] = wordCount; // Обновление существующего WordCount
    } else {
      wordDatas.add(wordCount); // Добавление нового WordCount
    }

    // Сериализация обновлённого списка в JSON и сохранение.
    String wordDatasString = jsonEncode(wordDatas);
    await prefs.setString(key, wordDatasString);
  }

  Future<WordCount> loadWordCountFromLocalStorage(String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    String? storedData = prefs.getString('$filePath-words');
    if (storedData != null) {
      List<dynamic> decodedData = jsonDecode(storedData);
      WordCount wordCount = WordCount.fromJson(decodedData[0]);
      return wordCount;
    } else {
      return WordCount();
    }
  }

  void replaceWordsWithTranslation(List<WordEntry> wordEntries) async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setBool('${textes.first.filePath}-isTrans', true);
    isBorder = true;
    var lastCallTranslateStr = prefs.getString('lastCallTranslate');
    if (lastCallTranslateStr != null) {
      final now = DateTime.now();
      DateTime? lastCallTranslateStamp = lastCallTranslateStr != null ? DateTime.parse(lastCallTranslateStr) : null;
      final timeElapsed = now.difference(lastCallTranslateStamp!);
      if (timeElapsed.inMilliseconds >= 1) {
        await getDataFromLocalStorage('textKey');
      }
    }
    // Копируем исходный текст в мутабельную переменную для замен
    String updatedText = getText;

    // Перебираем список слов
    for (var entry in wordEntries) {
      // Печатаем, какое слово мы ищем
      print('Ищем слово: ${entry.word}');

      // Создаем регулярное выражение для поиска слова в тексте
      final wordRegExp = RegExp(entry.word, caseSensitive: false, unicode: true);

      // Ищем совпадения и заменяем каждое из них
      updatedText = updatedText.replaceAllMapped(wordRegExp, (match) {
        // Выводим найденные совпадения
        final matchedWord = match.group(0)!;
        print('Найдено совпадение: $matchedWord');
        // Заменяем слово, сохраняя исходный регистр
        return matchCase(matchedWord, entry.translation ?? '');
      });
    }

    await prefs.setString('lastCallTranslate', DateTime.now().toIso8601String());
    isTrans = prefs.getBool('${textes.first.filePath}-isTrans');
    print(isTrans);
    setState(() {
      getText = updatedText;
      isTrans;
    });
  }

  String matchCase(String source, String pattern) {
    // Сохраняем регистр первой буквы исходного слова
    if (source[0] == source[0].toUpperCase()) {
      return pattern[0].toUpperCase() + pattern.substring(1).toLowerCase();
    }
    // Если весь текст в верхнем регистре - перевод тоже
    if (source.toUpperCase() == source) {
      return pattern.toUpperCase();
    }
    // Иначе возвращаем перевод в нижнем регистре
    return pattern.toLowerCase();
  }

  Future<void> showTableDialog(BuildContext context, WordCount wordCount) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return FutureBuilder(
          future: wordCount.checkCallInfo(),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: MyColors.purple,
                ),
              );
            } else if (snapshot.hasError) {
              return const AlertDialog(
                content: Text('Произошла ошибка: нет доступа к интернету'),
              );
            } else {
              if (wordCount.wordEntries.isEmpty) {
                Navigator.pop(context);
              }

              return WillPopScope(
                onWillPop: () async {
                  // debugPrint("DONE");
                  await saveWordCountToLocalstorage(wordCount);
                  return true;
                },
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.8,
                    ),
                    child: ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(0),
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width,
                          color: Colors.transparent,
                          child: Card(
                            child: Column(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                                      icon: const Icon(Icons.close),
                                      onPressed: () async {
                                        // debugPrint("DONE");
                                        await saveWordCountToLocalstorage(wordCount);
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 40),
                                  child: Center(
                                    child: Text24(
                                      text: 'Выберите слова',
                                      textColor: MyColors.black,
                                    ),
                                  ),
                                ),
                                DataTable(
                                  columnSpacing: 38.0,
                                  showBottomBorder: false,
                                  dataTextStyle: const TextStyle(fontFamily: 'Roboto', color: MyColors.black),
                                  columns: const [
                                    DataColumn(
                                      label: Expanded(
                                        child: Text16(
                                          text: 'Слово',
                                          textColor: MyColors.black,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Expanded(
                                        child: Text16(
                                          text: 'Произношение',
                                          textColor: MyColors.black,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Expanded(
                                        child: Text16(
                                          text: 'Перевод',
                                          textColor: MyColors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                  rows: wordCount.wordEntries.map((entry) {
                                    return DataRow(
                                      cells: [
                                        DataCell(InkWell(
                                          onTap: () async {
                                            await _showWordInputDialog(entry.word, wordCount.wordEntries);
                                            setState(() {
                                              entry.word;
                                              entry.count;
                                              entry.ipa;
                                            });
                                          },
                                          child: TextForTable(
                                            text: entry.word,
                                            textColor: MyColors.black,
                                          ),
                                        )),
                                        DataCell(
                                          ConstrainedBox(
                                            constraints: BoxConstraints(
                                              maxWidth: MediaQuery.of(context).size.width * 0.25,
                                            ),
                                            child: TextForTable(
                                              text: '[ ${entry.ipa} ]',
                                              textColor: MyColors.black,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          ConstrainedBox(
                                            constraints: BoxConstraints(
                                              maxWidth: MediaQuery.of(context).size.width * 0.25,
                                            ),
                                            child: TextForTable(
                                              text: entry.translation!.isNotEmpty ? entry.translation! : 'N/A',
                                              textColor: MyColors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                                // TextButton(
                                //     onPressed: () async {
                                //       await saveWordCountToLocalstorage(wordCount);
                                //       replaceWordsWithTranslation(wordCount.wordEntries);
                                //       Navigator.pop(context);
                                //     },
                                //     child: const Text16(
                                //       text: 'Сохранить',
                                //       textColor: MyColors.black,
                                //     ))
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }

  String getWordForm(int number) {
    int lastDigit = number % 10;
    int lastTwoDigits = number % 100;

    if (lastTwoDigits > 10 && lastTwoDigits < 15) {
      return 'слов';
    } else if (lastDigit == 1) {
      return 'слово';
    } else if (lastDigit > 1 && lastDigit < 5) {
      return 'слова';
    } else if (number > 1 && number < 5) {
      return 'слова';
    } else {
      return 'слов';
    }
  }

  showEmptyTable(BuildContext context, WordCount wordCount) async {
    final prefs = await SharedPreferences.getInstance();
    final lastCallTimestampStr = prefs.getString('lastCallTimestamp');
    DateTime? lastCallTimestamp;
    Duration timeElapsed;
    lastCallTimestamp = lastCallTimestampStr != null ? DateTime.parse(lastCallTimestampStr) : null;

    final now = DateTime.now();
    final oneDayMore = now.add(const Duration(days: 1));
    if (lastCallTimestamp != null) {
      timeElapsed = now.difference(lastCallTimestamp);
    } else {
      timeElapsed = now.difference(oneDayMore);
    }
    int getWords = prefs.getInt('words') ?? 10;
    print('showEmptyTable getWords = $getWords');
    // print('lastCallTimestampStr $lastCallTimestampStr');
    // print('lastCallTimestamp $lastCallTimestamp');
    // print('now $now');
    // print('timeElapsed $timeElapsed');
    // if (timeElapsed.inHours >= 24 && wordCount.wordEntries.length <= getWords ||
    if (timeElapsed.inMilliseconds >= 1 && wordCount.wordEntries.length <= getWords || lastCallTimestampStr == null) {
      // print('Entered');
      String screenWord = getWordForm(getWords - wordCount.wordEntries.length);
      var lastCallTimestamp = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastCallTimestamp', lastCallTimestamp.toIso8601String());

      showDialog<void>(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            screenWord = getWordForm(getWords - wordCount.wordEntries.length);

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(0),
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width,
                      color: Colors.transparent,
                      child: Card(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            IconButton(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Center(
                                child: Text24(
                                  text: wordCount.wordEntries.length < 10
                                      ? 'Осталось добавить ${(getWords - wordCount.wordEntries.length)} $screenWord'
                                      : 'Изучаемые слова',
                                  textColor: MyColors.black,
                                ),
                              ),
                            ),
                            DataTable(
                              columnSpacing: 38.0,
                              showBottomBorder: false,
                              dataTextStyle: const TextStyle(fontFamily: 'Roboto', color: MyColors.black),
                              columns: const [
                                DataColumn(
                                  label: Expanded(
                                    child: Text16(
                                      text: 'Слово',
                                      textColor: MyColors.black,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Expanded(
                                    child: Text16(
                                      text: 'Произношение',
                                      textColor: MyColors.black,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Expanded(
                                    child: Text16(
                                      text: 'Перевод',
                                      textColor: MyColors.black,
                                    ),
                                  ),
                                ),
                              ],
                              rows: wordCount.wordEntries.map((entry) {
                                return DataRow(
                                  cells: [
                                    DataCell(InkWell(
                                      onTap: () async {
                                        await _showWordInputDialog(entry.word, wordCount.wordEntries);
                                        setState(() {
                                          entry.word;
                                          entry.count;
                                          entry.ipa;
                                        });
                                      },
                                      child: TextForTable(
                                        text: entry.word,
                                        textColor: MyColors.black,
                                      ),
                                    )),
                                    DataCell(
                                      ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context).size.width * 0.25,
                                        ),
                                        child: TextForTable(
                                          text: '[ ${entry.ipa} ]',
                                          textColor: MyColors.black,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context).size.width * 0.25,
                                        ),
                                        child: TextForTable(
                                          text: entry.translation!.isNotEmpty ? entry.translation! : 'N/A',
                                          textColor: MyColors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                            wordCount.wordEntries.length < 10
                                ? TextButton(
                                    onPressed: () async {
                                      await addNewWord(wordCount.wordEntries, wordCount, wordCount.wordEntries.length);
                                    },
                                    child: const Text16(
                                      text: 'Добавить',
                                      textColor: MyColors.black,
                                    ))
                                : TextButton(
                                    onPressed: () async {
                                      await saveWordCountToLocalstorage(wordCount);
                                      replaceWordsWithTranslation(wordCount.wordEntries);
                                      Navigator.pop(context);
                                    },
                                    child: const Text16(
                                      text: 'Сохранить',
                                      textColor: MyColors.black,
                                    ))
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
    } else {
      Fluttertoast.showToast(
        msg: 'Можно только раз в 24 часа!',
        toastLength: Toast.LENGTH_SHORT, // Длительность отображения
        gravity: ToastGravity.BOTTOM, // Расположение уведомления
      );
      return;
    }
  }

  Future<void> showSavedWords(BuildContext context, String filePath) async {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return FutureBuilder<WordCount>(
          future: loadWordCountFromLocalStorage(filePath),
          builder: (BuildContext context, AsyncSnapshot<WordCount> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: MyColors.purple,
                ),
              );
            } else if (snapshot.hasError) {
              return AlertDialog(
                content: Text('Error: ${snapshot.error}'),
              );
            } else if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                WordCount? wordCount = snapshot.data;
                // debugPrint('Getted wordCount $wordCount');
                if (wordCount == null || wordCount.wordEntries.isEmpty) {
                  Fluttertoast.showToast(
                    msg: 'Нет сохраненных слов',
                    toastLength: Toast.LENGTH_SHORT, // Длительность отображения
                    gravity: ToastGravity.BOTTOM,
                  );
                  Navigator.pop(context);
                  return const SizedBox.shrink();
                }
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.8,
                    ),
                    child: ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(0),
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width,
                          color: Colors.transparent,
                          child: Card(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                IconButton(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 20),
                                  child: Center(
                                    child: Text24(
                                      text: 'Изучаемые слова',
                                      textColor: MyColors.black,
                                    ),
                                  ),
                                ),
                                DataTable(
                                  columnSpacing: 38.0,
                                  showBottomBorder: false,
                                  dataTextStyle: const TextStyle(fontFamily: 'Roboto', color: MyColors.black),
                                  columns: const [
                                    DataColumn(
                                      label: Expanded(
                                        child: Text16(
                                          text: 'Слово',
                                          textColor: MyColors.black,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Expanded(
                                        child: Text16(
                                          text: 'Произношение',
                                          textColor: MyColors.black,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Expanded(
                                        child: Text16(
                                          text: 'Перевод',
                                          textColor: MyColors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                  rows: wordCount.wordEntries.map((entry) {
                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          ConstrainedBox(
                                            constraints: BoxConstraints(
                                              maxWidth: MediaQuery.of(context).size.width * 0.25,
                                            ),
                                            child: TextForTable(
                                              text: entry.word,
                                              textColor: MyColors.black,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          ConstrainedBox(
                                            constraints: BoxConstraints(
                                              maxWidth: MediaQuery.of(context).size.width * 0.25,
                                            ),
                                            child: TextForTable(
                                              text: '[ ${entry.ipa} ]',
                                              textColor: MyColors.black,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          ConstrainedBox(
                                            constraints: BoxConstraints(
                                              maxWidth: MediaQuery.of(context).size.width * 0.25,
                                            ),
                                            child: TextForTable(
                                              text: entry.translation!.isNotEmpty ? entry.translation! : 'N/A',
                                              textColor: MyColors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                                // TextButton(
                                //     onPressed: () {
                                //       Navigator.pop(context);
                                //     },
                                //     child: const Text16(
                                //       text: 'Закрыть',
                                //       textColor: MyColors.black,
                                //     ))
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return const Center(
                  child: Text('No data available.'),
                );
              }
            } else {
              return const Center(
                child: Text('Unexpected state.'),
              );
            }
          },
        );
      },
    );
  }

  void wordModeDialog(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    int getWords = prefs.getInt('words') ?? 10;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AgreementDialog(
        getWords: getWords,
      ),
    );

    if (result == true) {
      // Действие, выполняемое после нажатия "Да"

      final wordCount = WordCount(filePath: textes.first.filePath, fileText: textes.first.fileText);
      await showEmptyTable(context, wordCount);
    } else if (result == false) {
      // Действие, выполняемое после нажатия "Нет"
      final wordCount = WordCount(filePath: textes.first.filePath, fileText: textes.first.fileText);
      // Если нужно сбросить счётчик времени
      // await wordCount.resetCallCount();
      // await wordCount.checkCallInfo();
      await showTableDialog(context, wordCount);
    }
  }

  Future<void> _showWordInputDialog(String word, List<WordEntry> wordEntries) async {
    List<String> words = WordCount(filePath: textes.first.filePath, fileText: textes.first.fileText).getAllWords();
    Set<String> uniqueSet = <String>{};
    List<String> result = [];
    for (String item in words.reversed) {
      if (uniqueSet.add(item)) {
        result.add(item);
      }
    }
    result.reversed.toList();
    showDialog(
      context: context,
      builder: (context) {
        String newWord = word;

        return AlertDialog(
          title: const Text('Изменить слово'),
          content: Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text == '') {
                return const Iterable<String>.empty();
              }
              String pattern = textEditingValue.text.toLowerCase();
              final Iterable<String> matchingStart = result.where((String option) {
                return option.toLowerCase().startsWith(pattern);
              });
              final Iterable<String> matchingAll = result.where((String option) {
                return option.toLowerCase().contains(pattern) && !option.toLowerCase().startsWith(pattern);
              });
              return matchingStart.followedBy(matchingAll);
            },
            onSelected: (String selection) {
              // debugPrint('You just selected $selection');
              newWord = selection;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text16(text: 'Отмена', textColor: MyColors.black),
            ),
            TextButton(
              onPressed: () async {
                // debugPrint('Введенное слово: $newWord');
                // debugPrint('onPressed word: $word');
                if (result.contains(newWord)) {
                  await updateWordInTable(word, newWord, wordEntries);
                  Navigator.of(context).pop();
                } else {
                  Fluttertoast.showToast(
                    msg: 'Введенного слова нет в книге',
                    toastLength: Toast.LENGTH_SHORT, // Длительность отображения
                    gravity: ToastGravity.BOTTOM,
                  );
                }
              },
              child: const Text16(text: 'Сохранить', textColor: MyColors.black),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateWordInTable(String oldWord, String newWord, List<WordEntry> wordEntries) async {
    final index = wordEntries.indexWhere((entry) => entry.word == oldWord);
    if (index != -1) {
      final count = WordCount(filePath: textes.first.filePath, fileText: textes.first.fileText).getWordCount(newWord);
      // debugPrint('updateWordInTable entry ${wordEntries[index]}');
      // debugPrint('updateWordInTable count ${wordEntries[index].count}');
      final translation = await WordCount(filePath: textes.first.filePath, fileText: textes.first.fileText).translateToEnglish(newWord);
      final ipa = await WordCount(filePath: textes.first.filePath, fileText: textes.first.fileText).getIPA(translation!);

      wordEntries[index] = WordEntry(
        word: newWord,
        count: count,
        translation: translation,
        ipa: ipa, // Обновите IPA
      );

      setState(() {});
    } else {
      // debugPrint('Word $oldWord not found in the list.');
    }
  }

  Future<void> addNewWord(List<WordEntry> wordEntries, WordCount wordCount, int length) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> words = WordCount(filePath: textes.first.filePath, fileText: textes.first.fileText).getAllWords();
    Set<String> uniqueSet = <String>{};
    List<String> result = [];
    for (String item in words.reversed) {
      if (uniqueSet.add(item)) {
        result.add(item);
      }
    }
    String newWord = '';
    result.reversed.toList();
    int getWords = prefs.getInt('words') ?? 10;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Добавить слово'),
          content: Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text == '') {
                return const Iterable<String>.empty();
              }
              String pattern = textEditingValue.text.toLowerCase();
              final Iterable<String> matchingStart = result.where((String option) {
                return option.toLowerCase().startsWith(pattern);
              });
              final Iterable<String> matchingAll = result.where((String option) {
                return option.toLowerCase().contains(pattern) && !option.toLowerCase().startsWith(pattern);
              });
              return matchingStart.followedBy(matchingAll);
            },
            onSelected: (String selection) {
              // debugPrint('You just selected $selection');
              newWord = selection;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text16(text: 'Отмена', textColor: MyColors.black),
            ),
            TextButton(
              onPressed: () async {
                if (length < getWords) {
                  if (result.contains(newWord)) {
                    WordCount wordProcessor = WordCount();

                    List<WordEntry> updatedWordEntries = await wordProcessor.processSingleWord(newWord, wordCount.wordEntries);

                    setState(() {
                      wordCount.wordEntries = updatedWordEntries;
                    });
                    Navigator.of(context).pop();
                  } else {
                    Fluttertoast.showToast(
                      msg: 'Введенного слова нет в книге!',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                  }
                } else {
                  Fluttertoast.showToast(
                    msg: 'Достигнут лимит слов!',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
                }
              },
              child: const Text16(text: 'Сохранить', textColor: MyColors.black),
            ),
          ],
        );
      },
    );
  }

  Future<void> saveSettings(bool isDarkTheme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', isDarkTheme);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await saveProgress();
        await _savePageCountToLocalStorage();
        Navigator.pop(context, true);
        return true;
      },
      child: Scaffold(
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
                              child: Icon(
                                CustomIcons.chevronLeft,
                                size: 30,
                                color: Theme.of(context).iconTheme.color,
                              ))),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shadowColor: Colors.transparent,
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              clipBehavior: Clip.antiAlias,
                              child: Text(
                                textes.isNotEmpty ? '${textes[0].author.toString()}. ${textes[0].title.toString()}' : 'Нет автора',
                                softWrap: false,
                                overflow: TextOverflow.fade,
                                style: TextStyle(fontSize: 16, fontFamily: 'Tektur', color: isDarkTheme ? MyColors.white : MyColors.black),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, RouteNames.readerSettings).then((value) => loadStylePreferences());
                            },
                            child: Icon(
                              CustomIcons.sliders,
                              size: 30,
                              color: Theme.of(context).iconTheme.color,
                            ),
                          ),
                        ],
                      )),
                ),
              )
            : null,
        body: Container(
            decoration: BoxDecoration(
                color: backgroundColor,
                border: isBorder == true
                    ? Border.all(color: const Color.fromRGBO(0, 255, 163, 1), width: 4)
                    : Border.all(width: 0, color: Colors.transparent)),
            child: Stack(children: [
              SafeArea(
                top: false,
                minimum: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                child: ListView.builder(
                    controller: _scrollController,
                    itemCount: 1,
                    itemBuilder: (context, index) {
                      if (textes.isNotEmpty) {
                        return _scrollController.hasClients
                            ? () {
                                return Text(
                                  getText,
                                  // textAlign: TextAlign.justify,
                                  // textAlign: TextAlign.center,
                                  softWrap: true,
                                  style: TextStyle(fontSize: fontSize, color: textColor, height: 1.41, locale: const Locale('ru', 'RU')),
                                );
                              }()
                            : Center(
                                child: Text(
                                  'Нет текста для отображения',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    color: textColor,
                                  ),
                                ),
                              );
                      }
                      return null;
                    }),
              ),
              GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    // Скролл вниз / следующая страница
                    _scrollController.animateTo(_scrollController.position.pixels + MediaQuery.of(context).size.height * 0.8,
                        duration: const Duration(milliseconds: 250), curve: Curves.ease);
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
              isBorder
                  ? Positioned(
                      left: isBorder ? MediaQuery.of(context).size.width / 4.5 : MediaQuery.of(context).size.width / 6,
                      top: isBorder ? MediaQuery.of(context).size.height / 4.5 : MediaQuery.of(context).size.height / 5,
                      child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onDoubleTap: () async {
                            showSavedWords(context, textes.first.filePath);
                          },
                          onVerticalDragEnd: (dragEndDetails) async {
                            if (dragEndDetails.primaryVelocity! > 0) {
                              showSavedWords(context, textes.first.filePath);
                            }
                          },
                          onTap: () {
                            setState(() {
                              visible = !visible;
                            });
                            if (visible) {
                              SystemChrome.setSystemUIOverlayStyle(
                                  const SystemUiOverlayStyle(systemNavigationBarColor: Colors.transparent, statusBarColor: Colors.transparent));
                              SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
                            } else {
                              SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
                            }
                          },
                          child: IgnorePointer(
                            child: Container(
                              width: isBorder ? MediaQuery.of(context).size.width / 2 : MediaQuery.of(context).size.width / 1.5,
                              height: isBorder ? MediaQuery.of(context).size.height / 2.5 : MediaQuery.of(context).size.height / 2,
                              color: const Color.fromRGBO(250, 100, 100, 0),
                            ),
                          )),
                    )
                  : Positioned(
                      left: isBorder ? MediaQuery.of(context).size.width / 4.5 : MediaQuery.of(context).size.width / 6,
                      top: isBorder ? MediaQuery.of(context).size.height / 4.5 : MediaQuery.of(context).size.height / 5,
                      child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onDoubleTap: () async {
                            showSavedWords(context, textes.first.filePath);
                          },
                          onTap: () {
                            setState(() {
                              visible = !visible;
                            });
                            if (visible) {
                              SystemChrome.setSystemUIOverlayStyle(
                                  const SystemUiOverlayStyle(systemNavigationBarColor: Colors.transparent, statusBarColor: Colors.transparent));
                              SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
                            } else {
                              SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
                            }
                          },
                          child: IgnorePointer(
                            child: Container(
                              width: isBorder ? MediaQuery.of(context).size.width / 2 : MediaQuery.of(context).size.width / 1.5,
                              height: isBorder ? MediaQuery.of(context).size.height / 2.5 : MediaQuery.of(context).size.height / 2,
                              color: const Color.fromRGBO(250, 100, 100, 0),
                            ),
                          )),
                    ),
              Positioned(
                left: MediaQuery.of(context).size.width / 6,
                child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      // Сролл вверх / предыдущая страница
                      _scrollController.animateTo(_scrollController.position.pixels - MediaQuery.of(context).size.height * 0.8,
                          duration: const Duration(milliseconds: 250), curve: Curves.ease);
                    },
                    child: IgnorePointer(
                      child: Container(
                        width: MediaQuery.of(context).size.width / 1.5,
                        height: MediaQuery.of(context).size.height / 5,
                        color: const Color.fromRGBO(100, 150, 200, 0),
                      ),
                    )),
              ),
            ])),
        bottomNavigationBar: BottomAppBar(
          color: Theme.of(context).colorScheme.primary,
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: visible ? 100 : 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: !visible
                      ? [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 0, 0, 0),
                            child: Container(
                              width: MediaQuery.of(context).size.width / 8,
                              alignment: Alignment.topLeft,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Transform.rotate(
                                    angle: 90 * 3.14159265 / 180,
                                    child: Icon(
                                      Icons.battery_full,
                                      color: Theme.of(context).iconTheme.color,
                                      size: 24,
                                    ),
                                  ),
                                  Text7(
                                    text: '${_batteryLevel.toString()}%',
                                    textColor: MyColors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Text12(
                                  text: textes.isNotEmpty
                                      ? (textes[0].title.toString().length > 28
                                          ? '${textes[0].title.toString().substring(0, 28)}...'
                                          : textes[0].title.toString())
                                      : 'Нет названия',
                                  textColor: MyColors.black,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 3, 24, 0),
                            child: Container(
                              width: MediaQuery.of(context).size.width / 8,
                              alignment: Alignment.topRight,
                              child: Text12(
                                text: '${_scrollPosition.toStringAsFixed(2)}%',
                                textColor: MyColors.black,
                              ),
                            ),
                          ),
                        ]
                      : [],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: visible ? 90 : 0,
                    child: Container(
                        alignment: AlignmentDirectional.topEnd,
                        color: Theme.of(context).colorScheme.primary,
                        child: Column(
                          children: [
                            _scrollController.hasClients
                                ? Padding(
                                    padding: const EdgeInsets.fromLTRB(8, 0, 28, 0),
                                    child: SliderTheme(
                                      data: const SliderThemeData(showValueIndicator: ShowValueIndicator.always),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Expanded(
                                            child: Slider(
                                              value: position != 0
                                                  ? position > _scrollController.position.maxScrollExtent
                                                      ? _scrollController.position.maxScrollExtent
                                                      : position
                                                  : _scrollController.position.pixels,
                                              min: 0,
                                              max: _scrollController.position.maxScrollExtent,
                                              label: visible
                                                  ? (position / _scrollController.position.maxScrollExtent) * 100 == 100
                                                      ? "${((position / _scrollController.position.maxScrollExtent) * 100).toString().substring(0, 3)}%"
                                                      : (position / _scrollController.position.maxScrollExtent) * 100 > 0
                                                          ? "${((position / _scrollController.position.maxScrollExtent) * 100).toString().substring(0, 4)}%"
                                                          : "0.00%"
                                                  : "",
                                              onChanged: (value) {
                                                setState(() {
                                                  position = value;
                                                });
                                                if (_actionTimer?.isActive ?? false) {
                                                  _actionTimer?.cancel();
                                                }
                                                _actionTimer = Timer(const Duration(milliseconds: 250), () {
                                                  _scrollController.jumpTo(value);
                                                });
                                              },
                                              onChangeEnd: (value) {
                                                _actionTimer?.cancel();
                                                if (value != _scrollController.position.pixels) {
                                                  _scrollController.jumpTo(value);
                                                }
                                              },
                                              activeColor: isDarkTheme ? MyColors.white : const Color.fromRGBO(29, 29, 33, 1),
                                              inactiveColor: isDarkTheme ? const Color.fromRGBO(96, 96, 96, 1) : const Color.fromRGBO(96, 96, 96, 1),
                                              thumbColor: isDarkTheme ? MyColors.white : const Color.fromRGBO(29, 29, 33, 1),
                                            ),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context).size.width / 12,
                                            alignment: Alignment.center,
                                            child: Text11(
                                                text: visible
                                                    ? (position / _scrollController.position.maxScrollExtent) * 100 == 100
                                                        ? "${((position / _scrollController.position.maxScrollExtent) * 100).toString().substring(0, 3)}%"
                                                        : (position / _scrollController.position.maxScrollExtent) * 100 > 0
                                                            ? "${((position / _scrollController.position.maxScrollExtent) * 100).toString().substring(0, 4)}%"
                                                            : "0.00%"
                                                    : "",
                                                textColor: MyColors.darkGray),
                                          )
                                        ],
                                      ),
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
                                  child: Icon(
                                    CustomIcons.turn,
                                    color: Theme.of(context).iconTheme.color,
                                    size: 30,
                                  ),
                                ),
                                const Padding(padding: EdgeInsets.only(right: 30)),
                                InkWell(
                                  onTap: () {
                                    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
                                    themeProvider.isDarkTheme = !themeProvider.isDarkTheme;
                                    saveSettings(themeProvider.isDarkTheme);
                                  },
                                  child: Icon(
                                    CustomIcons.theme,
                                    color: Theme.of(context).iconTheme.color,
                                    size: 30,
                                  ),
                                ),
                                const Padding(padding: EdgeInsets.only(right: 30)),
                                GestureDetector(
                                  onTap: () async {
                                    switch (isBorder) {
                                      case false:
                                        if (isTrans == true) {
                                          var temp = await loadWordCountFromLocalStorage(textes.first.filePath);
                                          print('temp.filePath = ${temp.filePath}');
                                          if (temp.filePath != '') {
                                            replaceWordsWithTranslation(temp.wordEntries);
                                          }
                                        } else {
                                          wordModeDialog(context);
                                        }
                                        break;
                                      default:
                                        await getDataFromLocalStorage('textKey');
                                        isBorder = false;
                                        final prefs = await SharedPreferences.getInstance();

                                        final lastCallTimestampStr = prefs.getString('lastCallTimestamp');
                                        var lastCallTimestamp = lastCallTimestampStr != null ? DateTime.parse(lastCallTimestampStr) : null;
                                        var timeElapsed = DateTime.now().difference(lastCallTimestamp!);
                                        // if (timeElapsed.inHours > 24) {
                                        if (timeElapsed.inMilliseconds > 1) {
                                          wordModeDialog(context);
                                        } else {
                                          Fluttertoast.showToast(
                                            msg:
                                                'Новый перевод завтра в ${(lastCallTimestamp.add(const Duration(days: 1)).hour)}:${(lastCallTimestamp.add(const Duration(days: 1)).minute)}',
                                            toastLength: Toast.LENGTH_LONG,
                                            gravity: ToastGravity.BOTTOM,
                                          );
                                        }

                                        print('isTrans = $isTrans');
                                        break;
                                    }
                                  },
                                  child: Icon(
                                    CustomIcons.wm,
                                    color: Theme.of(context).iconTheme.color,
                                    size: 30,
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
      ),
    );
  }
}
