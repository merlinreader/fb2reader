import 'package:flutter/material.dart';

class CustomCheckbox extends StatelessWidget {
  final bool isChecked;
  final Function(bool) onChanged;
  final Color bgColor;
  final Color borderColor;
  final Color checkColor;

  const CustomCheckbox(
      {super.key,
      required this.isChecked,
      required this.onChanged,
      required this.bgColor,
      required this.borderColor,
      required this.checkColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(right: 8.0, left: 0.0, top: 8.0, bottom: 8.0),
      child: InkWell(
        onTap: () {
          onChanged(!isChecked);
        },
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(
              width: 2,
              color: borderColor, // Цвет рамки
            ),
          ),
          child: isChecked
              ? Icon(
                  Icons.check,
                  size: 20,
                  color: checkColor, // Цвет галочки
                )
              : Container(), // Пустой контейнер, если не выбрано
        ),
      ),
    );
  }
}
