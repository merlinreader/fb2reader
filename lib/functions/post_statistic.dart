import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:merlin/pages/recent/recent.dart';
import 'package:merlin/pages/wordmode/wordmode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:merlin/functions/location.dart';

// метод который составляет список прочитанных страниц
getPageCountSimpleMode() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString('token') ?? '';
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
    int diff = countFromStorage - lastCountFromStorage;
    diff = diff < 0 ? 0 : diff;

    if (wordCounts.isNotEmpty) {
      if (entry.fileName == wordCounts[index].filePath) {
        if (countFromStorage > 0) {
          if (lastCountFromStorage != 0 &&
              countFromStorage > lastCountFromStorage) {
            final dataToAdd = <int, bool>{diff: true};
            dataToSend.addEntries(dataToAdd.entries);
          } else {
            final dataToAdd = <int, bool>{0: true};
            dataToSend.addEntries(dataToAdd.entries);
          }
        }
      }
    } else {
      if (lastCountFromStorage != 0 &&
          countFromStorage > lastCountFromStorage) {
        final dataToAdd = <int, bool>{diff: false};
        dataToSend.addEntries(dataToAdd.entries);
      } else {
        final dataToAdd = <int, bool>{0: false};
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
      // pageCountSimpleMode = pageCountWordMode + entry.key;
    }
    if (entry.value == false) {
      pageCountSimpleMode = pageCountSimpleMode + entry.key;
    }
  }
  print('pageCountWordMode $pageCountWordMode');
  print('pageCountSimpleMode $pageCountSimpleMode');
  print('nowDataUTC $nowDataUTC');
  // print(dataToSend);
  // for (final entry in dataToSend.entries) {
  //   int number = entry.key;
  //   bool value = entry.value;
  //   pageCountSimpleMode += number;
  //   if (value) {
  //     pageCountWordMode += number;
  //   }
  // }

// Присвоение значений переменным data
  if (token == '') {
    if (prefs.getString("deviceId") == null) {
      saveDeviceIdToLocalStorage();
    }
    await postAnonymStatisticData(
        pageCountSimpleMode, pageCountWordMode, nowDataUTC);
  } else {
    await postUserStatisticData(
        token, pageCountSimpleMode, pageCountWordMode, nowDataUTC);
  }
}

void saveDeviceIdToLocalStorage() async {
  final prefs = await SharedPreferences.getInstance();
  var uuid = const Uuid();
  var deviceId = uuid.v4();
  await prefs.setString('deviceId', deviceId);
}

Future<void> postUserStatisticData(String token, int pageCountSimpleMode,
    int pageCountWordMode, String nowDataUTC) async {
  final Map<String, dynamic> data = {
    "pageCountSimpleMode": pageCountSimpleMode,
    "pageCountWordMode": pageCountWordMode,
    "date": nowDataUTC,
  };
  print(token);
  print(data);
  final url = Uri.parse('https://fb2.cloud.leam.pro/api/statistic/user');
  final response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(data),
  );
  print(jsonEncode(data));
  // if (response.statusCode == 200) {
  //   print('Данные отправлены успешно!');
  // } else {
  //   print('Ошибка при отправке данных: ${response.statusCode}');
  // }
}

Future<void> postAnonymStatisticData(
    int pageCountSimpleMode, int pageCountWordMode, String nowDataUTC) async {
  final prefs = await SharedPreferences.getInstance();
  getLocation();
  final Map<String, dynamic> data = {
    "deviceId": prefs.getString("deviceId"),
    "country": prefs.getString("country"),
    "area": prefs.getString("adminArea"),
    "city": prefs.getString("locality"),
    "pageCountSimpleMode": pageCountWordMode,
    "pageCountWordMode": pageCountSimpleMode,
    "date": nowDataUTC,
  };
  print(data);
  final url = Uri.parse('https://fb2.cloud.leam.pro/api/statistic/anonym');
  final response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode(data),
  );
  print(response.body);
  if (response.statusCode == 200) {
    print('Данные отправлены успешно!');
  } else {
    print('Ошибка при отправке данных: ${response.statusCode}');
  }
}
