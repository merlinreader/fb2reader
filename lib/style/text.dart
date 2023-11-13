import 'package:flutter/material.dart';

class Text24 extends StatelessWidget {
  final String text;
  final Color textColor;
  const Text24({super.key, required this.text, required this.textColor});
  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleLarge
        //TextStyle(
        //fontFamily: 'Tektur',
        //color: textColor,
        //fontSize: 24,
        //fontWeight: FontWeight.bold)
        );
  }
}

class Text14 extends StatelessWidget {
  final String text;
  final Color textColor;
  const Text14({super.key, required this.text, required this.textColor});
  @override
  Widget build(BuildContext context) {
    return Text(
      text, style: Theme.of(context).textTheme.bodySmall,
      textAlign: TextAlign.center,
      //TextStyle(fontFamily: 'Tektur', color: textColor, fontSize: 14)
    );
  }
}

class Text12 extends StatelessWidget {
  final String text;
  final Color textColor;
  const Text12({super.key, required this.text, required this.textColor});
  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleSmall
        //TextStyle(fontFamily: 'Tektur', color: textColor, fontSize: 14)
        );
  }
}

class Text7 extends StatelessWidget {
  final String text;
  final Color textColor;
  const Text7({super.key, required this.text, required this.textColor});
  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.displaySmall
        //TextStyle(fontFamily: 'Tektur', color: textColor, fontSize: 14)
        );
  }
}

class Text18 extends StatelessWidget {
  final String text;
  final Color textColor;
  const Text18({super.key, required this.text, required this.textColor});
  @override
  Widget build(BuildContext context) {
    return Text(
      text, style: Theme.of(context).textTheme.titleMedium,
      //TextStyle(fontFamily: 'Tektur', color: textColor, fontSize: 18)
    );
  }
}

class Text16 extends StatelessWidget {
  final String text;
  final Color textColor;
  const Text16({super.key, required this.text, required this.textColor});
  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.displayMedium
        //TextStyle(fontFamily: 'Tektur', color: textColor, fontSize: 16)
        );
  }
}

class TextForTable extends StatelessWidget {
  final String text;
  final Color textColor;
  const TextForTable({super.key, required this.text, required this.textColor});
  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: Theme.of(context).textTheme.bodyMedium,
        textAlign: TextAlign.start
        //TextStyle(fontFamily: 'Roboto', color: textColor)
        );
  }
}

class Text11 extends StatelessWidget {
  final String text;
  final Color textColor;
  const Text11({super.key, required this.text, required this.textColor});
  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.bodySmall
        //TextStyle(fontFamily: 'Tektur', color: textColor, fontSize: 11)
        );
  }
}

class Text11Bold extends StatelessWidget {
  final String text;
  final Color textColor;
  const Text11Bold({super.key, required this.text, required this.textColor});
  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(
            fontFamily: 'Tektur',
            color: textColor,
            fontSize: 11,
            fontWeight: FontWeight.bold));
  }
}

class Text14Bold extends StatelessWidget {
  final String text;
  final Color textColor;
  const Text14Bold({super.key, required this.text, required this.textColor});
  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.bodySmall
        //TextStyle(
        //fontFamily: 'Tektur',
        //color: textColor,
        //fontSize: 11,
        //fontWeight: FontWeight.bold)
        );
  }
}

// ignore: must_be_immutable
class TextTektur extends StatelessWidget {
  final String text;
  final Color textColor;
  final double fontsize;
  FontWeight? fontWeight;
  TextTektur(
      {super.key,
      required this.text,
      required this.fontsize,
      required this.textColor,
      this.fontWeight});
  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(
            fontFamily: 'Tektur',
            color: textColor,
            fontSize: fontsize,
            fontWeight: fontWeight));
  }
}
