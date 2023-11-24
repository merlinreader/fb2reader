import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

class _AvatarKeys {
  static String avatatBytes = 'avatar_bytes';
  static String avatarUrl = 'avatar_url';
}

class AvatarProvider {
  static final AvatarProvider _instance = AvatarProvider._();

  factory AvatarProvider() {
    return _instance;
  }

  static Uint8List? _avatarBytes;
  static String? _avatarUrl;

  AvatarProvider._();

  static Future<void> initAsync() async {
    final prefs = await SharedPreferences.getInstance();
    final codeUnits = prefs.getString(_AvatarKeys.avatatBytes)?.codeUnits;
    if (codeUnits != null) {
      _avatarBytes = Uint8List.fromList(codeUnits);
    }
    _avatarUrl = prefs.getString(_AvatarKeys.avatarUrl);
  }

  static Future<Uint8List?> getAvatarBytes() async {
    return _avatarBytes;
  }

  static Future<String?> getAvatarUrl() async {
    return _avatarUrl;
  }

  static Future<void> setAvatarBytes(Uint8List avatarBytes) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_AvatarKeys.avatatBytes, String.fromCharCodes(avatarBytes));
    _avatarBytes = avatarBytes;
  }

  static Future<void> setAvatarUrl(String avatarUrl) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_AvatarKeys.avatarUrl, avatarUrl);
    _avatarUrl = avatarUrl;
  }

  static Future<void> removeAvatarBytes() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_AvatarKeys.avatatBytes);
    _avatarBytes = null;
  }

  static Future<void> removeAvatarUrl() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_AvatarKeys.avatarUrl);
    _avatarUrl = null;
  }
}
