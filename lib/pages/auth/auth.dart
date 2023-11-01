import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:path/path.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Auth extends StatefulWidget {
  const Auth({Key? key}) : super(key: key);

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  final controller = WebViewController();
  String? currentUser;

  @override
  void initState() {
    super.initState();
    controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    controller.loadRequest(Uri.parse(
        'https://oauth.telegram.org/auth?bot_id=6409671267&origin=https%3A%2F%2Ffb2.cloud.leam.pro&embed=1&request_access=write&return_to=https%3A%2F%2Ffb2.cloud.leam.pro%2Fapi%2Faccount%2Fwidget'));
    controller.setNavigationDelegate(NavigationDelegate(
      onPageStarted: (url) {
        setState(() {
          currentUser = url.toString();
        });
        print(currentUser);
      },
    ));
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
