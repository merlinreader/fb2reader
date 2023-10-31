// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:merlin/style/colors.dart';
import 'package:merlin/style/text.dart';

class AchievementCard extends StatelessWidget {
  final String name;
  final String dataText;
  final String picture;
  final bool isLocked;

  const AchievementCard({
    required this.name,
    required this.dataText,
    required this.picture,
    required this.isLocked,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Container(
      width: mediaQuery.size.width - 48,
      height: 83.0,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isLocked ? Colors.white.withOpacity(0.2) : Colors.transparent,
      ),
      child: Row(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding:
                const EdgeInsets.only(left: 16, top: 16, bottom: 16, right: 8),
            child: SvgPicture.asset(
              picture,
              width: 48,
              height: 48,
              color: isLocked ? Colors.transparent.withOpacity(0.5) : null,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(child: Text11(text: name, textColor: MyColors.black)
                  //Text(
                  //name,
                  //style: TextStyle(
                  //fontFamily: 'Tektur',
                  //fontSize: 11,
                  //fontWeight: FontWeight.bold,
                  //color:
                  //isLocked ? Colors.black.withOpacity(0.2) : Colors.black,
                  //),
                  //),
                  ),
              Text(
                dataText,
                style: TextStyle(
                  fontFamily: 'Tektur',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isLocked ? Colors.grey.withOpacity(0.2) : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
