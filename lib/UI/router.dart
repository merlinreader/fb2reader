import 'package:flutter/material.dart';

import 'package:merlin/pages/page.dart';
import 'package:merlin/pages/profile/profile.dart';
import 'package:merlin/pages/profile/profile_view_model.dart';
import 'package:merlin/pages/reader/reader.dart';
import 'package:merlin/pages/settings/settings.dart';
import 'package:merlin/pages/splash_screen/splash_screen.dart';
import 'package:provider/provider.dart';

abstract class RouteNames {
  static const String splashScreen = '/';
  static const String main = '/main';
  static const String profile = '/main/profile';
  static const String reader = '/main/reader';
  static const String readerSettings = '/main/reader/settings';
  static const String auth = '/main/auth';
}

class AppRouter {
  final routes = <String, Widget Function(BuildContext)>{
    RouteNames.splashScreen: (context) => SplashScreen.create(context),
    RouteNames.main: (context) => const AppPage(),
    RouteNames.profile: (context) => ChangeNotifierProvider(
          create: (context) => ProfileViewModel(context),
          child: const Profile(),
        ),
    RouteNames.reader: (context) => const ReaderPage(),
    RouteNames.readerSettings: (context) => const SettingsPage(),
  };
}
