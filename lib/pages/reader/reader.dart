// ignore_for_file: use_build_context_synchronously, sized_box_for_whitespace

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
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
  const ReaderPage({Key? key, String? fileTitle}) : super(key: key);

  @override
  Reader createState() => Reader();
}

class Reader extends State with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  String path = '/storage/emulated/0/Android/data/com.example.merlin/files/';
  late Book book;
  bool loading = true;
  double fontSize = 18;
  bool isDarkTheme = false;
  bool visible = false;
  int _batteryLevel = 0;
  double _scrollPosition = 0.0;
  List<DeviceOrientation> orientations = [
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeRight,
  ];
  int currentOrientationIndex = 0;
  double position = 0;
  Timer? _actionTimer;
  bool isBorder = false;
  bool? isTrans = false;
  final Battery _battery = Battery();
  double pageSize = 0;
  int pageCount = 0;
  double pagesForCount = 0;
  double nowPage = 0;
  double pageFormula = 0;
  double pageResult = 0;
  int lastPageCount = 0;
  String translatedText = '';

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _getBatteryLevel();
    _scrollController.addListener(_updateScrollPercentage);
    WidgetsBinding.instance.addObserver(this);

    super.initState();
    loadStylePreferences();
    _initPage();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Future.delayed(const Duration(milliseconds: 300), () async {
        final prefs = await SharedPreferences.getInstance();
        while (!loading) {
          lastPageCount = prefs.getInt('pageCount-${book.filePath}') ?? 0;
          // print('READER lastpagecount $lastPageCount');
          prefs.setInt('lastPageCount-${book.filePath}', lastPageCount);
          pageSize = MediaQuery.of(context).size.height;
          await saveDateTime(pageSize);

          if (_scrollController.hasClients) {
            _scrollController.jumpTo(book.lastPosition);
          }
          _loadPageCountFromLocalStorage();
          if (book.text.isNotEmpty) {
            break;
          }
        }
      });
    });
  }

  @override
  Future<void> dispose() async {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setPreferredOrientations([orientations[0]]);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      await _savePageCountToLocalStorage();
      await getPageCount(book.title, isBorder);
      final prefs = await SharedPreferences.getInstance();
      await book.updateStageInFile(_scrollPosition / 100, _scrollController.position.pixels);
      lastPageCount = prefs.getInt('pageCount-${book.filePath}') ?? 0;
      prefs.setInt('lastPageCount-${book.filePath}', lastPageCount);
    }
  }

  Future<void> disposeBook() async {
    await book.updateStageInFile(_scrollPosition / 100, _scrollController.position.pixels);
  }

  Future<void> _initPage() async {
    await initBook();
  }

  Future<void> initBook() async {
    final prefs = await SharedPreferences.getInstance();
    String? fileTitle = prefs.getString('fileTitle');
    if (fileTitle != null) {
      List<FileSystemEntity> files = Directory(path).listSync();
      String targetFileName = '$fileTitle.json';
      FileSystemEntity? targetFile;
      try {
        targetFile = files.firstWhere(
          (file) => file is File && file.uri.pathSegments.last == targetFileName,
        );
      } catch (e) {
        Navigator.pop(context);
        Fluttertoast.showToast(
          msg: 'Файл не найден',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        return;
      }

      try {
        String content = await (targetFile as File).readAsString();
        Map<String, dynamic> jsonMap = jsonDecode(content);
        book = Book.fromJson(jsonMap);
        loading = false;
        setState(() {});
      } catch (e) {
        // print('Error reading file: $e');
        // Navigator.pop(context);
        Fluttertoast.showToast(
          msg: 'Ошибка чтения файла',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
      // print('Длина текста книги = ${book.text.replaceAll(RegExp(r'\['), '').replaceAll(RegExp(r'\]'), '').length}');
    }
  }

  void _getBatteryLevel() async {
    final batteryLevel = await _battery.batteryLevel;
    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  Future<void> saveDateTime(double pageSize) async {
    final prefs = await SharedPreferences.getInstance();
    DateTime currentTime = DateTime.now();
    prefs.setString('savedDateTime', currentTime.toIso8601String());
    prefs.setDouble('pageSize', pageSize);
  }

  void _updateScrollPercentage() {
    if (_scrollController.position.maxScrollExtent == 0) {
      return;
    }
    _scrollPosition = (_scrollController.position.pixels / _scrollController.position.maxScrollExtent) * 100;
    pagesForCount = _scrollController.position.maxScrollExtent / pageSize;
    if (visible) {
      setState(() {
        position = _scrollController.position.pixels;
      });
    } else if (_scrollController.position.pixels - position >= pageSize / 1.25 ||
        position - _scrollController.position.pixels >= pageSize / 1.25 ||
        _scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      setState(() {
        position = _scrollController.position.pixels;
      });
    }
    setState(() {
      nowPage = _scrollController.position.pixels / pageSize;
      pageFormula = pagesForCount / (book.text.length.toDouble() / 900);
      pageResult = nowPage / pageFormula;
    });
  }

  Future<void> _loadPageCountFromLocalStorage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    pageCount = (prefs.getInt('pageCount-${book.filePath}') ?? 0);
  }

  Future<void> _savePageCountToLocalStorage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    pageCount = ((_scrollPosition / 100) * pagesForCount).toInt();
    // print("Сохраняем pageCount $pageCount");
    prefs.setInt('pageCount-${book.filePath}', pageResult.round());
    // print("Сохраняем pageCount ${pageResult.round()}");
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

  double? savedPosition;
  double? savedMaxExtent;

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

      await Future.delayed(const Duration(milliseconds: 200));
      double newMaxExtent = _scrollController.position.maxScrollExtent;
      double newPositionRatio = savedPosition! / savedMaxExtent!;
      double newPosition = newPositionRatio * newMaxExtent;
      newPosition = min(newPosition, newMaxExtent);
      _scrollController.jumpTo(newPosition);
    }
  }

  Future<void> saveSettings(bool isDarkTheme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', isDarkTheme);
  }

  void replaceWordsWithTranslation(List<WordEntry> wordEntries) async {
    final prefs = await SharedPreferences.getInstance();
    await _savePageCountToLocalStorage();
    await getPageCount(book.title, isBorder);
    await book.updateStageInFile(_scrollPosition / 100, _scrollController.position.pixels);
    lastPageCount = prefs.getInt('pageCount-${book.filePath}') ?? 0;
    prefs.setInt('lastPageCount-${book.filePath}', lastPageCount);

    prefs.setBool('${book.filePath}-isTrans', true);
    isBorder = true;
    translatedText = book.text.replaceAll(RegExp(r'\['), '').replaceAll(RegExp(r'\]'), '');

    for (var entry in wordEntries) {
      var escapedWord = RegExp.escape(entry.word);
      var pattern = '(?<!\\p{L})$escapedWord(?!\\p{L})';
      var wordRegExp = RegExp(pattern, caseSensitive: false, unicode: true);

      translatedText = translatedText.replaceAllMapped(wordRegExp, (match) {
        final matchedWord = match.group(0)!;
        return matchCase(matchedWord, entry.translation ?? '');
      });
    }

    await prefs.setString('lastCallTranslate', DateTime.now().toIso8601String());
    isTrans = prefs.getBool('${book.filePath}-isTrans');
    setState(() {
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

  // ИЗМЕНИТЬ НА SECURE STORAGE
  Future<WordCount> loadWordCountFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    String key = 'WMWORDS';
    String? storedData = prefs.getString(key);
    if (storedData != null) {
      Map<String, dynamic> decodedData = jsonDecode(storedData);
      WordCount wordCount = WordCount.fromJson(decodedData);
      return wordCount;
    } else {
      return WordCount();
    }
  }

  Future<void> saveWordCountToLocalstorage(WordCount wordCount) async {
    final prefs = await SharedPreferences.getInstance();
    String key = 'WMWORDS';

    // Сериализация WordCount в JSON и сохранение.
    String wordCountString = jsonEncode(wordCount.toJson());
    await prefs.setString(key, wordCountString);
  }

  void wordModeDialog(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    int getWords = prefs.getInt('words') ?? 10;
    // print('wordModeDialog $getWords');
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AgreementDialog(
        getWords: getWords,
      ),
    );

    const FlutterSecureStorage storage = FlutterSecureStorage();

    if (result == true) {
      await _savePageCountToLocalStorage();
      await getPageCount(book.title, isBorder);
      final prefs = await SharedPreferences.getInstance();
      await book.updateStageInFile(_scrollPosition / 100, _scrollController.position.pixels);
      lastPageCount = prefs.getInt('pageCount-${book.filePath}') ?? 0;
      prefs.setInt('lastPageCount-${book.filePath}', lastPageCount);
      // Действие, выполняемое после нажатия "Да"
      final wordCount = WordCount(filePath: book.filePath, fileText: book.text);
      // await wordCount.resetCallCount();
      // await showEmptyTable(context, wordCount);
      var timeNow = DateTime.now();
      String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(timeNow);
      await storage.write(key: 'TimeDialog', value: formattedDateTime);

      await showTableDialog(context, wordCount, true);
    } else if (result == false) {
      await _savePageCountToLocalStorage();
      await getPageCount(book.title, isBorder);
      final prefs = await SharedPreferences.getInstance();
      await book.updateStageInFile(_scrollPosition / 100, _scrollController.position.pixels);
      lastPageCount = prefs.getInt('pageCount-${book.filePath}') ?? 0;
      prefs.setInt('lastPageCount-${book.filePath}', lastPageCount);
      // Действие, выполняемое после нажатия "Нет"
      final wordCount = WordCount(filePath: book.filePath, fileText: book.text);
      // Если нужно сбросить счётчик времени
      // await wordCount.resetCallCount();
      // await wordCount.checkCallInfo();
      var timeNow = DateTime.now();
      String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(timeNow);
      await storage.write(key: 'TimeDialog', value: formattedDateTime);
      await showTableDialog(context, wordCount, false);
    }
  }

  showTableDialog(BuildContext context, WordCount wordCount, bool confirm) async {
    var wordsMap = await WordCount(filePath: book.filePath, fileText: book.text).getAllWordCounts();
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
                                                final themeProvider = Provider.of<ThemeProvider>(context);

                                                return DataRow(
                                                  cells: [
                                                    DataCell(
                                                      forTable == false
                                                          ? SizedBox(
                                                              width: MediaQuery.of(context).size.width * 0.23,
                                                              child: Text(
                                                                entry.word,
                                                                style: TextStyle(
                                                                    overflow: TextOverflow.ellipsis,
                                                                    color: themeProvider.isDarkTheme ? MyColors.white : MyColors.black),
                                                              ),
                                                            )
                                                          : Text(
                                                              entry.word,
                                                              style: TextStyle(
                                                                  overflow: TextOverflow.ellipsis,
                                                                  color: themeProvider.isDarkTheme ? MyColors.white : MyColors.black),
                                                            ),
                                                    ),
                                                    DataCell(
                                                      forTable == false
                                                          ? SizedBox(
                                                              width: MediaQuery.of(context).size.width * 0.275,
                                                              child: Text(
                                                                '[ ${entry.ipa} ]',
                                                                style: TextStyle(
                                                                    overflow: TextOverflow.ellipsis,
                                                                    color: themeProvider.isDarkTheme ? MyColors.white : MyColors.black),
                                                              ),
                                                            )
                                                          : SizedBox(
                                                              width: MediaQuery.of(context).size.width * 0.14,
                                                              child: Text(
                                                                '[ ${entry.ipa} ]',
                                                                style: TextStyle(
                                                                    overflow: TextOverflow.ellipsis,
                                                                    color: themeProvider.isDarkTheme ? MyColors.white : MyColors.black),
                                                              ),
                                                            ),
                                                    ),
                                                    DataCell(
                                                      forTable == false
                                                          ? Padding(
                                                              padding: const EdgeInsets.only(left: 10),
                                                              child: SizedBox(
                                                                width: MediaQuery.of(context).size.width * 0.5,
                                                                child: Text(
                                                                  entry.translation!.isNotEmpty ? entry.translation! : 'N/A',
                                                                  style:
                                                                      TextStyle(color: themeProvider.isDarkTheme ? MyColors.white : MyColors.black),
                                                                ),
                                                              ),
                                                            )
                                                          : Text(
                                                              entry.translation!.isNotEmpty ? entry.translation! : 'N/A',
                                                              style: TextStyle(color: themeProvider.isDarkTheme ? MyColors.white : MyColors.black),
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
                  ));
            }
          },
        );
      },
    );
  }

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
                final themeProvider = Provider.of<ThemeProvider>(context);

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
                                          themeProvider.isDarkTheme ? const TextStyle(color: MyColors.white) : const TextStyle(color: MyColors.black),
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
                                                                color: themeProvider.isDarkTheme ? MyColors.white : MyColors.black),
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
      final count = WordCount(filePath: book.filePath, fileText: book.text).getWordCount(newWord);
      final translation = await WordCount(filePath: book.filePath, fileText: book.text).translateToEnglish(newWord);
      final ipa = await WordCount(filePath: book.filePath, fileText: book.text).getIPA(translation);

      wordEntries[index] = WordEntry(
        word: newWord,
        count: count,
        translation: translation,
        ipa: ipa,
      );

      setState(() {});
    }
  }

  Future<void> showSavedWords(BuildContext context, String filePath) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return FutureBuilder<WordCount>(
          future: loadWordCountFromLocalStorage(),
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
                                        final themeProvider = Provider.of<ThemeProvider>(context);

                                        return DataRow(
                                          cells: [
                                            DataCell(
                                              forTable == false
                                                  ? SizedBox(
                                                      width: MediaQuery.of(context).size.width * 0.23,
                                                      child: Text(
                                                        entry.word,
                                                        style: TextStyle(
                                                            overflow: TextOverflow.ellipsis,
                                                            color: themeProvider.isDarkTheme ? MyColors.white : MyColors.black),
                                                      ),
                                                    )
                                                  : Text(
                                                      entry.word,
                                                      style: TextStyle(
                                                          overflow: TextOverflow.ellipsis,
                                                          color: themeProvider.isDarkTheme ? MyColors.white : MyColors.black),
                                                    ),
                                            ),
                                            DataCell(
                                              forTable == false
                                                  ? SizedBox(
                                                      width: MediaQuery.of(context).size.width * 0.275,
                                                      child: Text(
                                                        '[ ${entry.ipa} ]',
                                                        style: TextStyle(
                                                            overflow: TextOverflow.ellipsis,
                                                            color: themeProvider.isDarkTheme ? MyColors.white : MyColors.black),
                                                      ),
                                                    )
                                                  : SizedBox(
                                                      width: MediaQuery.of(context).size.width * 0.14,
                                                      child: Text(
                                                        '[ ${entry.ipa} ]',
                                                        style: TextStyle(
                                                            overflow: TextOverflow.ellipsis,
                                                            color: themeProvider.isDarkTheme ? MyColors.white : MyColors.black),
                                                      ),
                                                    ),
                                            ),
                                            DataCell(
                                              forTable == false
                                                  ? Padding(
                                                      padding: const EdgeInsets.only(left: 10),
                                                      child: SizedBox(
                                                        width: MediaQuery.of(context).size.width * 0.5,
                                                        child: Text(
                                                          entry.translation!.isNotEmpty ? entry.translation! : 'N/A',
                                                          style: TextStyle(color: themeProvider.isDarkTheme ? MyColors.white : MyColors.black),
                                                        ),
                                                      ),
                                                    )
                                                  : Text(
                                                      entry.translation!.isNotEmpty ? entry.translation! : 'N/A',
                                                      style: TextStyle(color: themeProvider.isDarkTheme ? MyColors.white : MyColors.black),
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return WillPopScope(
        onWillPop: () async {
          await book.updateStageInFile(_scrollPosition / 100, _scrollController.position.pixels);

          await _savePageCountToLocalStorage();
          await getPageCount(book.title, isBorder);
          Navigator.pop(context, true);
          return true;
        },
        child: !loading
            ? Scaffold(
                appBar: visible
                    ? PreferredSize(
                        preferredSize: Size(MediaQuery.of(context).size.width, 50),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          child: AppBar(
                              leading: GestureDetector(
                                  onTap: () async {
                                    await book.updateStageInFile(_scrollPosition / 100, position);
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
                                        book.author.isNotEmpty && book.customTitle.isNotEmpty
                                            ? '${book.author.toString()}. ${book.customTitle.toString()}'
                                            : 'Нет автора',
                                        softWrap: false,
                                        overflow: TextOverflow.fade,
                                        style: TextStyle(
                                            fontSize: 16, fontFamily: 'Tektur', color: themeProvider.isDarkTheme ? MyColors.white : MyColors.black),
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
                              return _scrollController.hasClients
                                  ? () {
                                      return Text(
                                        isBorder ? translatedText : book.text.replaceAll(RegExp(r'\['), '').replaceAll(RegExp(r'\]'), ''),
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
                            }),
                        GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              // Скролл вниз / следующая страница
                              _scrollController.animateTo(_scrollController.position.pixels + MediaQuery.of(context).size.height * 0.925,
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
                                      showSavedWords(context, book.filePath);
                                    },
                                    onVerticalDragEnd: (dragEndDetails) async {
                                      if (dragEndDetails.primaryVelocity! > 0) {
                                        showSavedWords(context, book.filePath);
                                      }
                                    },
                                    onTap: () {
                                      setState(() {
                                        visible = !visible;
                                      });
                                      if (visible) {
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
                                      showSavedWords(context, book.filePath);
                                    },
                                    onTap: () {
                                      setState(() {
                                        visible = !visible;
                                      });
                                      if (visible) {
                                        SystemChrome.setEnabledSystemUIMode(
                                          SystemUiMode.manual,
                                          overlays: [
                                            SystemUiOverlay.top,
                                            SystemUiOverlay.bottom,
                                          ],
                                        );
                                      } else {
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
                                // Скролл вверх / предыдущая страница
                                _scrollController.animateTo(_scrollController.position.pixels - MediaQuery.of(context).size.height * 0.925,
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
                                              color: themeProvider.isDarkTheme
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
                                              color: themeProvider.isDarkTheme
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
                                          book.customTitle.isNotEmpty && book.author.isNotEmpty
                                              ? (book.customTitle.toString().length + book.author.toString().length > 30
                                                  ? book.author.toString().length > 19
                                                      ? '${book.author.toString()}. ${book.customTitle.toString().substring(0, book.customTitle.toString().length ~/ 4.5)}...'
                                                      : '${book.author.toString()}. ${book.customTitle.toString().substring(0, book.customTitle.toString().length ~/ 1.5)}...'
                                                  : '${book.author.toString()}. ${book.customTitle.toString()}')
                                              : 'Нет названия',
                                          style: TextStyle(
                                              color: themeProvider.isDarkTheme
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
                                            color: themeProvider.isDarkTheme
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
                                                        activeColor: themeProvider.isDarkTheme ? MyColors.white : const Color.fromRGBO(29, 29, 33, 1),
                                                        inactiveColor: themeProvider.isDarkTheme
                                                            ? const Color.fromRGBO(96, 96, 96, 1)
                                                            : const Color.fromRGBO(96, 96, 96, 1),
                                                        thumbColor: themeProvider.isDarkTheme ? MyColors.white : const Color.fromRGBO(29, 29, 33, 1),
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
                                            color: themeProvider.isDarkTheme ? MyColors.darkGray : MyColors.black,
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
                                            onTap: () async {
                                              final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
                                              themeProvider.isDarkTheme = !themeProvider.isDarkTheme;
                                              await saveSettings(themeProvider.isDarkTheme);
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
                                                  const FlutterSecureStorage storage = FlutterSecureStorage();
                                                  var timeNow = DateTime.now();
                                                  var timeLast = await storage.read(key: 'TimeDialog');
                                                  if (timeLast != null) {
                                                    var elapsedTime = timeNow.difference(DateTime.parse(timeLast));
                                                    if (elapsedTime.inHours >= 24) {
                                                      wordModeDialog(context);
                                                    } else {
                                                      var tempWE = await loadWordCountFromLocalStorage();
                                                      if (tempWE.filePath != '') {
                                                        replaceWordsWithTranslation(tempWE.wordEntries);
                                                      }
                                                    }
                                                  } else {
                                                    wordModeDialog(context);
                                                  }
                                                  break;
                                                default:
                                                  await _savePageCountToLocalStorage();
                                                  await getPageCount(book.title, isBorder);
                                                  final prefs = await SharedPreferences.getInstance();
                                                  await book.updateStageInFile(_scrollPosition / 100, _scrollController.position.pixels);
                                                  lastPageCount = prefs.getInt('pageCount-${book.filePath}') ?? 0;
                                                  prefs.setInt('lastPageCount-${book.filePath}', lastPageCount);
                                                  isBorder = false;
                                                  setState(() {});
                                                  const FlutterSecureStorage storage = FlutterSecureStorage();
                                                  var timeLast = await storage.read(key: 'TimeDialog');
                                                  if (timeLast != null) {
                                                    final formattedTime =
                                                        DateFormat('MM.dd HH:mm').format(DateTime.parse(timeLast).add(const Duration(days: 1)));

                                                    Fluttertoast.showToast(
                                                      msg: 'Новый перевод будет доступен $formattedTime',
                                                      toastLength: Toast.LENGTH_LONG,
                                                      gravity: ToastGravity.BOTTOM,
                                                    );
                                                  }
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
              )
            : Scaffold(
                body: Container(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ));
  }
}
