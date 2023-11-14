import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:merlin/pages/recent/recent.dart';
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
    print('Данные отправлены успешно!');
  } else {
    print('Ошибка при отправке данных: ${response.statusCode}');
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
  // Список со значениями прочитынных страниц
  List<int> countsInSimpleMode = [];
  List<String> filenames = [];
  print('Started');
  for (final entry in books) {
    filenames.add(entry.fileName);
  }

  for (final entry in filenames) {
    int countFromStorage = prefs.getInt('pageCountSimpleMode-$entry') ?? 0;
    if (countFromStorage > 0) {
      countsInSimpleMode.add(countFromStorage);
    }
  }

  for (final entry in countsInSimpleMode) {
    print(entry);
  }
}
