import 'package:flutter/material.dart';

import 'package:merlin/style/colors.dart';

class Text24 extends StatelessWidget {
  final String text;
  const Text24({super.key, required this.text});
  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            fontFamily: 'Tektur', color: MyColors.black, fontSize: 24));
  }
}

class Text14 extends StatelessWidget {
  final String text;
  const Text14({super.key, required this.text});
  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            fontFamily: 'Tektur', color: MyColors.black, fontSize: 14));
  }
}
