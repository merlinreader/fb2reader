import 'package:flutter/material.dart';
import 'package:merlin/style/colors.dart';

class Button extends StatelessWidget {
  final String text;
  final double width;
  final double height;
  final double horizontalPadding;
  final double verticalPadding;
  final Color? buttonColor;
  final Color textColor;
  final double fontSize;
  final VoidCallback onPressed;
  final FontWeight fontWeight;

  const Button({
    required this.text,
    required this.width,
    required this.height,
    required this.horizontalPadding,
    required this.verticalPadding,
    this.buttonColor,
    required this.textColor,
    required this.fontSize,
    required this.onPressed,
    required this.fontWeight,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        //ПРИМЕР ИСПОЛЬЗОВАНИЯ ТЕМ !!!!!!!!!!!!
        style: Theme.of(context).elevatedButtonTheme.style ??
            ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
              backgroundColor: buttonColor,
              padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding, vertical: verticalPadding),
            ),
        child: Text(text,
            style: TextStyle(
                color: textColor,
                fontFamily: 'Tektur',
                fontSize: fontSize,
                fontWeight: fontWeight)),
      ),
    );
  }
}
