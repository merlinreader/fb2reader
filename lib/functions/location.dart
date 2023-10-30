// ignore_for_file: avoid_print

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

Future<Map<String, String>> getLocation() async {
  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
  List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);
  Placemark placemark = placemarks[0];
  String? country = placemark.country;
  String? area = placemark.administrativeArea;
  String? locality = placemark.locality;

  final prefs = await SharedPreferences.getInstance();
  prefs.setString('country', country ?? '');
  prefs.setString('adminArea', area ?? '');
  prefs.setString('locality', locality ?? '');

  final locationData = {
    'country': country ?? '',
    'area': area ?? '',
    'city': locality ?? '',
  };

  // Отправляем данные на сервер
  await sendLocationDataToServer(locationData);

  return locationData;
}

Future<void> sendLocationDataToServer(Map<String, String> locationData) async {
  const url = 'https://fb2.cloud.leam.pro/api/account/geo';

  final response = await http.patch(
    Uri.parse(url),
    // headers: {'Authorization': 'Bearer $token'},
    body: locationData,
  );

  if (response.statusCode == 200) {
    print('Данные успешно отправлены на сервер');
  } else {
    print('Ошибка при отправке данных на сервер: ${response.reasonPhrase}');
  }
}

Future<String> getSavedLocation() async {
  final prefs = await SharedPreferences.getInstance();
  final country = prefs.getString('country') ?? '';
  final area = prefs.getString('adminArea') ?? '';
  final locality = prefs.getString('locality') ?? '';
  return '$country, $area, $locality';
}
