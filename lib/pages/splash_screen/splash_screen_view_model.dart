// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:merlin/UI/router.dart';
import 'package:merlin/domain/data_providers/avatar_provider.dart';
import 'package:merlin/domain/data_providers/token_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SplashSreenViewModel {
  final BuildContext context;

  SplashSreenViewModel(this.context) {
    _initAsync();
  }

  Future<void> _initAsync() async {
    await AvatarProvider.initAsync();
    await TokenProvider().initAsync();
    debugPrint('загрузка');
    await getFirstName();
    debugPrint('сейчас я на загрузке');
    //await Future.delayed(Duration(seconds: 5));
    Navigator.pushReplacementNamed(context, RouteNames.main);
  }

  Future<void> getFirstName() async {
    String firstName;
    String avatarFromServer;
    // ignore: unused_local_variable
    Uint8List? saveAvatar;
    final prefs = await SharedPreferences.getInstance();
    String? token = await TokenProvider().getToken();
    debugPrint('сейчас я на запросе');
    debugPrint('вот токен::::::::::::::::::::::::::::::::::::::::::::::::::::::::=$token');
    if (token != null) {
      String url = 'https://fb2.cloud.leam.pro/api/account/';
      final data = json.decode((await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $token',
      }))
          .body);
      firstName = data['firstName'].toString();
      debugPrint('имя из запроса $firstName');
      avatarFromServer = data['avatar']['picture'];
      prefs.setString('firstName', firstName);
      try {
        await AvatarProvider.setAvatarUrl(avatarFromServer);
        final response = await http.get(Uri.parse(avatarFromServer));
        await AvatarProvider.setAvatarBytes(response.bodyBytes);
        saveAvatar = response.bodyBytes;
      } catch (_) {}
    }
  }
}
