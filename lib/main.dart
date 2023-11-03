import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:merlin/UI/theme/theme.dart';
import 'package:merlin/functions/location.dart';
import 'package:merlin/style/colors.dart';
import 'package:merlin/UI/router.dart';
import 'package:merlin/pages/settings/settings.dart';
import 'package:provider/provider.dart';
import 'package:merlin/pages/splashScreen/splashScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

//В ФАЙЛЕ BUTTON ПРИМЕР ИСПОЛЬЗОВАНИЯ КНОПОК

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(), // Создание экземпляра ThemeProvider
      child: MerlinApp(),
    ),
  );
  getLocation();
}

class MerlinApp extends StatelessWidget {
  final _router = AppRouter();

  MerlinApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
    ));
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Merlin',
          theme: themeProvider.isDarkTheme ? darkTheme() : lightTheme(),
          initialRoute: RouteNames.splashScreen,
          routes: _router.routes,
          //home: SplashScreen(),
        );
      },
    );
  }
}

class ThemeProvider with ChangeNotifier {
  bool _isDarkTheme = false;

  bool get isDarkTheme => _isDarkTheme;

  set isDarkTheme(bool value) {
    _isDarkTheme = value;
    setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: value ? MyColors.darkGray : MyColors.white,
    ));
    notifyListeners(); // Notifies the listeners when the theme changes.
  }

  ThemeProvider() {
    _initAsync();
  }

  Future<void> _initAsync() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
  }

  void setSystemUIOverlayStyle(SystemUiOverlayStyle style) {
    SystemChrome.setSystemUIOverlayStyle(style);
  }
}
