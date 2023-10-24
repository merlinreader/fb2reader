import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white, // Установите белый фон
      body: Center(
        child: CircularProgressIndicator(), // Индикатор загрузки в центре
      ),
    );
  }
}
