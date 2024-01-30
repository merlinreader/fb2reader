// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:merlin/UI/icon/custom_icon.dart';
import 'package:merlin/UI/router.dart';
import 'package:merlin/UI/theme/theme.dart';
import 'package:merlin/domain/data_providers/color_provider.dart';
import 'package:merlin/functions/book.dart';
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
  double lastPosition = 0; // маяк BookInfo

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

class Reader extends State with WidgetsBindingObserver {
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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    getDataFromLocalStorage('textKey');
    getImagesFromLocalStorage('booksKey');

    _getBatteryLevel();
    _scrollController.addListener(_updateScrollPercentage);
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      lastPageCount = prefs.getInt('pageCount-${textes.first.filePath}') ?? 0;
      prefs.setInt('lastPageCount-${textes.first.filePath}', lastPageCount);
      // print('initState lastPageCount $lastPageCount');
      final filePath = textes.first.filePath;
      pageSize = MediaQuery.of(context).size.height;
      // print('pageSize = $pageSize');
      saveDateTime(pageSize);
      final readingPositionsJson = prefs.getString('readingPositions');
      isTrans = prefs.getBool('${textes.first.filePath}-isTrans');
      setState(() {
        isTrans;
      });
      if (isTrans != null && isTrans == true && isBorder == true) {
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
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      // print('Приложение свернуто');
      await saveProgress();
      await _savePageCountToLocalStorage();
      await saveReadingPosition(_scrollController.position.pixels, textes.first.filePath);
      await getPageCount(textes.first.filePath, isBorder);
    }
    // else if (state == AppLifecycleState.resumed) {
    //   print('Приложение открыто');
    // }
  }

  @override
  void dispose() async {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([orientations[0]]);
    getPageCount(textes.first.filePath, isBorder);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeDependencies() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
    loadStylePreferences();
    super.didChangeDependencies();
  }

  Future<void> isWM() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isWM-${textes.first.filePath}', isBorder);
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
    // print(pageCount);
    prefs.setInt('pageCount-${textes.first.filePath}', pageCount);
  }

  bool isDarkTheme = false;

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
    images.firstWhere((element) => element.fileName == textes.first.filePath).progress =
        _scrollController.position.pixels / _scrollController.position.maxScrollExtent;
    // setState(() {});
    // print("SAVING PROGRESS ${_scrollController.position.pixels / _scrollController.position.maxScrollExtent}");
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('booksKey', jsonEncode(images));
    // print('SUCCESS PROGRESS');
  }

  double getProgress() {
    return _scrollController.position.pixels / _scrollController.position.maxScrollExtent;
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

  void _updateScrollPercentage() {
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
      // print('lastPageCount $lastPageCount');
      // print('pageCount $pageCount');
    });
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

  double? savedPosition; // Переменная для хранения позиции скролла
  double? savedMaxExtent; // Переменная для хранения максимальной прокрутки

  Future<void> savePositionAndExtent() async {
    savedPosition = _scrollController.position.pixels;
    savedMaxExtent = _scrollController.position.maxScrollExtent;
  }

  bool forTable = false;
  void switchOrientation() async {
    if (savedPosition != null && savedMaxExtent != null) {
      currentOrientationIndex = (currentOrientationIndex + 1) % orientations.length;
      SystemChrome.setPreferredOrientations([orientations[currentOrientationIndex]]);
      if (orientations[currentOrientationIndex] == DeviceOrientation.landscapeLeft ||
          orientations[currentOrientationIndex] == DeviceOrientation.landscapeRight) {
        forTable = true;
      } else {
        forTable = false;
      }

      // Дождитесь завершения изменения ориентации
      await Future.delayed(const Duration(milliseconds: 200));

      double newMaxExtent = _scrollController.position.maxScrollExtent;
      double newPositionRatio = savedPosition! / savedMaxExtent!;
      double newPosition = newPositionRatio * newMaxExtent;

      // Убедитесь, что новая позиция не выходит за пределы
      newPosition = min(newPosition, newMaxExtent);

      // Используйте animateTo для плавного перехода
      // _scrollController.animateTo(
      //   newPosition,
      //   duration: Duration(milliseconds: 250),
      //   curve: Curves.easeOut,
      // );
      _scrollController.jumpTo(newPosition);
    }
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
    String key = 'WMWORDS';

    // Сериализация WordCount в JSON и сохранение.
    String wordCountString = jsonEncode(wordCount.toJson());
    await prefs.setString(key, wordCountString);
  }

  Future<WordCount> loadWordCountFromLocalStorage(String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    String key = 'WMWORDS';
    String? storedData = prefs.getString(key);
    // print('reader loadwCounts $storedData');
    if (storedData != null) {
      Map<String, dynamic> decodedData = jsonDecode(storedData);
      WordCount wordCount = WordCount.fromJson(decodedData);
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
      DateTime? lastCallTranslateStamp = DateTime.parse(lastCallTranslateStr);
      final timeElapsed = now.difference(lastCallTranslateStamp);
      if (timeElapsed.inMilliseconds >= 1) {
        await getDataFromLocalStorage('textKey');
      }
    }
    String updatedText = getText;

    for (var entry in wordEntries) {
      // print('Ищем слово: ${entry.word}');

      var escapedWord = RegExp.escape(entry.word);
      var pattern = '(?<!\\p{L})$escapedWord(?!\\p{L})';
      var wordRegExp = RegExp(pattern, caseSensitive: false, unicode: true);

      updatedText = updatedText.replaceAllMapped(wordRegExp, (match) {
        final matchedWord = match.group(0)!;
        // print('Найдено совпадение: $matchedWord');
        return matchCase(matchedWord, entry.translation ?? '');
      });
      // updatedText = updatedText.replaceAllMapped(entry.word[0].toUpperCase() + entry.word.substring(1).toLowerCase(), (match) {
      //   final matchedWord = match.group(0)!;
      //   print('Найдено совпадение: ${matchedWord.characters}');
      //   return matchCase(matchedWord, entry.translation ?? '');
      // });
    }

    await prefs.setString('lastCallTranslate', DateTime.now().toIso8601String());
    isTrans = prefs.getBool('${textes.first.filePath}-isTrans');
    // print(isTrans);
    setState(() {
      getText = updatedText;
      isTrans;
    });
  }

  String matchCase(String source, String pattern) {
    // print('source $source');
    // print('pattern $pattern');
    // Сохраняем регистр первой буквы исходного слова
    if (source[0] == source[0].toUpperCase()) {
      // print('большая буква');
      return pattern[0].toUpperCase() + pattern.substring(1).toLowerCase();
    }
    // Если весь текст в верхнем регистре - перевод тоже
    if (source.toUpperCase() == source) {
      // print('Если весь текст в верхнем регистре - перевод тоже');
      return pattern.toUpperCase();
    }
    // Иначе возвращаем перевод в нижнем регистре
    // print('Иначе возвращаем перевод в нижнем регистре');
    return pattern.toLowerCase();
  }

  showTableDialog(BuildContext context, WordCount wordCount, bool confirm) async {
    var wordsMap = await WordCount(filePath: textes.first.filePath, fileText: textes.first.fileText).getAllWordCounts();
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return FutureBuilder(
          future: wordCount.checkCallInfo(confirm),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: MyColors.purple,
                ),
              );
            } else if (snapshot.hasError) {
              // print(wordCount.wordEntries);
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
                    replaceWordsWithTranslation(wordCount.wordEntries);
                    return true;
                  },
                  child: GestureDetector(
                    onTap: () async {
                      // debugPrint("DONE");
                      await saveWordCountToLocalstorage(wordCount);
                      replaceWordsWithTranslation(wordCount.wordEntries);
                      Navigator.pop(context);
                    },
                    child: confirm == false
                        ? SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: forTable == false ? MediaQuery.of(context).size.height * 0.6 : MediaQuery.of(context).size.height * 0.8,
                              ),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: forTable == false ? MediaQuery.of(context).size.height * 0.6 : MediaQuery.of(context).size.height * 0.8,
                                color: Colors.transparent,
                                child: Card(
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: forTable == false ? MediaQuery.of(context).size.height * 0.5 : MediaQuery.of(context).size.height * 0.7,
                                    child: Column(
                                      // mainAxisAlignment: MainAxisAlignment.start,
                                      // crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              alignment: Alignment.centerRight,
                                              padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                                              icon: const Icon(Icons.close),
                                              onPressed: () async {
                                                await saveWordCountToLocalstorage(wordCount);
                                                replaceWordsWithTranslation(wordCount.wordEntries);
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 0),
                                          child: Center(
                                            child: forTable == false
                                                ? const Text24(
                                                    text: 'Изучаемые слова',
                                                    textColor: MyColors.black,
                                                  )
                                                : const Text20(text: 'Изучаемые слова', textColor: MyColors.black),
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context).size.width,
                                          child: DataTable(
                                            columnSpacing: forTable == false ? 15 : 0,
                                            showBottomBorder: false,
                                            dataTextStyle: const TextStyle(fontFamily: 'Roboto', color: MyColors.black),
                                            clipBehavior: Clip.hardEdge,
                                            horizontalMargin: 10,
                                            columns: [
                                              DataColumn(
                                                label: forTable == false
                                                    ? SizedBox(
                                                        width: MediaQuery.of(context).size.width * 0.19,
                                                        child: const Text(
                                                          'Слово',
                                                          style: TextStyle(
                                                            fontFamily: 'Tektur',
                                                            fontSize: 15,
                                                          ),
                                                          textAlign: TextAlign.left,
                                                        ),
                                                      )
                                                    : SizedBox(
                                                        width: MediaQuery.of(context).size.width * 0.285,
                                                        child: const Text(
                                                          'Слово',
                                                          style: TextStyle(
                                                            fontFamily: 'Tektur',
                                                            fontSize: 15,
                                                          ),
                                                          textAlign: TextAlign.left,
                                                        ),
                                                      ),
                                              ),
                                              DataColumn(
                                                label: forTable == false
                                                    ? const Text('Транскрипция',
                                                        style: TextStyle(
                                                          fontFamily: 'Tektur',
                                                          fontSize: 15,
                                                        ),
                                                        textAlign: TextAlign.left)
                                                    : SizedBox(
                                                        width: MediaQuery.of(context).size.width * 0.345,
                                                        child: const Text('Транскрипция',
                                                            style: TextStyle(
                                                              fontFamily: 'Tektur',
                                                              fontSize: 15,
                                                            ),
                                                            textAlign: TextAlign.left),
                                                      ),
                                              ),
                                              DataColumn(
                                                label: forTable == false
                                                    ? Text(
                                                        'Перевод',
                                                        style: const TextStyle(
                                                          fontFamily: 'Tektur',
                                                          fontSize: 15,
                                                        ),
                                                        textAlign: forTable == false ? TextAlign.right : TextAlign.left,
                                                      )
                                                    : SizedBox(
                                                        width: MediaQuery.of(context).size.width * 0.3,
                                                        child: Text(
                                                          'Перевод',
                                                          style: const TextStyle(
                                                            fontFamily: 'Tektur',
                                                            fontSize: 15,
                                                          ),
                                                          textAlign: forTable == false ? TextAlign.right : TextAlign.left,
                                                        ),
                                                      ),
                                              ),
                                            ],
                                            rows: const [],
                                          ),
                                        ),
                                        Container(
                                          width: forTable == true ? MediaQuery.of(context).size.width : null,
                                          height: forTable == false
                                              ? MediaQuery.of(context).size.height * 0.42
                                              : MediaQuery.of(context).size.height * 0.43,
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.vertical,
                                            child: DataTable(
                                              columnSpacing: forTable == false ? 33 : 0,
                                              showBottomBorder: false,
                                              dataTextStyle: const TextStyle(fontFamily: 'Roboto', color: MyColors.black),
                                              clipBehavior: Clip.hardEdge,
                                              headingRowHeight: 0,
                                              horizontalMargin: 10,
                                              columns: const [
                                                DataColumn(
                                                  label: Flexible(
                                                    child: Text15(
                                                      text: '',
                                                      textColor: MyColors.black,
                                                    ),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Flexible(
                                                    child: Text15(
                                                      text: '',
                                                      textColor: MyColors.black,
                                                    ),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Flexible(
                                                    child: Text15(
                                                      text: '',
                                                      textColor: MyColors.black,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              rows: wordCount.wordEntries.map((entry) {
                                                return DataRow(
                                                  cells: [
                                                    DataCell(
                                                      // Text(
                                                      //   entry.word,
                                                      //   style: TextStyle(
                                                      //       overflow: TextOverflow.ellipsis, color: isDarkTheme ? MyColors.white : MyColors.black),
                                                      // ),
                                                      forTable == false
                                                          ? SizedBox(
                                                              width: MediaQuery.of(context).size.width * 0.23,
                                                              child: Text(
                                                                entry.word,
                                                                style: TextStyle(
                                                                    overflow: TextOverflow.ellipsis,
                                                                    color: isDarkTheme ? MyColors.white : MyColors.black),
                                                              ),
                                                            )
                                                          : Text(
                                                              entry.word,
                                                              style: TextStyle(
                                                                  overflow: TextOverflow.ellipsis,
                                                                  color: isDarkTheme ? MyColors.white : MyColors.black),
                                                            ),
                                                      // TextForTable(
                                                      //   text: entry.word,
                                                      //   textColor: MyColors.black,
                                                      // ),
                                                    ),
                                                    DataCell(
                                                      // Text(
                                                      //   '[ ${entry.ipa} ]',
                                                      //   style: TextStyle(
                                                      //       overflow: TextOverflow.ellipsis, color: isDarkTheme ? MyColors.white : MyColors.black),
                                                      // ),
                                                      forTable == false
                                                          ? SizedBox(
                                                              width: MediaQuery.of(context).size.width * 0.275,
                                                              child: Text(
                                                                '[ ${entry.ipa} ]',
                                                                style: TextStyle(
                                                                    overflow: TextOverflow.ellipsis,
                                                                    color: isDarkTheme ? MyColors.white : MyColors.black),
                                                              ),
                                                            )
                                                          : SizedBox(
                                                              width: MediaQuery.of(context).size.width * 0.14,
                                                              child: Text(
                                                                '[ ${entry.ipa} ]',
                                                                style: TextStyle(
                                                                    overflow: TextOverflow.ellipsis,
                                                                    color: isDarkTheme ? MyColors.white : MyColors.black),
                                                              ),
                                                            ),
                                                      // TextForTable(
                                                      //   text: '[ ${entry.ipa} ]',
                                                      //   textColor: MyColors.black,
                                                      // ),
                                                    ),
                                                    DataCell(
                                                      // SizedBox(
                                                      //   width: MediaQuery.of(context).size.width * 0.275,
                                                      //   child: Text(
                                                      //     entry.translation!.isNotEmpty ? entry.translation! : 'N/A',
                                                      //     style: TextStyle(color: isDarkTheme ? MyColors.white : MyColors.black),
                                                      //   ),
                                                      // ),
                                                      forTable == false
                                                          ? Padding(
                                                              padding: const EdgeInsets.only(left: 10),
                                                              child: SizedBox(
                                                                width: MediaQuery.of(context).size.width * 0.5,
                                                                child: Text(
                                                                  entry.translation!.isNotEmpty ? entry.translation! : 'N/A',
                                                                  style: TextStyle(color: isDarkTheme ? MyColors.white : MyColors.black),
                                                                ),
                                                              ),
                                                            )
                                                          : Text(
                                                              entry.translation!.isNotEmpty ? entry.translation! : 'N/A',
                                                              style: TextStyle(color: isDarkTheme ? MyColors.white : MyColors.black),
                                                            ),
                                                    ),
                                                  ],
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: forTable == false ? MediaQuery.of(context).size.height * 0.6 : MediaQuery.of(context).size.height * 0.8,
                              ),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: forTable == false ? MediaQuery.of(context).size.height * 0.6 : MediaQuery.of(context).size.height * 0.8,
                                color: Colors.transparent,
                                child: Card(
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: forTable == false ? MediaQuery.of(context).size.height * 0.5 : MediaQuery.of(context).size.height * 0.7,
                                    child: Column(
                                      // mainAxisAlignment: MainAxisAlignment.start,
                                      // crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              alignment: Alignment.centerRight,
                                              padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                                              icon: const Icon(Icons.close),
                                              onPressed: () async {
                                                await saveWordCountToLocalstorage(wordCount);
                                                replaceWordsWithTranslation(wordCount.wordEntries);
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 20),
                                          child: Center(
                                            child: forTable == false
                                                ? const Text24(
                                                    text: 'Изучаемые слова',
                                                    textColor: MyColors.black,
                                                  )
                                                : const Text20(text: 'Изучаемые слова', textColor: MyColors.black),
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context).size.width,
                                          // height: MediaQuery.of(context).size.height * 0.37,
                                          child: DataTable(
                                            columnSpacing: forTable == false ? 0 : 30,
                                            showBottomBorder: false,
                                            dataTextStyle: const TextStyle(fontFamily: 'Roboto', color: MyColors.black),
                                            clipBehavior: Clip.hardEdge,
                                            horizontalMargin: 10,
                                            columns: [
                                              DataColumn(
                                                label: forTable == false
                                                    ? SizedBox(
                                                        width: MediaQuery.of(context).size.width * 0.6,
                                                        child: const Text(
                                                          'Слово',
                                                          style: TextStyle(
                                                            fontFamily: 'Tektur',
                                                            fontSize: 15,
                                                          ),
                                                          textAlign: TextAlign.left,
                                                        ),
                                                      )
                                                    : SizedBox(
                                                        width: MediaQuery.of(context).size.width * 0.3,
                                                        child: const Text(
                                                          'Слово',
                                                          style: TextStyle(
                                                            fontFamily: 'Tektur',
                                                            fontSize: 15,
                                                          ),
                                                          textAlign: TextAlign.left,
                                                        ),
                                                      ),
                                              ),
                                              DataColumn(
                                                label: forTable == false
                                                    ? Text(
                                                        'Количество',
                                                        style: const TextStyle(
                                                          fontFamily: 'Tektur',
                                                          fontSize: 15,
                                                        ),
                                                        textAlign: forTable == false ? TextAlign.right : TextAlign.left,
                                                      )
                                                    : Text(
                                                        'Количество',
                                                        style: const TextStyle(
                                                          fontFamily: 'Tektur',
                                                          fontSize: 15,
                                                        ),
                                                        textAlign: forTable == false ? TextAlign.right : TextAlign.left,
                                                      ),
                                              ),
                                            ],
                                            rows: const [],
                                          ),
                                        ),
                                        Container(
                                            width: MediaQuery.of(context).size.width,
                                            height: forTable == false
                                                ? MediaQuery.of(context).size.height * 0.41
                                                : MediaQuery.of(context).size.height * 0.35,
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.vertical,
                                              child: DataTable(
                                                columnSpacing: 0,
                                                showBottomBorder: false,
                                                dataTextStyle: const TextStyle(fontFamily: 'Roboto', color: MyColors.black),
                                                clipBehavior: Clip.hardEdge,
                                                headingRowHeight: 0,
                                                horizontalMargin: 10,
                                                columns: const [
                                                  DataColumn(
                                                    label: Flexible(
                                                      child: Text15(
                                                        text: '',
                                                        textColor: MyColors.black,
                                                      ),
                                                    ),
                                                  ),
                                                  DataColumn(
                                                    label: Flexible(
                                                      child: Text15(
                                                        text: '',
                                                        textColor: MyColors.black,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                                rows: wordCount.wordEntries.map((entry) {
                                                  return DataRow(
                                                    cells: [
                                                      DataCell(
                                                        forTable == false
                                                            ? SizedBox(
                                                                width: MediaQuery.of(context).size.width * 0.6,
                                                                child: InkWell(
                                                                  onTap: () async {
                                                                    await _showWordInputDialog(entry.word, wordCount.wordEntries, wordsMap);
                                                                    setState(() {
                                                                      entry.word;
                                                                      entry.count;
                                                                    });
                                                                  },
                                                                  child: TextForTable(
                                                                    text: entry.word,
                                                                    textColor: MyColors.black,
                                                                  ),
                                                                ),
                                                              )
                                                            : SizedBox(
                                                                width: MediaQuery.of(context).size.width * 0.43,
                                                                child: InkWell(
                                                                  onTap: () async {
                                                                    await _showWordInputDialog(entry.word, wordCount.wordEntries, wordsMap);
                                                                    setState(() {
                                                                      entry.word;
                                                                      entry.count;
                                                                    });
                                                                  },
                                                                  child: TextForTable(
                                                                    text: entry.word,
                                                                    textColor: MyColors.black,
                                                                  ),
                                                                ),
                                                              ),
                                                      ),
                                                      DataCell(
                                                        SizedBox(
                                                          width: MediaQuery.of(context).size.width * 0.2,
                                                          child: TextForTable(
                                                            text: '${entry.count}',
                                                            textColor: MyColors.black,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                }).toList(),
                                              ),
                                            )),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                  )

                  // SingleChildScrollView(
                  //   child: ConstrainedBox(
                  //     constraints: BoxConstraints(
                  //       maxHeight: MediaQuery.of(context).size.height * 0.8,
                  //     ),
                  //     child: ListView(
                  //       shrinkWrap: true,
                  //       padding: const EdgeInsets.all(0),
                  //       children: <Widget>[
                  //         Container(
                  //           width: MediaQuery.of(context).size.width,
                  //           color: Colors.transparent,
                  //           child: Card(
                  //             child: Column(
                  //               children: <Widget>[
                  //                 Row(
                  //                   mainAxisAlignment: MainAxisAlignment.end,
                  //                   children: [
                  //                     IconButton(
                  //                       alignment: Alignment.centerRight,
                  //                       padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                  //                       icon: const Icon(Icons.close),
                  //                       onPressed: () async {
                  //                         // debugPrint("DONE");
                  //                         await saveWordCountToLocalstorage(wordCount);
                  //                         replaceWordsWithTranslation(wordCount.wordEntries);
                  //                         Navigator.pop(context);
                  //                       },
                  //                     ),
                  //                   ],
                  //                 ),
                  //                 const Padding(
                  //                   padding: EdgeInsets.only(bottom: 40),
                  //                   child: Center(
                  //                     child: Text24(
                  //                       text: 'Изучаемые слова',
                  //                       textColor: MyColors.black,
                  //                     ),
                  //                   ),
                  //                 ),
                  //                 confirm == false
                  //                     ? Padding(
                  //                         padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                  //                         child: DataTable(
                  //                           columnSpacing: 30.0,
                  //                           showBottomBorder: false,
                  //                           dataTextStyle: const TextStyle(fontFamily: 'Roboto', color: MyColors.black),
                  //                           columns: const [
                  //                             DataColumn(
                  //                               label: Flexible(
                  //                                 child: Text15(
                  //                                   text: 'Слово',
                  //                                   textColor: MyColors.black,
                  //                                 ),
                  //                               ),
                  //                             ),
                  //                             DataColumn(
                  //                               label: Flexible(
                  //                                 child: Text15(
                  //                                   text: 'Транскрипция',
                  //                                   textColor: MyColors.black,
                  //                                 ),
                  //                               ),
                  //                             ),
                  //                             DataColumn(
                  //                               label: Flexible(
                  //                                 child: Text15(
                  //                                   text: 'Перевод',
                  //                                   textColor: MyColors.black,
                  //                                 ),
                  //                               ),
                  //                             ),
                  //                           ],
                  //                           rows: wordCount.wordEntries.map((entry) {
                  //                             return DataRow(
                  //                               cells: [
                  //                                 DataCell(
                  //                                   Flexible(
                  //                                     child: TextForTable(
                  //                                       text: entry.word,
                  //                                       textColor: MyColors.black,
                  //                                     ),
                  //                                   ),
                  //                                 ),
                  //                                 DataCell(
                  //                                   Flexible(
                  //                                     child: TextForTable(
                  //                                       text: '[ ${entry.ipa} ]',
                  //                                       textColor: MyColors.black,
                  //                                     ),
                  //                                   ),
                  //                                 ),
                  //                                 DataCell(
                  //                                   Flexible(
                  //                                     child: TextForTable(
                  //                                       text: entry.translation!.isNotEmpty ? entry.translation! : 'N/A',
                  //                                       textColor: MyColors.black,
                  //                                     ),
                  //                                   ),
                  //                                 ),
                  //                               ],
                  //                             );
                  //                           }).toList(),
                  //                         ),
                  //                       )
                  //                     : Padding(
                  //                         padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                  //                         child: FractionallySizedBox(
                  //                           widthFactor: 0.95,
                  //                           child:
                  // DataTable(
                  //                             columnSpacing: 30.0,
                  //                             showBottomBorder: false,
                  //                             dataTextStyle: const TextStyle(fontFamily: 'Roboto', color: MyColors.black),
                  //                             columns: const [
                  //                               DataColumn(
                  //                                 label: Flexible(
                  //                                   child: Text15(
                  //                                     text: 'Слово',
                  //                                     textColor: MyColors.black,
                  //                                   ),
                  //                                 ),
                  //                               ),
                  //                               DataColumn(
                  //                                 label: Flexible(
                  //                                   child: Text15(
                  //                                     text: 'Количество',
                  //                                     textColor: MyColors.black,
                  //                                   ),
                  //                                 ),
                  //                               ),
                  //                             ],
                  //                             rows: wordCount.wordEntries.map((entry) {
                  //                               return DataRow(
                  //                                 cells: [
                  //                                   DataCell(
                  //                                     Flexible(
                  //                                       child: InkWell(
                  //                                         onTap: () async {
                  //                                           await _showWordInputDialog(entry.word, wordCount.wordEntries);
                  //                                           setState(() {
                  //                                             entry.word;
                  //                                             entry.count;
                  //                                           });
                  //                                         },
                  //                                         child: TextForTable(
                  //                                           text: entry.word,
                  //                                           textColor: MyColors.black,
                  //                                         ),
                  //                                       ),
                  //                                     ),
                  //                                   ),
                  //                                   DataCell(
                  //                                     Flexible(
                  //                                       child: TextForTable(
                  //                                         text: '${entry.count}',
                  //                                         textColor: MyColors.black,
                  //                                       ),
                  //                                     ),
                  //                                   ),
                  //                                 ],
                  //                               );
                  //                             }).toList(),
                  //                           ),
                  //                         ),
                  //                       ),
                  //                 // TextButton(
                  //                 //     onPressed: () async {
                  //                 //       await saveWordCountToLocalstorage(wordCount);
                  //                 //       replaceWordsWithTranslation(wordCount.wordEntries);
                  //                 //       Navigator.pop(context);
                  //                 //     },
                  //                 //     child: const Text16(
                  //                 //       text: 'Сохранить',
                  //                 //       textColor: MyColors.black,
                  //                 //     ))
                  //               ],
                  //             ),
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  );
            }
          },
        );
      },
    );
  }

  // Облачка
  // Future<void> showTableDialog(BuildContext context, WordCount wordCount) async {
  //   showDialog<void>(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return FutureBuilder(
  //         future: wordCount.checkCallInfo(),
  //         builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
  //           if (snapshot.connectionState == ConnectionState.waiting) {
  //             return const Center(
  //               child: CircularProgressIndicator(
  //                 color: MyColors.purple,
  //               ),
  //             );
  //           } else if (snapshot.hasError) {
  //             return const AlertDialog(
  //               content: Text('Произошла ошибка: нет доступа к интернету'),
  //             );
  //           } else {
  //             if (wordCount.wordEntries.isEmpty) {
  //               Navigator.pop(context);
  //             }

  //             return WillPopScope(
  //               onWillPop: () async {
  //                 // debugPrint("DONE");
  //                 await saveWordCountToLocalstorage(wordCount);
  //                 return true;
  //               },
  //               child: ConstrainedBox(
  //                 constraints: BoxConstraints(
  //                   maxHeight: MediaQuery.of(context).size.height * 0.8,
  //                 ),
  //                 child: Column(
  //                   // shrinkWrap: true,
  //                   // padding: const EdgeInsets.all(0),
  //                   children: <Widget>[
  //                     Container(
  //                       width: MediaQuery.of(context).size.width,
  //                       height: MediaQuery.of(context).size.height * 0.5,
  //                       color: Colors.transparent,
  //                       child: Card(
  //                         child: Column(
  //                           mainAxisAlignment: MainAxisAlignment.start,
  //                           crossAxisAlignment: CrossAxisAlignment.stretch,
  //                           children: <Widget>[
  //                             IconButton(
  //                               alignment: Alignment.centerRight,
  //                               padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
  //                               icon: const Icon(Icons.close),
  //                               onPressed: () async {
  //                                 // debugPrint("DONE");
  //                                 await saveWordCountToLocalstorage(wordCount);
  //                                 replaceWordsWithTranslation(wordCount.wordEntries);
  //                                 Navigator.pop(context);
  //                               },
  //                             ),
  //                             const Padding(
  //                               padding: EdgeInsets.only(bottom: 20),
  //                               child: Center(
  //                                 child: Text24(
  //                                   text: 'Частые слова',
  //                                   textColor: MyColors.black,
  //                                 ),
  //                               ),
  //                             ),

  //                             Expanded(
  //                               child: ListView.builder(
  //                                 itemCount: wordCount.wordEntries.length,
  //                                 itemBuilder: (context, index) {
  //                                   var entry = wordCount.wordEntries[index];
  //                                   return Container(
  //                                     height: 70,
  //                                     width: MediaQuery.of(context).size.width * 0.5, // Adjust width as needed
  //                                     margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Adjust vertical margin as needed
  //                                     decoration: BoxDecoration(
  //                                         color: Colors.transparent,
  //                                         // borderRadius: BorderRadius.circular(12),
  //                                         border: Border.all(color: MyColors.lightGray) // Adjust border radius for rounded corners
  //                                         ),
  //                                     child: Padding(
  //                                       padding: const EdgeInsets.all(8), // Adjust inner padding as needed
  //                                       child: Column(
  //                                         mainAxisAlignment: MainAxisAlignment.center,
  //                                         children: [
  //                                           TextForTable(
  //                                             text: '${entry.word} - ${entry.translation!.isNotEmpty ? entry.translation! : 'N/A'}',
  //                                             textColor: MyColors.black,
  //                                           ),
  //                                           TextForTable(
  //                                             text: '[ ${entry.ipa} ]',
  //                                             textColor: MyColors.black,
  //                                           ),
  //                                         ],
  //                                       ),
  //                                     ),
  //                                   );
  //                                 },
  //                               ),
  //                             )
  //                             // TextButton(
  //                             //     onPressed: () {
  //                             //       Navigator.pop(context);
  //                             //     },
  //                             //     child: const Text16(
  //                             //       text: 'Закрыть',
  //                             //       textColor: MyColors.black,
  //                             //     ))
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             );
  //           }
  //         },
  //       );
  //     },
  //   );
  // }

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

  // showEmptyTable(BuildContext context, WordCount wordCount) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final lastCallTimestampStr = prefs.getString('lastCallTimestamp');
  //   DateTime? lastCallTimestamp;
  //   Duration timeElapsed;
  //   lastCallTimestamp = lastCallTimestampStr != null ? DateTime.parse(lastCallTimestampStr) : null;

  //   final now = DateTime.now();
  //   final oneDayMore = now.add(const Duration(days: 1));
  //   if (lastCallTimestamp != null) {
  //     timeElapsed = now.difference(lastCallTimestamp);
  //   } else {
  //     timeElapsed = now.difference(oneDayMore);
  //   }
  //   int getWords = prefs.getInt('words') ?? 10;
  //   print('showEmptyTable getWords = $getWords');
  //   // print('lastCallTimestampStr $lastCallTimestampStr');
  //   // print('lastCallTimestamp $lastCallTimestamp');
  //   // print('now $now');
  //   // print('timeElapsed $timeElapsed');
  //   if (timeElapsed.inMilliseconds >= 1 && wordCount.wordEntries.length <= getWords || lastCallTimestampStr == null) {
  //     // if (timeElapsed.inHours >= 24 && wordCount.wordEntries.length <= getWords || lastCallTimestampStr == null) {
  //     // print('Entered');
  //     String screenWord = getWordForm(getWords - wordCount.wordEntries.length);
  //     var lastCallTimestamp = DateTime.now();
  //     final prefs = await SharedPreferences.getInstance();
  //     await prefs.setString('lastCallTimestamp', lastCallTimestamp.toIso8601String());

  //     showDialog<void>(
  //         context: context,
  //         barrierDismissible: true,
  //         builder: (BuildContext context) {
  //           screenWord = getWordForm(getWords - wordCount.wordEntries.length);

  //           return SingleChildScrollView(
  //             child: ConstrainedBox(
  //               constraints: BoxConstraints(
  //                 maxHeight: MediaQuery.of(context).size.height * 0.8,
  //               ),
  //               child: ListView(
  //                 shrinkWrap: true,
  //                 padding: const EdgeInsets.all(0),
  //                 children: <Widget>[
  //                   Container(
  //                     width: MediaQuery.of(context).size.width,
  //                     color: Colors.transparent,
  //                     child: Card(
  //                       child: Column(
  //                         mainAxisAlignment: MainAxisAlignment.start,
  //                         crossAxisAlignment: CrossAxisAlignment.stretch,
  //                         children: <Widget>[
  //                           IconButton(
  //                             alignment: Alignment.centerRight,
  //                             padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
  //                             icon: const Icon(Icons.close),
  //                             onPressed: () async {
  //                               if (wordCount.wordEntries.length == getWords) {
  //                                 await saveWordCountToLocalstorage(wordCount);
  //                                 replaceWordsWithTranslation(wordCount.wordEntries);
  //                                 Navigator.pop(context);
  //                               } else {
  //                                 Fluttertoast.showToast(msg: 'Вы не добавили все слова', toastLength: Toast.LENGTH_LONG);
  //                               }
  //                             },
  //                           ),
  //                           Padding(
  //                             padding: const EdgeInsets.only(bottom: 20),
  //                             child: Center(
  //                               child: Text24(
  //                                 text: wordCount.wordEntries.length < 10
  //                                     ? 'Осталось добавить ${(getWords - wordCount.wordEntries.length)} $screenWord'
  //                                     : 'Изучаемые слова',
  //                                 textColor: MyColors.black,
  //                               ),
  //                             ),
  //                           ),
  //                           DataTable(
  //                             columnSpacing: 38.0,
  //                             showBottomBorder: false,
  //                             dataTextStyle: const TextStyle(fontFamily: 'Roboto', color: MyColors.black),
  //                             columns: const [
  //                               DataColumn(
  //                                 label: Expanded(
  //                                   child: Text15(
  //                                     text: 'Слово',
  //                                     textColor: MyColors.black,
  //                                   ),
  //                                 ),
  //                               ),
  //                               DataColumn(
  //                                 label: Expanded(
  //                                   child: Text15(
  //                                     text: 'Транскрипция',
  //                                     textColor: MyColors.black,
  //                                   ),
  //                                 ),
  //                               ),
  //                               DataColumn(
  //                                 label: Expanded(
  //                                   child: Text15(
  //                                     text: 'Перевод',
  //                                     textColor: MyColors.black,
  //                                   ),
  //                                 ),
  //                               ),
  //                             ],
  //                             rows: wordCount.wordEntries.map((entry) {
  //                               return DataRow(
  //                                 cells: [
  //                                   DataCell(InkWell(
  //                                     onTap: () async {
  //                                       await _showWordInputDialog(entry.word, wordCount.wordEntries);
  //                                       setState(() {
  //                                         entry.word;
  //                                         entry.count;
  //                                         entry.ipa;
  //                                       });
  //                                     },
  //                                     child: TextForTable(
  //                                       text: entry.word,
  //                                       textColor: MyColors.black,
  //                                     ),
  //                                   )),
  //                                   DataCell(
  //                                     ConstrainedBox(
  //                                       constraints: BoxConstraints(
  //                                         maxWidth: MediaQuery.of(context).size.width * 0.25,
  //                                       ),
  //                                       child: TextForTable(
  //                                         text: '[ ${entry.ipa} ]',
  //                                         textColor: MyColors.black,
  //                                       ),
  //                                     ),
  //                                   ),
  //                                   DataCell(
  //                                     ConstrainedBox(
  //                                       constraints: BoxConstraints(
  //                                         maxWidth: MediaQuery.of(context).size.width * 0.25,
  //                                       ),
  //                                       child: TextForTable(
  //                                         text: entry.translation!.isNotEmpty ? entry.translation! : 'N/A',
  //                                         textColor: MyColors.black,
  //                                       ),
  //                                     ),
  //                                   ),
  //                                 ],
  //                               );
  //                             }).toList(),
  //                           ),
  //                           wordCount.wordEntries.length < 10
  //                               ? TextButton(
  //                                   onPressed: () async {
  //                                     await addNewWord(wordCount.wordEntries, wordCount, wordCount.wordEntries.length);
  //                                   },
  //                                   child: const Text16(
  //                                     text: 'Добавить',
  //                                     textColor: MyColors.black,
  //                                   ))
  //                               : TextButton(
  //                                   onPressed: () async {
  //                                     await saveWordCountToLocalstorage(wordCount);
  //                                     replaceWordsWithTranslation(wordCount.wordEntries);
  //                                     Navigator.pop(context);
  //                                   },
  //                                   child: const Text16(
  //                                     text: 'Сохранить',
  //                                     textColor: MyColors.black,
  //                                   ))
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           );
  //         });
  //   } else {
  //     Fluttertoast.showToast(
  //       msg: 'Можно только раз в 24 часа!',
  //       toastLength: Toast.LENGTH_SHORT, // Длительность отображения
  //       gravity: ToastGravity.BOTTOM, // Расположение уведомления
  //     );
  //     return;
  //   }
  // }

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
    // print('showEmptyTable getWords = $getWords');
    // print('lastCallTimestampStr $lastCallTimestampStr');
    // print('lastCallTimestamp $lastCallTimestamp');
    // print('now $now');
    // print('timeElapsed $timeElapsed');
    // if (timeElapsed.inMilliseconds >= 1 && wordCount.wordEntries.length <= getWords || lastCallTimestampStr == null) {
    if (timeElapsed.inHours >= 24 && wordCount.wordEntries.length <= getWords || lastCallTimestampStr == null) {
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

            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: wordCount.wordEntries.isNotEmpty ? MediaQuery.of(context).size.height * 0.5 : MediaQuery.of(context).size.height * 0.3,
                    color: Colors.transparent,
                    child: Card(
                      child: Column(
                        mainAxisAlignment: wordCount.wordEntries.isNotEmpty ? MainAxisAlignment.start : MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          IconButton(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                            icon: const Icon(Icons.close),
                            onPressed: () async {
                              if (wordCount.wordEntries.length == getWords) {
                                await saveWordCountToLocalstorage(wordCount);
                                replaceWordsWithTranslation(wordCount.wordEntries);
                                Navigator.pop(context);
                              } else {
                                Fluttertoast.showToast(msg: 'Вы не добавили все слова', toastLength: Toast.LENGTH_LONG);
                              }
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
                          wordCount.wordEntries.isNotEmpty
                              ? Expanded(
                                  child: ListView.builder(
                                    itemCount: wordCount.wordEntries.length,
                                    itemBuilder: (context, index) {
                                      var entry = wordCount.wordEntries[index];
                                      return Container(
                                        height: 70,
                                        width: MediaQuery.of(context).size.width * 0.5, // Adjust width as needed
                                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Adjust vertical margin as needed
                                        decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            // borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: MyColors.lightGray) // Adjust border radius for rounded corners
                                            ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8), // Adjust inner padding as needed
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              TextForTable(
                                                text: '${entry.word} - ${entry.translation!.isNotEmpty ? entry.translation! : 'N/A'}',
                                                textColor: MyColors.black,
                                              ),
                                              TextForTable(
                                                text: '[ ${entry.ipa} ]',
                                                textColor: MyColors.black,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Container(
                                  height: 70,
                                  width: MediaQuery.of(context).size.width * 0.5, // Adjust width as needed
                                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Adjust vertical margin as needed
                                  decoration: const BoxDecoration(
                                    color: Colors.transparent,
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(8), // Adjust inner padding as needed
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        TextForTable(
                                          text: 'Добавьте первое слово',
                                          textColor: MyColors.black,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
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
      barrierDismissible: false,
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
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: forTable == false ? MediaQuery.of(context).size.height * 0.6 : MediaQuery.of(context).size.height * 0.8,
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: forTable == false ? MediaQuery.of(context).size.height * 0.6 : MediaQuery.of(context).size.height * 0.8,
                        color: Colors.transparent,
                        child: Card(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: forTable == false ? MediaQuery.of(context).size.height * 0.5 : MediaQuery.of(context).size.height * 0.7,
                            child: Column(
                              // mainAxisAlignment: MainAxisAlignment.start,
                              // crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                                      icon: const Icon(Icons.close),
                                      onPressed: () async {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 0),
                                  child: Center(
                                    child: forTable == false
                                        ? const Text24(
                                            text: 'Изучаемые слова',
                                            textColor: MyColors.black,
                                          )
                                        : const Text20(text: 'Изучаемые слова', textColor: MyColors.black),
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: DataTable(
                                    columnSpacing: forTable == false ? 15 : 0,
                                    showBottomBorder: false,
                                    dataTextStyle: const TextStyle(fontFamily: 'Roboto', color: MyColors.black),
                                    clipBehavior: Clip.hardEdge,
                                    horizontalMargin: 10,
                                    columns: [
                                      DataColumn(
                                        label: forTable == false
                                            ? SizedBox(
                                                width: MediaQuery.of(context).size.width * 0.19,
                                                child: const Text(
                                                  'Слово',
                                                  style: TextStyle(
                                                    fontFamily: 'Tektur',
                                                    fontSize: 15,
                                                  ),
                                                  textAlign: TextAlign.left,
                                                ),
                                              )
                                            : SizedBox(
                                                width: MediaQuery.of(context).size.width * 0.285,
                                                child: const Text(
                                                  'Слово',
                                                  style: TextStyle(
                                                    fontFamily: 'Tektur',
                                                    fontSize: 15,
                                                  ),
                                                  textAlign: TextAlign.left,
                                                ),
                                              ),
                                      ),
                                      DataColumn(
                                        label: forTable == false
                                            ? const Text('Транскрипция',
                                                style: TextStyle(
                                                  fontFamily: 'Tektur',
                                                  fontSize: 15,
                                                ),
                                                textAlign: TextAlign.left)
                                            : SizedBox(
                                                width: MediaQuery.of(context).size.width * 0.345,
                                                child: const Text('Транскрипция',
                                                    style: TextStyle(
                                                      fontFamily: 'Tektur',
                                                      fontSize: 15,
                                                    ),
                                                    textAlign: TextAlign.left),
                                              ),
                                      ),
                                      DataColumn(
                                        label: forTable == false
                                            ? Text(
                                                'Перевод',
                                                style: const TextStyle(
                                                  fontFamily: 'Tektur',
                                                  fontSize: 15,
                                                ),
                                                textAlign: forTable == false ? TextAlign.right : TextAlign.left,
                                              )
                                            : SizedBox(
                                                width: MediaQuery.of(context).size.width * 0.3,
                                                child: Text(
                                                  'Перевод',
                                                  style: const TextStyle(
                                                    fontFamily: 'Tektur',
                                                    fontSize: 15,
                                                  ),
                                                  textAlign: forTable == false ? TextAlign.right : TextAlign.left,
                                                ),
                                              ),
                                      ),
                                    ],
                                    rows: const [],
                                  ),
                                ),
                                Container(
                                  width: forTable == true ? MediaQuery.of(context).size.width : null,
                                  height: forTable == false ? MediaQuery.of(context).size.height * 0.42 : MediaQuery.of(context).size.height * 0.43,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: DataTable(
                                      columnSpacing: forTable == false ? 33 : 0,
                                      showBottomBorder: false,
                                      dataTextStyle: const TextStyle(fontFamily: 'Roboto', color: MyColors.black),
                                      clipBehavior: Clip.hardEdge,
                                      headingRowHeight: 0,
                                      horizontalMargin: 10,
                                      columns: const [
                                        DataColumn(
                                          label: Flexible(
                                            child: Text15(
                                              text: '',
                                              textColor: MyColors.black,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Flexible(
                                            child: Text15(
                                              text: '',
                                              textColor: MyColors.black,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Flexible(
                                            child: Text15(
                                              text: '',
                                              textColor: MyColors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                      rows: wordCount.wordEntries.map((entry) {
                                        return DataRow(
                                          cells: [
                                            DataCell(
                                              // Text(
                                              //   entry.word,
                                              //   style: TextStyle(
                                              //       overflow: TextOverflow.ellipsis, color: isDarkTheme ? MyColors.white : MyColors.black),
                                              // ),
                                              forTable == false
                                                  ? SizedBox(
                                                      width: MediaQuery.of(context).size.width * 0.23,
                                                      child: Text(
                                                        entry.word,
                                                        style: TextStyle(
                                                            overflow: TextOverflow.ellipsis, color: isDarkTheme ? MyColors.white : MyColors.black),
                                                      ),
                                                    )
                                                  : Text(
                                                      entry.word,
                                                      style: TextStyle(
                                                          overflow: TextOverflow.ellipsis, color: isDarkTheme ? MyColors.white : MyColors.black),
                                                    ),
                                              // TextForTable(
                                              //   text: entry.word,
                                              //   textColor: MyColors.black,
                                              // ),
                                            ),
                                            DataCell(
                                              // Text(
                                              //   '[ ${entry.ipa} ]',
                                              //   style: TextStyle(
                                              //       overflow: TextOverflow.ellipsis, color: isDarkTheme ? MyColors.white : MyColors.black),
                                              // ),
                                              forTable == false
                                                  ? SizedBox(
                                                      width: MediaQuery.of(context).size.width * 0.275,
                                                      child: Text(
                                                        '[ ${entry.ipa} ]',
                                                        style: TextStyle(
                                                            overflow: TextOverflow.ellipsis, color: isDarkTheme ? MyColors.white : MyColors.black),
                                                      ),
                                                    )
                                                  : SizedBox(
                                                      width: MediaQuery.of(context).size.width * 0.14,
                                                      child: Text(
                                                        '[ ${entry.ipa} ]',
                                                        style: TextStyle(
                                                            overflow: TextOverflow.ellipsis, color: isDarkTheme ? MyColors.white : MyColors.black),
                                                      ),
                                                    ),
                                              // TextForTable(
                                              //   text: '[ ${entry.ipa} ]',
                                              //   textColor: MyColors.black,
                                              // ),
                                            ),
                                            DataCell(
                                              // SizedBox(
                                              //   width: MediaQuery.of(context).size.width * 0.275,
                                              //   child: Text(
                                              //     entry.translation!.isNotEmpty ? entry.translation! : 'N/A',
                                              //     style: TextStyle(color: isDarkTheme ? MyColors.white : MyColors.black),
                                              //   ),
                                              // ),
                                              forTable == false
                                                  ? Padding(
                                                      padding: const EdgeInsets.only(left: 10),
                                                      child: SizedBox(
                                                        width: MediaQuery.of(context).size.width * 0.5,
                                                        child: Text(
                                                          entry.translation!.isNotEmpty ? entry.translation! : 'N/A',
                                                          style: TextStyle(color: isDarkTheme ? MyColors.white : MyColors.black),
                                                        ),
                                                      ),
                                                    )
                                                  : Text(
                                                      entry.translation!.isNotEmpty ? entry.translation! : 'N/A',
                                                      style: TextStyle(color: isDarkTheme ? MyColors.white : MyColors.black),
                                                    ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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

  // Облачка
  // Future<void> showSavedWords(BuildContext context, String filePath) async {
  //   showDialog<void>(
  //     context: context,
  //     barrierDismissible: true,
  //     builder: (BuildContext context) {
  //       return FutureBuilder<WordCount>(
  //         future: loadWordCountFromLocalStorage(filePath),
  //         builder: (BuildContext context, AsyncSnapshot<WordCount> snapshot) {
  //           if (snapshot.connectionState == ConnectionState.waiting) {
  //             return const Center(
  //               child: CircularProgressIndicator(
  //                 color: MyColors.purple,
  //               ),
  //             );
  //           } else if (snapshot.hasError) {
  //             return AlertDialog(
  //               content: Text('Error: ${snapshot.error}'),
  //             );
  //           } else if (snapshot.connectionState == ConnectionState.done) {
  //             if (snapshot.hasData) {
  //               WordCount? wordCount = snapshot.data;
  //               // debugPrint('Getted wordCount $wordCount');
  //               if (wordCount == null || wordCount.wordEntries.isEmpty) {
  //                 Fluttertoast.showToast(
  //                   msg: 'Нет сохраненных слов',
  //                   toastLength: Toast.LENGTH_SHORT, // Длительность отображения
  //                   gravity: ToastGravity.BOTTOM,
  //                 );
  //                 Navigator.pop(context);
  //                 return const SizedBox.shrink();
  //               }
  //               return ConstrainedBox(
  //                 constraints: BoxConstraints(
  //                   maxHeight: MediaQuery.of(context).size.height * 0.6,
  //                 ),
  //                 child: Column(
  //                   // shrinkWrap: true,
  //                   // padding: const EdgeInsets.all(0),
  //                   children: <Widget>[
  //                     Container(
  //                       width: MediaQuery.of(context).size.width,
  //                       height: MediaQuery.of(context).size.height * 0.5,
  //                       color: Colors.transparent,
  //                       child: Card(
  //                         child: Column(
  //                           mainAxisAlignment: MainAxisAlignment.start,
  //                           crossAxisAlignment: CrossAxisAlignment.stretch,
  //                           children: <Widget>[
  //                             IconButton(
  //                               alignment: Alignment.centerRight,
  //                               padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
  //                               icon: const Icon(Icons.close),
  //                               onPressed: () {
  //                                 Navigator.of(context).pop();
  //                               },
  //                             ),
  //                             const Padding(
  //                               padding: EdgeInsets.only(bottom: 20),
  //                               child: Center(
  //                                 child: Text24(
  //                                   text: 'Изучаемые слова',
  //                                   textColor: MyColors.black,
  //                                 ),
  //                               ),
  //                             ),

  //                             Expanded(
  //                               child: ListView.builder(
  //                                 itemCount: wordCount.wordEntries.length,
  //                                 itemBuilder: (context, index) {
  //                                   var entry = wordCount.wordEntries[index];
  //                                   return Container(
  //                                     // height: MediaQuery.of(context).size.height * 0.1,
  //                                     width: MediaQuery.of(context).size.width * 0.5, // Adjust width as needed
  //                                     margin: const EdgeInsets.symmetric(vertical: 2.5, horizontal: 20), // Adjust vertical margin as needed
  //                                     decoration: BoxDecoration(
  //                                         color: Colors.transparent,
  //                                         // borderRadius: BorderRadius.circular(12),
  //                                         border: Border.all(color: MyColors.lightGray) // Adjust border radius for rounded corners
  //                                         ),
  //                                     child: Padding(
  //                                       padding: const EdgeInsets.symmetric(vertical: 10), // Adjust inner padding as needed
  //                                       child: Column(
  //                                         mainAxisAlignment: MainAxisAlignment.center,
  //                                         children: [
  //                                           TextForTable(
  //                                             text: '${entry.word} - ${entry.translation!.isNotEmpty ? entry.translation! : 'N/A'}',
  //                                             textColor: MyColors.black,
  //                                           ),
  //                                           TextForTable(
  //                                             text: '[ ${entry.ipa} ]',
  //                                             textColor: MyColors.black,
  //                                           ),
  //                                         ],
  //                                       ),
  //                                     ),
  //                                   );
  //                                 },
  //                               ),
  //                             )
  //                             // TextButton(
  //                             //     onPressed: () {
  //                             //       Navigator.pop(context);
  //                             //     },
  //                             //     child: const Text16(
  //                             //       text: 'Закрыть',
  //                             //       textColor: MyColors.black,
  //                             //     ))
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               );
  //             } else {
  //               return const Center(
  //                 child: Text('No data available.'),
  //               );
  //             }
  //           } else {
  //             return const Center(
  //               child: Text('Unexpected state.'),
  //             );
  //           }
  //         },
  //       );
  //     },
  //   );
  // }

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
      // await wordCount.resetCallCount();
      // await showEmptyTable(context, wordCount);
      await showTableDialog(context, wordCount, true);
    } else if (result == false) {
      // Действие, выполняемое после нажатия "Нет"
      final wordCount = WordCount(filePath: textes.first.filePath, fileText: textes.first.fileText);
      // Если нужно сбросить счётчик времени
      // await wordCount.resetCallCount();
      // await wordCount.checkCallInfo();
      await showTableDialog(context, wordCount, false);
    }
  }

  // Future<void> _showWordInputDialog(String word, List<WordEntry> wordEntries) async {
  //   List<String> words = WordCount(filePath: textes.first.filePath, fileText: textes.first.fileText).getAllWords();
  //   Set<String> uniqueSet = <String>{};
  //   List<String> result = [];
  //   for (String item in words.reversed) {
  //     if (uniqueSet.add(item)) {
  //       result.add(item);
  //     }
  //   }
  //   result.reversed.toList();
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       String newWord = word;

  //       return AlertDialog(
  //         title: const Text('Изменить слово'),
  //         content: Autocomplete<String>(
  //           optionsBuilder: (TextEditingValue textEditingValue) {
  //             if (textEditingValue.text == '') {
  //               return const Iterable<String>.empty();
  //             }
  //             String pattern = textEditingValue.text.toLowerCase();
  //             final Iterable<String> matchingStart = result.where((String option) {
  //               return option.toLowerCase().startsWith(pattern);
  //             });
  //             final Iterable<String> matchingAll = result.where((String option) {
  //               return option.toLowerCase().contains(pattern) && !option.toLowerCase().startsWith(pattern);
  //             });
  //             return matchingStart.followedBy(matchingAll);
  //           },
  //           onSelected: (String selection) {
  //             // debugPrint('You just selected $selection');
  //             newWord = selection;
  //           },
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text16(text: 'Отмена', textColor: MyColors.black),
  //           ),
  //           TextButton(
  //             onPressed: () async {
  //               // debugPrint('Введенное слово: $newWord');
  //               // debugPrint('onPressed word: $word');
  //               if (result.contains(newWord)) {
  //                 await updateWordInTable(word, newWord, wordEntries);
  //                 Navigator.of(context).pop();
  //               } else {
  //                 Fluttertoast.showToast(
  //                   msg: 'Введенного слова нет в книге',
  //                   toastLength: Toast.LENGTH_SHORT, // Длительность отображения
  //                   gravity: ToastGravity.BOTTOM,
  //                 );
  //               }
  //             },
  //             child: const Text16(text: 'Сохранить', textColor: MyColors.black),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  Future<void> _showWordInputDialog(String word, List<WordEntry> wordEntries, Map<String, int> wordsMap) async {
    String searchText = '';
    List<String> filteredWords = [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Card(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 0),
                            child: Center(
                              child: Text24(
                                text: 'Выберите слова',
                                textColor: MyColors.black,
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                  child: TextField(
                                    onChanged: (value) {
                                      setState(() {
                                        searchText = value.toLowerCase();
                                        filteredWords = wordsMap.keys.where((word) => word.toLowerCase().startsWith(searchText)).toList();
                                        filteredWords.sort((a, b) => a.compareTo(b));
                                        filteredWords.sort((a, b) => wordsMap[b]!.compareTo(wordsMap[a]!));
                                      });
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Введите текст',
                                      border: const OutlineInputBorder(),
                                      disabledBorder: const OutlineInputBorder(),
                                      focusedBorder: const OutlineInputBorder(),
                                      focusColor: MyColors.purple,
                                      floatingLabelStyle:
                                          isDarkTheme ? const TextStyle(color: MyColors.white) : const TextStyle(color: MyColors.black),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: DataTable(
                                      columnSpacing: 45.0,
                                      showBottomBorder: false,
                                      horizontalMargin: 20,
                                      dataTextStyle: const TextStyle(fontFamily: 'Roboto', color: MyColors.black),
                                      columns: const [
                                        DataColumn(
                                          label: SizedBox(
                                            child: Text15(text: 'Слово', textColor: MyColors.black),
                                          ),
                                        ),
                                        DataColumn(
                                          label: SizedBox(
                                            child: Text15(
                                              text: 'Количество',
                                              textColor: MyColors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                      rows: const []),
                                ),
                                Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: forTable == false ? MediaQuery.of(context).size.height * 0.42 : MediaQuery.of(context).size.height * 0.2,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: DataTable(
                                        columnSpacing: 0.0,
                                        showBottomBorder: false,
                                        dataTextStyle: const TextStyle(fontFamily: 'Roboto', color: MyColors.black),
                                        clipBehavior: Clip.hardEdge,
                                        headingRowHeight: 0,
                                        horizontalMargin: 10,
                                        columns: const [
                                          DataColumn(
                                            label: Flexible(
                                              child: Text15(
                                                text: '',
                                                textColor: MyColors.black,
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Flexible(
                                              child: Text15(
                                                text: '',
                                                textColor: MyColors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                        rows: searchText.isEmpty
                                            ? const <DataRow>[]
                                            : List<DataRow>.generate(
                                                filteredWords.length,
                                                (index) => DataRow(
                                                  cells: [
                                                    DataCell(
                                                      SizedBox(
                                                        width: MediaQuery.of(context).size.width * 0.3,
                                                        child: TextButton(
                                                          style: const ButtonStyle(alignment: Alignment.centerLeft),
                                                          onPressed: () async {
                                                            List<String> test = [filteredWords[index]];
                                                            // print(test);
                                                            test = await WordCount().getNounsByList(test);
                                                            // print('after $test');
                                                            if (test.length != 1) {
                                                              Fluttertoast.showToast(msg: 'Данное слово не существительное');
                                                              return;
                                                            } else {
                                                              await updateWordInTable(word, filteredWords[index], wordEntries);
                                                              Navigator.of(context).pop();
                                                            }
                                                          },
                                                          child: Text(
                                                            filteredWords[index],
                                                            style: TextStyle(
                                                                fontFamily: 'Roboto',
                                                                fontSize: 15,
                                                                fontWeight: FontWeight.normal,
                                                                overflow: TextOverflow.ellipsis,
                                                                color: isDarkTheme ? MyColors.white : MyColors.black),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      SizedBox(
                                                        width: MediaQuery.of(context).size.width * 0.3,
                                                        child: TextForTable(
                                                          text: '${wordsMap[filteredWords[index]] ?? 0}',
                                                          textColor: MyColors.black,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                      ),
                                    ))
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
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
      final ipa = await WordCount(filePath: textes.first.filePath, fileText: textes.first.fileText).getIPA(translation);

      wordEntries[index] = WordEntry(
        word: newWord,
        count: count,
        translation: translation,
        ipa: ipa,
      );

      setState(() {});
    } else {
      // debugPrint('Word $oldWord not found in the list.');
    }
  }

  Future<void> addNewWord(List<WordEntry> wordEntries, WordCount wordCount, int length) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> words = await WordCount(filePath: textes.first.filePath, fileText: textes.first.fileText).getAllWords();
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
        await saveReadingPosition(_scrollController.position.pixels, textes.first.filePath);
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
                          onTap: () async {
                            await saveProgress();
                            await saveReadingPosition(_scrollController.position.pixels, textes.first.filePath);
                            await _savePageCountToLocalStorage();
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
                          Padding(
                            padding: const EdgeInsets.fromLTRB(35, 0, 0, 0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, RouteNames.readerSettings).then((value) => loadStylePreferences());
                              },
                              child: Icon(
                                CustomIcons.sliders,
                                size: 28,
                                color: Theme.of(context).iconTheme.color,
                              ),
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
                    ? Border.all(color: const Color.fromRGBO(0, 255, 163, 1), width: 2)
                    : Border.all(width: 0, color: Colors.transparent)),
            child: SafeArea(
              top: true,
              minimum: visible
                  ? const EdgeInsets.only(top: 0, left: 8, right: 8)
                  : orientations[currentOrientationIndex] == DeviceOrientation.landscapeLeft ||
                          orientations[currentOrientationIndex] == DeviceOrientation.landscapeRight
                      ? const EdgeInsets.only(top: 0, left: 8, right: 8)
                      : const EdgeInsets.only(top: 40, left: 8, right: 8),
              child: Stack(children: [
                ListView.builder(
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
                GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      // Скролл вниз / следующая страница
                      _scrollController.animateTo(_scrollController.position.pixels + MediaQuery.of(context).size.height * 0.92,
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
                                // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                                //   systemNavigationBarColor: Theme.of(context) == darkTheme() ? MyColors.blackGray : MyColors.white,
                                //   systemNavigationBarIconBrightness: Theme.of(context) == darkTheme() ? Brightness.light : Brightness.light,
                                // ));
                                SystemChrome.setEnabledSystemUIMode(
                                  SystemUiMode.manual,
                                  overlays: [
                                    SystemUiOverlay.top,
                                    SystemUiOverlay.bottom,
                                  ],
                                );
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
                                // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                                //   systemNavigationBarColor: Theme.of(context) == darkTheme() ? MyColors.blackGray : MyColors.white,
                                //   systemNavigationBarIconBrightness: Theme.of(context) == darkTheme() ? Brightness.light : Brightness.dark,
                                // ));
                                SystemChrome.setEnabledSystemUIMode(
                                  SystemUiMode.manual,
                                  overlays: [
                                    SystemUiOverlay.top,
                                    SystemUiOverlay.bottom,
                                  ],
                                );
                              } else {
                                // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
                                SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
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
                        _scrollController.animateTo(_scrollController.position.pixels - MediaQuery.of(context).size.height * 0.92,
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
              ]),
            )),
        bottomNavigationBar: BottomAppBar(
          // color: Theme.of(context).colorScheme.primary,
          color: visible ? Theme.of(context).colorScheme.primary : backgroundColor,
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: visible ? 85 : 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: !visible
                      ? [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                            child: Container(
                              width: MediaQuery.of(context).size.width / 8,
                              alignment: Alignment.topLeft,
                              child: Stack(
                                alignment: Alignment.centerLeft,
                                children: [
                                  Transform.rotate(
                                    angle: 90 * 3.14159265 / 180,
                                    child: Icon(
                                      Icons.battery_full,
                                      // color: Theme.of(context).iconTheme.color,
                                      color: isDarkTheme
                                          ? backgroundColor.value == 0xff1d1d21
                                              ? MyColors.white
                                              : MyColors.black
                                          : backgroundColor.value != 0xff1d1d21
                                              ? MyColors.black
                                              : MyColors.white,
                                      size: 28,
                                    ),
                                  ),
                                  Text(
                                    _batteryLevel.toInt() >= 100 ? '${_batteryLevel.toString()}%' : ' ${_batteryLevel.toString()}%',
                                    style: TextStyle(
                                      color: isDarkTheme
                                          ? backgroundColor.value == 0xff1d1d21
                                              ? MyColors.black
                                              : MyColors.white
                                          : backgroundColor.value != 0xff1d1d21
                                              ? MyColors.white
                                              : MyColors.black,
                                      fontSize: 7,
                                      fontFamily: 'Tektur',
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),

                                  // Text7(
                                  //   text: '${_batteryLevel.toString()}%',
                                  //   textColor: MyColors.white,
                                  // ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Text(
                                  textes.isNotEmpty
                                      ? (textes[0].title.toString().length + textes[0].author.toString().length > 30
                                          ? textes[0].author.toString().length > 19
                                              ? '${textes[0].author.toString()}. ${textes[0].title.toString().substring(0, textes[0].title.toString().length ~/ 4.5)}...'
                                              : '${textes[0].author.toString()}. ${textes[0].title.toString().substring(0, textes[0].title.toString().length ~/ 1.5)}...'
                                          : '${textes[0].author.toString()}. ${textes[0].title.toString()}')
                                      : 'Нет названия',
                                  style: TextStyle(
                                      color: isDarkTheme
                                          ? backgroundColor.value == 0xff1d1d21
                                              ? MyColors.white
                                              : MyColors.black
                                          : backgroundColor.value != 0xff1d1d21
                                              ? MyColors.black
                                              : MyColors.white,
                                      fontFamily: 'Tektur',
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 3, 10, 0),
                            child: Container(
                              width: MediaQuery.of(context).size.width / 8,
                              alignment: Alignment.topRight,
                              child: Text(
                                '${_scrollPosition.toStringAsFixed(1)}%',
                                style: TextStyle(
                                    color: isDarkTheme
                                        ? backgroundColor.value == 0xff1d1d21
                                            ? MyColors.white
                                            : MyColors.black
                                        : backgroundColor.value != 0xff1d1d21
                                            ? MyColors.black
                                            : MyColors.white,
                                    fontFamily: 'Tektur',
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold),
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
                    height: visible ? 85 : 0,
                    child: SingleChildScrollView(
                      child: Container(
                          alignment: AlignmentDirectional.topEnd,
                          color: Theme.of(context).colorScheme.primary,
                          child: Column(
                            children: [
                              _scrollController.hasClients
                                  ? SliderTheme(
                                      data: const SliderThemeData(showValueIndicator: ShowValueIndicator.always),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          SliderTheme(
                                            data: const SliderThemeData(
                                                trackHeight: 3,
                                                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 9),
                                                trackShape: RectangularSliderTrackShape()),
                                            child: Container(
                                              width: orientations[currentOrientationIndex] == DeviceOrientation.landscapeLeft ||
                                                      orientations[currentOrientationIndex] == DeviceOrientation.landscapeRight
                                                  ? MediaQuery.of(context).size.width / 1.19
                                                  : MediaQuery.of(context).size.width / 1.12,
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
                                                        ? "${((position / _scrollController.position.maxScrollExtent) * 100).toStringAsFixed(1)}%"
                                                        : (position / _scrollController.position.maxScrollExtent) * 100 > 0
                                                            ? "${((position / _scrollController.position.maxScrollExtent) * 100).toStringAsFixed(1)}%"
                                                            : "0.0%"
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
                                                inactiveColor:
                                                    isDarkTheme ? const Color.fromRGBO(96, 96, 96, 1) : const Color.fromRGBO(96, 96, 96, 1),
                                                thumbColor: isDarkTheme ? MyColors.white : const Color.fromRGBO(29, 29, 33, 1),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context).size.width / 11,
                                            alignment: Alignment.center,
                                            child: Text11(
                                                text: visible
                                                    ? (position / _scrollController.position.maxScrollExtent) * 100 == 100
                                                        ? "${((position / _scrollController.position.maxScrollExtent) * 100).toStringAsFixed(1)}%"
                                                        : (position / _scrollController.position.maxScrollExtent) * 100 > 0
                                                            ? "${((position / _scrollController.position.maxScrollExtent) * 100).toStringAsFixed(1)}%"
                                                            : "0.0%"
                                                    : "",
                                                textColor: MyColors.darkGray),
                                          )
                                        ],
                                      ),
                                    )
                                  : const Text("Загрузка..."),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  height: 2,
                                  child: Container(
                                    color: isDarkTheme ? MyColors.darkGray : MyColors.black,
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      await savePositionAndExtent();
                                      switchOrientation();
                                    },
                                    child: Icon(
                                      CustomIcons.turn,
                                      color: Theme.of(context).iconTheme.color,
                                      size: 27,
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
                                      size: 27,
                                    ),
                                  ),
                                  const Padding(padding: EdgeInsets.only(right: 30)),
                                  GestureDetector(
                                    onTap: () async {
                                      switch (isBorder) {
                                        case false:
                                          var temp = await loadWordCountFromLocalStorage(textes.first.filePath);
                                          if (temp.filePath != '') {
                                            replaceWordsWithTranslation(temp.wordEntries);
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
                                          if (timeElapsed.inHours > 24) {
                                            // if (timeElapsed.inMilliseconds > 1) {
                                            wordModeDialog(context);
                                          } else {
                                            Fluttertoast.showToast(
                                              msg:
                                                  'Новый перевод завтра в ${(lastCallTimestamp.add(const Duration(days: 1)).hour)}:${(lastCallTimestamp.add(const Duration(days: 1)).minute)}',
                                              toastLength: Toast.LENGTH_LONG,
                                              gravity: ToastGravity.BOTTOM,
                                            );
                                          }

                                          // print('isTrans = $isTrans');
                                          break;
                                      }
                                    },
                                    child: Icon(
                                      CustomIcons.wm,
                                      color: Theme.of(context).iconTheme.color,
                                      size: 27,
                                    ),
                                  )
                                ],
                              )
                            ],
                          )),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
