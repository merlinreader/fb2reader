import 'package:flutter/material.dart';

class Text24 extends StatelessWidget {
  final String text;
  final Color textColor;
  const Text24({super.key, required this.text, required this.textColor});
  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(
            fontFamily: 'Tektur',
            color: textColor,
            fontSize: 24,
            fontWeight: FontWeight.bold));
  }
}

class Text14 extends StatelessWidget {
  final String text;
  final Color textColor;
  const Text14({super.key, required this.text, required this.textColor});
  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(fontFamily: 'Tektur', color: textColor, fontSize: 14));
  }
}

class Text11 extends StatelessWidget {
  final String text;
  final Color textColor;
  const Text11({super.key, required this.text, required this.textColor});
  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(fontFamily: 'Tektur', color: textColor, fontSize: 11));
  }
}
