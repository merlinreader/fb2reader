import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, String>> getLocation() async {
  PermissionStatus status = await Permission.locationWhenInUse.status;
  if (!status.isGranted) {
    await Permission.locationWhenInUse.request();
    if (!status.isGranted && status.isPermanentlyDenied) {
      openAppSettings();
    }
  }
  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
  List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);
  Placemark placemark = placemarks[0];
  String? country = placemark.country;
  String? area = placemark.administrativeArea;
  String? locality = placemark.locality;

  final prefs = await SharedPreferences.getInstance();
  prefs.setString("country", country ?? '');
  prefs.setString("adminArea", area ?? '');
  prefs.setString("locality", locality ?? '');
  Map<String, String> locationData = {
    'country': country ?? '',
    'area': area ?? '',
    'city': locality ?? '',
  };
  // Отправляем данные на сервер
  await sendLocationDataToServer(locationData, prefs.getString('token') ?? '');

  return locationData;
}

Future<void> sendLocationDataToServer(
    Map<String, String> locationData, String? token) async {
  const url = 'https://fb2.cloud.leam.pro/api/account/geo';

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
  } else {
    // print('Ошибка при отправке данных на сервер: ${response.reasonPhrase}');
  }
}

Future<String> getSavedLocation() async {
  final prefs = await SharedPreferences.getInstance();
  final country = prefs.getString('country') ?? 'Russia';
  final area = prefs.getString('adminArea') ?? '';
  final locality = prefs.getString('locality') ?? '';
  if (country.isNotEmpty && area.isNotEmpty && locality.isNotEmpty) {
    return '$country, $area, $locality';
  } else {
    return 'Нет данных о местоположении';
  }
}
