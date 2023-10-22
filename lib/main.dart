import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:merlin/pages/profile/profile.dart';
import 'package:merlin/functions/location.dart';
import 'package:merlin/style/colors.dart';

import 'package:merlin/pages/settings.dart';
import 'package:merlin/pages/recent/recent.dart';


import 'package:merlin/functions/location.dart';
import 'package:merlin/style/colors.dart';
import 'package:merlin/pages/page.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: MyColors.white,
  ));
  runApp(const Recent());
  getLocation();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: MyColors.white,
  ));
  runApp(const AppPage());
  getLocation();
}
