import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:merlin/UI/router.dart';
import 'package:merlin/domain/data_providers/avatar_provider.dart';

class SplashSreenViewModel {
  final BuildContext context;

  SplashSreenViewModel(this.context) {
    _initAsync();
  }

  Future<void> _initAsync() async {
    await AvatarProvider.initAsync();
    Navigator.pushReplacementNamed(context, RouteNames.main);
  }
}
