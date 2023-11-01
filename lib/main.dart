import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:merlin/UI/theme/theme.dart';
import 'package:merlin/functions/location.dart';
import 'package:merlin/style/colors.dart';
import 'package:merlin/UI/router.dart';
import 'package:merlin/pages/settings/settings.dart';

//В ФАЙЛЕ BUTTON ПРИМЕР ИСПОЛЬЗОВАНИЯ КНОПОК

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: MyColors.white,
  ));
  runApp(MerlinApp());
  getLocation();
}

class MerlinApp extends StatelessWidget {
  final _router = AppRouter();

  MerlinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Merlin',
      theme: isDarkTheme ? darkTheme() : lightTheme(),
      initialRoute: RouteNames.main,
      routes: _router.routes,
    );
  }
}
