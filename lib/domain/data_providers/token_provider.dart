import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class _TokenKeys {
  static String token = 'token';
}

class TokenProvider {
  static final TokenProvider _instance = TokenProvider._();

  factory TokenProvider() {
    return _instance;
  }

  String? _token = '';

  TokenProvider._();

  final _tokenController = StreamController<String?>.broadcast();
  Stream<String?> get onTokenChanged => _tokenController.stream;

  Future<void> initAsync() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_TokenKeys.token);
  }

  Future<String?> getToken() async {
    return _token;
  }

  // Future<void> setToken(String token) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   prefs.setString(_TokenKeys.token, token);
  //   _token = token;
  // }
  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_TokenKeys.token, token);
    _token = token;

    _tokenController.add(token);
  }
}
