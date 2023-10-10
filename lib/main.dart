import 'package:flutter/material.dart';

import 'package:merlin/components/appbar.dart';
import 'package:merlin/components/navbar.dart';
import 'package:merlin/style/colors.dart';
import 'components/button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        appBar: CustomAppBar(),
        bottomNavigationBar: CustomNavBar(),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              CustomButton(
                  text: "Нажми меня",
                  width: 312,
                  height: 48,
                  horizontalPadding: 0,
                  verticalPadding: 0,
                  buttonColor: MyColors.puple,
                  textColor: MyColors.white,
                  fontSize: 14,
                  onPressed: printbutton),
              Text(
                'You have pushed the button this many times:',
              ),
              CustomButton(
                  text: "Страна",
                  width: 76,
                  height: 40,
                  horizontalPadding: 0,
                  verticalPadding: 0,
                  buttonColor: MyColors.puple,
                  textColor: MyColors.white,
                  fontSize: 14,
                  onPressed: printbutton)
            ])));
  }
}

void printbutton() {
  print("123");
}
