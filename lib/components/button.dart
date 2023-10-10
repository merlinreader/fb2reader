import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final double width;
  final double height;
  final double horizontalPadding;
  final double verticalPadding;
  final Color buttonColor;
  final Color textColor;
  final double fontSize;
  final VoidCallback onPressed;

  const CustomButton({
    required this.text,
    required this.width,
    required this.height,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.buttonColor,
    required this.textColor,
    required this.fontSize,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
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
            )),
      ),
    );
  }
}
