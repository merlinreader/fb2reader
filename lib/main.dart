import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:merlin/UI/theme/theme.dart';
import 'package:merlin/style/colors.dart';
import 'package:merlin/UI/router.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:appmetrica_plugin/appmetrica_plugin.dart';

AppMetricaConfig get _config =>
    const AppMetricaConfig('122d6c68-55d1-46bf-bf45-27036d6307cf', logs: true);


Future<void> main() async {
  AppMetrica.runZoneGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();
    AppMetrica.activate(_config);
    runApp(
      ChangeNotifierProvider(
        create: (context) => ThemeProvider(), // Создание экземпляра ThemeProvider
        child: const MerlinApp(),
      ),
    );
  });
}

class MerlinApp extends StatefulWidget {
  const MerlinApp({super.key});

  @override
  State<MerlinApp> createState() => _MerlinAppState();
}

class _MerlinAppState extends State<MerlinApp> {
  final _router = AppRouter();
  final str = "DEMO";
  // ignore: unused_field

  @override
  void initState() {
    super.initState();
    AppMetrica.reportEvent('My first AppMetrica event!');
    if(str.length != 4) {
      throw UnimplementedError();
    }
    //initUniLinks();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Merlin',
          theme: themeProvider.isDarkTheme ? darkTheme() : lightTheme(),
          initialRoute: RouteNames.splashScreen,
          routes: _router.routes,
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
      systemNavigationBarColor: value ? MyColors.blackGray : MyColors.white,
      systemNavigationBarIconBrightness: value ? Brightness.light : Brightness.dark,
    ));
    notifyListeners();
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
