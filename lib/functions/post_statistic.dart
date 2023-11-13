import 'dart:convert';
import 'package:http/http.dart' as http;

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
