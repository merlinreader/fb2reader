import 'package:flutter/material.dart';
import 'package:merlin/components/svg/svg_widget.dart';
import 'package:merlin/pages/splash_screen/splash_screen_view_model.dart';
import 'package:merlin/style/colors.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: MyColors.purple,
      body: Center(child: MerlinStart()),
    );
  }

  static Widget create(BuildContext context) {
    return Provider(
      create: (context) => SplashSreenViewModel(context),
      lazy: false,
      child: const SplashScreen(),
    );
  }
}
