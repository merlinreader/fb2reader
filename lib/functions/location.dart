import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

Future<String> getLocation() async {
  PermissionStatus permission = await Permission.locationWhenInUse.status;
  if (permission != PermissionStatus.granted) {
    permission = await Permission.locationWhenInUse.request();
    if (permission != PermissionStatus.granted) {
      throw Exception('Разрешение на определение местоположения не предоставлено');
    }
  }
  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
  List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);
  Placemark placemark = placemarks[0];
  String? country = placemark.country;
  String? adminArea = placemark.administrativeArea;
  String? locality = placemark.locality;
  return ('$country, $adminArea, $locality');
}
