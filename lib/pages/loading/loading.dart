import 'package:flutter/material.dart';
import 'package:merlin/style/colors.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: MyColors.purple,
      ), // Индикатор загрузки в центре
    );
  }
}
