import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:merlin/UI/theme/theme.dart';
import 'package:merlin/style/colors.dart';
import 'package:merlin/UI/router.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';
import 'package:merlin/domain/data_providers/token_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(), // Создание экземпляра ThemeProvider
      child: const MerlinApp(),
    ),
  );
}

class MerlinApp extends StatefulWidget {
  const MerlinApp({super.key});

  @override
  State<MerlinApp> createState() => _MerlinAppState();
}

class _MerlinAppState extends State<MerlinApp> {
  final _router = AppRouter();
  // ignore: unused_field
  String? _link = 'unknown';
  @override
  void initState() {
    super.initState();
    initUniLinks();
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

  Future<void> initUniLinks() async {
    // Подписываемся на поток приходящих ссылок
    linkStream.listen((String? link) {
      // Если ссылка есть, обновляем состояние приложения
      if (!mounted) return;
      setState(() {
        _link = link;
      });
    }, onError: (err) {
      // Обработка ошибок
      if (!mounted) return;
      setState(() {
        _link = 'Failed to get latest link: $err';
      });
    });

    // Получение начальной ссылки
    try {
      String? initialLink = await getInitialLink();
      if (initialLink != null) {
        setState(() {
          Uri uri = Uri.parse(initialLink);
          //token = uri.queryParameters['token']!;
          TokenProvider().setToken(uri.queryParameters['token']!);
          debugPrint('СОХРАНЯЮ ТАКОЙ ТОКЕН В ЛОКАЛКУ: ${TokenProvider().getToken}');
        });
      }
    } catch (err) {
      setState(() {
        _link = 'Failed to get initial link: $err';
      });
    }
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
