import 'dart:async';

import 'package:flutter/material.dart';
import 'package:merlin/UI/router.dart';
import 'package:merlin/components/svg/svg_widget.dart';
import 'package:merlin/style/colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Timer(Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, RouteNames.main);
    });
    return const Scaffold(
      backgroundColor: MyColors.purple,
      body: Center(child: MerlinStart()),
    );
  }
}
