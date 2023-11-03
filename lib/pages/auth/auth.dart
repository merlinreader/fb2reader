import 'dart:core';
import 'dart:convert';
import 'package:flutter/material.dart';
//import 'package:geocoding/geocoding.dart';
//import 'package:path/path.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class Auth extends StatefulWidget {
  const Auth({Key? key}) : super(key: key);

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  final controller = WebViewController();
  String? currentUser;
  String? firstName;
  String? secondName;
  String? id;

  @override
  void initState() {
    super.initState();
    controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    controller.loadRequest(Uri.parse(
        'https://oauth.telegram.org/auth?bot_id=6409671267&origin=https%3A%2F%2Ffb2.cloud.leam.pro&embed=1&request_access=write&return_to=https%3A%2F%2Ffb2.cloud.leam.pro%2Fapi%2Faccount%2Fwidget'));
    controller.setNavigationDelegate(NavigationDelegate(
      onPageStarted: (url) {
        setState(() {
          //currentUser = url.toString();
          Uri uri = Uri.parse(url);
          firstName = uri.queryParameters['first_name'];
          secondName = uri.queryParameters['second_name'];
          id = uri.queryParameters['id'];
          print(firstName);
          print(secondName);
          print(id);
          postData(firstName, secondName, id);
        });
      },
    ));
  }

  Future<void> postData(String? firstName, String? secondName, String? id) async {
    final url = Uri.parse('https://fb2.cloud.leam.pro/api/account/login');

    final Map<String, String?> data = {
      'firstName': firstName,
      'lastName': secondName,
      'telegramId': id,
    };

    final response = await http.post(
      url,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      print('я тут САЛАГИ');
    } else {
      print('Ошибка при выполнении POST-запроса: ${response.statusCode}');
      print(response.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
        ),
        body: WebViewWidget(
          controller: controller,
        ),
      ),
    );
  }
}
