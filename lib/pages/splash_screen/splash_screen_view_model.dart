import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:merlin/UI/router.dart';
import 'package:merlin/domain/data_providers/avatar_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SplashSreenViewModel {
  final BuildContext context;

  SplashSreenViewModel(this.context) {
    _initAsync();
  }

  Future<void> _initAsync() async {
    await AvatarProvider.initAsync();
    Navigator.pushReplacementNamed(context, RouteNames.main);
  }

  Future<void> getFirstName() async {
    String firstName;
    String avatarFromServer;
    Uint8List? saveAvatar;
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    if (token != '') {
      String url = 'https://fb2.cloud.leam.pro/api/account/';
      final data = json.decode((await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $token',
      }))
          .body);
      firstName = data['firstName'].toString();
      avatarFromServer = data['avatar']['picture'];
      await prefs.setString('firstName', firstName);
      try {
        await AvatarProvider.setAvatarUrl(avatarFromServer);
        final response = await http.get(Uri.parse(avatarFromServer));
        await AvatarProvider.setAvatarBytes(response.bodyBytes);
        saveAvatar = response.bodyBytes;
      } catch (_) {}
    }
  }
}
