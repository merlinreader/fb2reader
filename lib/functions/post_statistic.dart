import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:merlin/pages/recent/recent.dart';
import 'package:merlin/pages/wordmode/wordmode.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> postStatisticData(String token) async {
  final Map<String, dynamic> data = {
    //"pageCountSimpleMode": pageCountSimpleMode,
    //"pageCountWordMode": pageCountWordMode,
    "date": DateTime.now().toIso8601String(),
  };

  final url = Uri.parse('https://fb2.cloud.leam.pro/api/statistic');
  final response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(data),
  );

  if (response.statusCode == 200) {
    // print('Данные отправлены успешно!');
  } else {
    // print('Ошибка при отправке данных: ${response.statusCode}');
  }
}

// метод который составляет список прочитынных страниц
getPageCountSimpleMode() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? imageDataJson = prefs.getString('booksKey');
  List<ImageInfo> books = [];
  if (imageDataJson != null) {
    books = (jsonDecode(imageDataJson) as List)
        .map((item) => ImageInfo.fromJson(item))
        .toList();
  }
  List<WordCount> wordCounts = [];
  for (final entry in books) {
    String? storedData = prefs.getString('${entry.fileName}-words');
    if (storedData != null) {
      List<dynamic> decodedData = jsonDecode(storedData);
      WordCount wordCount = WordCount.fromJson(decodedData[0]);
      wordCounts.add(wordCount);
    }
  }

  Map<int, bool> dataToSend = {};
  int index = 0;
  for (final entry in books) {
    int countFromStorage = prefs.getInt('pageCount-${entry.fileName}') ?? 0;
    int lastCountFromStorage =
        prefs.getInt('lastPageCount-${entry.fileName}') ?? 0;
    int diff = lastCountFromStorage - countFromStorage;
    diff = diff < 0 ? diff : 0;
    if (entry.fileName == wordCounts[index].filePath) {
      if (countFromStorage > 0) {
        if (lastCountFromStorage != 0 &&
            countFromStorage < lastCountFromStorage) {
          final dataToAdd = <int, bool>{0: true};
          dataToSend.addEntries(dataToAdd.entries);
        } else {
          final dataToAdd = <int, bool>{diff: true};
          dataToSend.addEntries(dataToAdd.entries);
        }
      }
    } else {
      if (lastCountFromStorage != 0 &&
          countFromStorage < lastCountFromStorage) {
        final dataToAdd = <int, bool>{0: false};
        dataToSend.addEntries(dataToAdd.entries);
      } else {
        final dataToAdd = <int, bool>{diff: false};
        dataToSend.addEntries(dataToAdd.entries);
      }
    }
  }
  int pageCountSimpleMode = 0;
  int pageCountWordMode = 0;
  String nowDataUTC = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ+00:00")
      .format(DateTime.now().toUtc());
  for (final entry in dataToSend.entries) {
    if (entry.value == true) {
      pageCountWordMode = pageCountWordMode + entry.key;
    } else {
      pageCountSimpleMode = pageCountSimpleMode + entry.key;
    }
  }
  print('pageCountWordMode $pageCountWordMode');
  print('pageCountSimpleMode $pageCountSimpleMode');
  print('nowDataUTC $nowDataUTC');
  // print(dataToSend);
}
