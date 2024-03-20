import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:merlin/functions/book.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:merlin/functions/location.dart';

Future<DateTime?> getSavedDateTime() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? savedDateTimeString = prefs.getString('savedDateTime');
  if (savedDateTimeString != null) {
    return DateTime.parse(savedDateTimeString);
  }
  return null;
}

Future<double?> getPageSize() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  double? savedPageSize = prefs.getDouble('pageSize');
  if (savedPageSize != null) {
    return savedPageSize;
  }
  return null;
}

List<Book> books = [];

Future<void> processFiles() async {
  final Directory? externalDir = await getExternalStorageDirectory();
  final String path = '${externalDir?.path}/books';
  List<FileSystemEntity> files = Directory(path).listSync();
  List<Future<Book>> futures = [];

  for (FileSystemEntity file in files) {
    if (file is File) {
      Future<Book> futureBook = _readBookFromFile(file);
      futures.add(futureBook);
    }
  }

  List<Book> loadedBooks = await Future.wait(futures);

  books.addAll(loadedBooks);

  // print('Длина списка с книжками ${books.length}');
}

Future<Book> _readBookFromFile(File file) async {
  try {
    String content = await file.readAsString();
    Map<String, dynamic> jsonMap = jsonDecode(content);
    Book book = Book.fromJson(jsonMap);
    return book;
  } catch (e) {
    // print('Error reading file: $e');
    return Book(filePath: '', text: '', title: '', author: '', lastPosition: 0, imageBytes: null, progress: 0, customTitle: '');
  }
}

getPageCount(String inputFilePath, bool isWM) async {
  const FlutterSecureStorage storage = FlutterSecureStorage();
  String? tokenFromStorage;
  try {
    tokenFromStorage = await storage.read(key: 'token');
  } catch (e) {
    tokenFromStorage == null;
  }
  String token = '';
  if (tokenFromStorage != null) {
    token = tokenFromStorage;
  }
  // print(token);
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  await processFiles();

  Map<int, bool> dataToSend = {};

  for (final entry in books) {
    if (entry.title == inputFilePath) {
      int countFromStorage = prefs.getInt('pageCount-${entry.filePath}') ?? 0;
      prefs.remove('pageCount-${entry.title}');
      int lastCountFromStorage = prefs.getInt('lastPageCount-${entry.filePath}') ?? 0;
      // print("countfromst $countFromStorage");
      // print("lastfromst $lastCountFromStorage");
      int diff = countFromStorage - lastCountFromStorage;
      diff = diff < 0 ? 0 : diff;

      // print('isWM $inputFilePath = $isWM and entry.fileName = ${entry.filePath}');
      if (isWM == true) {
        if (countFromStorage > 0) {
          if (countFromStorage > lastCountFromStorage) {
            final dataToAdd = <int, bool>{diff: true};
            dataToSend.addEntries(dataToAdd.entries);
          } else {
            final dataToAdd = <int, bool>{0: true};
            dataToSend.addEntries(dataToAdd.entries);
          }
        }
      } else {
        if (countFromStorage > lastCountFromStorage) {
          final dataToAdd = <int, bool>{diff: false};
          dataToSend.addEntries(dataToAdd.entries);
        } else {
          final dataToAdd = <int, bool>{0: false};
          dataToSend.addEntries(dataToAdd.entries);
        }
      }
    }
  }
  books.clear();
  double pageSize = await getPageSize() ?? 0;
  DateTime savedDateTime = await getSavedDateTime() ?? DateTime.now();
  DateTime nowDateTime = DateTime.now();
  Duration difference = nowDateTime.difference(savedDateTime);
  int differenceInSeconds = difference.inSeconds;
  // print('pageSize = $pageSize');
  // print('savedDateTime = $savedDateTime');
  // print('differenceInSeconds = $differenceInSeconds');
  int pageCountSimpleMode = 0;
  int pageCountWordMode = 0;
  String nowDataUTC = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ+00:00").format(DateTime.now().toUtc());
  pageCountWordMode = 0;
  pageCountSimpleMode = 0;

  for (final entry in dataToSend.entries) {
    if (entry.value == true) {
      double speed = pageSize / differenceInSeconds;
      // print('WM entry.key = ${entry.key}');
      // print('speed WM = $speed sym/sec');
      if (33.3 > speed) {
        pageCountWordMode = pageCountWordMode + entry.key;
      }
    }
    if (entry.value == false) {
      double speed = pageSize / differenceInSeconds;
      // print('SM entry.key = ${entry.key}');
      // print('speed SM = $speed sym/sec');
      if (33.3 > speed) {
        pageCountSimpleMode = pageCountSimpleMode + entry.key;
      }
    }
  }

  // print('pageCountWordMode $pageCountWordMode');
  // print('pageCountSimpleMode $pageCountSimpleMode');
  // print('nowDataUTC $nowDataUTC');
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
  // Fluttertoast.showToast(msg: 'pageSM: $pageCountSimpleMode | pageWM: $pageCountWordMode', toastLength: Toast.LENGTH_LONG);
  // print('pageSM: $pageCountSimpleMode | pageWM: $pageCountWordMode');
  if (token == '') {
    if (prefs.getString("deviceId") == null) {
      saveDeviceIdToLocalStorage();
    }
    await postAnonymStatisticData(pageCountSimpleMode, pageCountWordMode, nowDataUTC);
  } else {
    await postUserStatisticData(token, pageCountSimpleMode, pageCountWordMode, nowDataUTC);
  }
}

void saveDeviceIdToLocalStorage() async {
  final prefs = await SharedPreferences.getInstance();
  var uuid = const Uuid();
  var deviceId = uuid.v4();
  await prefs.setString('deviceId', deviceId);
}

Future<void> postUserStatisticData(String token, int pageCountSimpleMode, int pageCountWordMode, String nowDataUTC) async {
  if (pageCountSimpleMode > 0 || pageCountWordMode > 0) {
    final Map<String, dynamic> data = {
      "pageCountSimpleMode": pageCountSimpleMode,
      "pageCountWordMode": pageCountWordMode,
      "date": nowDataUTC,
    };
    // print(token);
    // print(data);
    final url = Uri.parse('https://merlin.su/statistic/user');
    // ignore: unused_local_variable
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    // print(response.body);
    if (response.statusCode == 200) {
      // print('Данные статистики ЮЗЕРА отправлены успешно! 200');
      // print("$pageCountSimpleMode, $pageCountWordMode");
    }
    if (response.statusCode == 201) {
      // print('Данные статистики ЮЗЕРА отправлены успешно! 201');
    } else {
      // print('Ошибка при отправке данных статистики ЮЗЕРА: ${response.reasonPhrase} (${response.statusCode})');
    }
  }
}

Future<void> postAnonymStatisticData(int pageCountSimpleMode, int pageCountWordMode, String nowDataUTC) async {
  // print('Anonym func pagesSM $pageCountSimpleMode pagesWM $pageCountWordMode');
  if (pageCountSimpleMode > 0 || pageCountWordMode > 0) {
    final prefs = await SharedPreferences.getInstance();
    getLocation();
    String? location = prefs.getString('location');
    String? country, area, city;

    if (location != null) {
      List<String> locationParts = location.split(',');
      if (locationParts.length >= 3) {
        country = locationParts[0].trim();
        area = locationParts[1].trim();
        city = locationParts[2].trim();
      }
    }

    final Map<String, dynamic> data = {
      "deviceId": prefs.getString("deviceId"),
      "country": country,
      "area": area,
      "city": city,
      "pageCountSimpleMode": pageCountSimpleMode,
      "pageCountWordMode": pageCountWordMode,
      "date": nowDataUTC,
    };
    // print(data);
    final url = Uri.parse('https://merlin.su/statistic/anonym');
    // ignore: unused_local_variable
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    // print(response.body);
    if (response.statusCode == 200) {
      // print('Данные статистики и местоположения МЕРЛИНА отправлены успешно! 200');
      // print("принт $pageCountSimpleMode, $pageCountWordMode");
    }
    if (response.statusCode == 201) {
      // print('Данные статистики и местоположения МЕРЛИНА отправлены успешно! 201');
      // print("принт201 $pageCountSimpleMode, $pageCountWordMode");
    } else {
      // print('Ошибка при отправке данных статистики и местоположения МЕРЛИНА: ${response.reasonPhrase} (${response.statusCode})');
    }
  }
}
