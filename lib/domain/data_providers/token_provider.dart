import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';

class TokenProvider {
  static final TokenProvider _instance = TokenProvider._();
  factory TokenProvider() => _instance;

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  String? _token = '';
  final StreamController<String?> _tokenController = StreamController<String?>.broadcast();
  Stream<String?> get onTokenChanged => _tokenController.stream;

  TokenProvider._();

  Future<void> initAsync() async {
    _token = await _secureStorage.read(key: 'token');
  }

  Future<String?> getToken() async {
    return _token;
  }

  Future<void> setToken(String token) async {
    await _secureStorage.write(key: 'token', value: token);
    _token = token;
    _tokenController.add(token);
  }
}
