// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:merlin/UI/router.dart';
import 'package:merlin/domain/data_providers/avatar_provider.dart';
import 'package:merlin/domain/data_providers/token_provider.dart';
import 'package:merlin/functions/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:uni_links/uni_links.dart';

class SplashSreenViewModel {
  final BuildContext context;

  SplashSreenViewModel(this.context) {
    _initAsync();
  }

  Future<void> _initAsync() async {
    await initUniLinks();
    await AvatarProvider.initAsync();
    await TokenProvider().initAsync();
    await getFirstName();
    Navigator.pushReplacementNamed(context, RouteNames.main);
    await getLocation();
  }

  // ignore: unused_field
  String? _link = 'unknown';
  Future<void> initUniLinks() async {
    // Подписываемся на поток приходящих ссылок
    linkStream.listen((String? link) {
      // Если ссылка есть, обновляем состояние приложения
      _link = link;
    }, onError: (err) {
      // Обработка ошибок
      _link = 'Failed to get latest link: $err';
    });

    // Получение начальной ссылки
    try {
      String? initialLink = await getInitialLink();
      // Fluttertoast.showToast(
      //   msg: 'LINK: $initialLink',
      //   toastLength: Toast.LENGTH_SHORT, // Длительность отображения
      //   gravity: ToastGravity.BOTTOM,
      // );
      if (initialLink != null) {
        Uri uri = Uri.parse(initialLink);
        //token = uri.queryParameters['token']!;
        TokenProvider().setToken(uri.queryParameters['token']!);
        // Fluttertoast.showToast(
        //   msg: 'СОХРАНЯЮ ТАКОЙ ТОКЕН В ЛОКАЛКУ: ${uri.queryParameters['token']!}',
        //   toastLength: Toast.LENGTH_SHORT, // Длительность отображения
        //   gravity: ToastGravity.BOTTOM,
        // );
        // debugPrint('СОХРАНЯЮ ТАКОЙ ТОКЕН В ЛОКАЛКУ: ${TokenProvider().getToken}');
      }
    } catch (err) {
      _link = 'Failed to get initial link: $err';
    }
  }

  Future<void> getFirstName() async {
    String firstName;
    String avatarFromServer;
    // ignore: unused_local_variable
    Uint8List? saveAvatar;
    final prefs = await SharedPreferences.getInstance();
    String? token = await TokenProvider().getToken();
    // debugPrint('сейчас я на запросе');
    // Fluttertoast.showToast(
    //   msg: 'сейчас я на запросе, токен: $token',
    //   toastLength: Toast.LENGTH_SHORT, // Длительность отображения
    //   gravity: ToastGravity.BOTTOM,
    // );
    // debugPrint('вот токен::::::::::::::::::::::::::::::::::::::::::::::::::::::::=$token');
    if (token != null) {
      String url = 'https://fb2.cloud.leam.pro/api/account/';
      final data = json.decode((await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $token',
      }))
          .body);
      firstName = data['firstName'].toString();
      // debugPrint('имя из запроса $firstName');
      // Fluttertoast.showToast(
      //   msg: 'имя из запроса $firstName',
      //   toastLength: Toast.LENGTH_SHORT, // Длительность отображения
      //   gravity: ToastGravity.BOTTOM,
      // );
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
