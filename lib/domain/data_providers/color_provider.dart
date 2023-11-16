import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ColorKeys {
  static String readerBackgroundColor = 'readerBackgroundColor';
  static String readerTextColor = 'readerTextColor';
}

class ColorProvider {
  static final ColorProvider _instance = ColorProvider._internal();

  factory ColorProvider() {
    return _instance;
  }

  ColorProvider._internal();

  Future<Color?> getColor(String key) async {
    final prefs = await SharedPreferences.getInstance();
    String? hex = prefs.getString(key);
    if (hex == null) return null;
    return HexColor.fromHex(hex);
  }

  Future<void> setColor(String key, Color color) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, color.toHex());
  }
}

extension HexColor on Color {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
