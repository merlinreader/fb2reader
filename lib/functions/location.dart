import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, String>> getLocation() async {
  PermissionStatus status = await Permission.locationWhenInUse.status;
  if (!status.isGranted) {
    await Permission.locationWhenInUse.request();
  }
  Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  Map<String, String> locationData = {
    'latitude': position.latitude.toString(),
    'longitude': position.longitude.toString(),
  };

  const FlutterSecureStorage secureStorage = FlutterSecureStorage();
  String? tokenSecure;
  try {
    tokenSecure = await secureStorage.read(key: 'token');
  } catch (e) {
    tokenSecure = null;
  }

  if (tokenSecure != null) {
    await sendLocationDataToServer(locationData, tokenSecure.toString());
  } else {
    convertCoordsToAdress(locationData);
  }
  return locationData;
}

Future<void> sendLocationDataToServer(Map<String, String> locationData, String? token) async {
  const url = 'https://merlin.su/account/geo-by-coords';
  try {
    // ignore: unused_local_variable
    final response = await http.patch(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(locationData),
    );

    if (response.statusCode == 200) {
      // print('Данные успешно отправлены на сервер');
      final jsonResponse = json.decode(response.body);
      setLocation(jsonResponse);
    } else {
      // print('Ошибка при отправке данных на сервер: ${response.reasonPhrase}');
    }
  } catch (_) {}
}

Future<void> convertCoordsToAdress(Map<String, String> locationData) async {
  final String url = 'https://merlin.su/account/geo-by-coords?latitude=${locationData['latitude']}&longitude=${locationData['longitude']}';

  try {
    final Uri uri = Uri.parse(url);
    final response = await http.get(
      uri,
    );

    if (response.statusCode == 200) {
      // print('Данные успешно отправлены на сервер');
      final jsonResponse = json.decode(response.body);
      setLocation(jsonResponse);
      // print(jsonResponse);
    } else {
      // print('Ошибка при отправке данных на сервер: ${response.reasonPhrase}');
    }
  } catch (_) {}
}

Future<void> setLocation(Map<String, dynamic> jsonResponse) async {
  final prefs = await SharedPreferences.getInstance();
  final country = jsonResponse['country'] ?? 'Russia';
  final area = jsonResponse['area'] ?? '';
  final city = jsonResponse['city'] ?? '';

  if (country.isNotEmpty && area.isNotEmpty && city.isNotEmpty) {
    final locationString = '$country, $area, $city';
    await prefs.setString('location', locationString);
    // print('Локация сохранена: $locationString');
  } else {
    // print('Невозможно сохранить локацию: отсутствуют данные');
  }
}

Future<String> getSavedLocation() async {
  final prefs = await SharedPreferences.getInstance();
  final locationString = prefs.getString('location');
  if (locationString != null && locationString.isNotEmpty) {
    return locationString;
  } else {
    return 'Нет данных о местоположении';
  }
}
