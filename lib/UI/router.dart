import 'package:flutter/material.dart';

import 'package:merlin/pages/page.dart';
import 'package:merlin/pages/profile/profile.dart';
import 'package:merlin/pages/reader/reader.dart';
import 'package:merlin/pages/settings/settings.dart';
import 'package:merlin/pages/auth/auth.dart';
import 'package:path/path.dart';

abstract class RouteNames {
  static const String main = '/main';
  static const String profile = '/main/profile';
  static const String reader = '/main/reader';
  static const String readerSettings = '/main/reader/settings';
  static const String auth = '/main/auth';
}

class AppRouter {
  final routes = <String, Widget Function(BuildContext)>{
    RouteNames.main: (context) => const AppPage(),
    RouteNames.profile: (context) => const Profile(),
    RouteNames.reader: (context) => const ReaderPage(),
    RouteNames.readerSettings: (context) => const SettingsPage(),
    RouteNames.auth: (context) => const Auth()
  };
}
