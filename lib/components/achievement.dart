import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AchievementCard extends StatelessWidget {
  final String name;
  final String dataText;
  final String icon;
  // final double width;
  // final double height;
  // final double horizontalPadding;
  // final double verticalPadding;
  // final Color buttonColor;
  // final Color textColor;
  // final double fontSize;
  // final FontWeight fontWeight;

  const AchievementCard({
    required this.name,
    required this.dataText,
    required this.icon,
    // required this.width,
    // required this.height,
    // required this.horizontalPadding,
    // required this.verticalPadding,
    // required this.buttonColor,
    // required this.textColor,
    // required this.fontSize,
    // required this.fontWeight,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Center(
        child: Container(
      width: mediaQuery.size.width - 48,
      height: 83.0,
      alignment: Alignment.center,
      /* ТЕНЬ И ВСЁ ТАКОЕ
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            blurRadius: 4,
            offset: Offset(4, 8), // Shadow position
          ),
        ],
      ),
      */
      child: Row(children: [
        Container(
          alignment: Alignment.centerLeft,
          padding:
              const EdgeInsets.only(left: 16, top: 16, bottom: 16, right: 8),
          child: SvgPicture.asset(
            icon,
            width: 48,
            height: 48,
          ),
        ),
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Flexible(
              child: Text(
            name,
            style: const TextStyle(
                fontFamily: 'Tektur',
                color: Colors.black,
                fontSize: 11,
                fontWeight: FontWeight.bold),
          )),
          Text(
            dataText,
            style: const TextStyle(
                fontFamily: 'Tektur',
                color: Colors.black,
                fontSize: 11,
                fontWeight: FontWeight.bold),
          )
        ]),
      ]),
    ));
  }
}

/*
@override
  Widget build(BuildContext context) {
    return Center(
      child: Row(children: [
        Container(
          width: 312.0,
          height: 83.0,
          color: Colors.orange,
          alignment: Alignment.center,
          child: Container(
            child: SvgPicture.asset(
              icon,
              width: 48,
              height: 48,
            ),
          ),
          decoration: BoxDecoration(
            color: Colors.teal,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 4,
                offset: Offset(4, 8), // Shadow position
              ),
            ],
          ),
        ),
        Text(
          name,
          textAlign: TextAlign.left,
          style: const TextStyle(
              fontFamily: 'Tektur',
              color: Colors.black,
              fontSize: 11,
              fontWeight: FontWeight.bold),
        )
      ]),
    );
  }
*/