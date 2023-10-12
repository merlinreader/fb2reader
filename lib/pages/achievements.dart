import 'package:flutter/material.dart';
import 'package:merlin/components/appbar.dart';
import 'package:merlin/components/navbar.dart';
import 'package:merlin/style/colors.dart';
import 'package:merlin/style/text.dart';
import 'package:merlin/components/button.dart';
import 'package:merlin/components/achievement.dart';

class AchievementsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(),
        body: AchievementCard(
          name: '1 место за что-то там',
          dataText: 'Июль 2023',
          icon: 'assets/images/merlin.svg',
        ),
        bottomNavigationBar: CustomNavBar(),
      ),
    );
  }
}
/*
Widget _buildBody() {
  return const SafeArea(
    child: Column(children: <Widget>[
      Padding(
        padding: EdgeInsets.all(24),
        child: Column(children: <Widget>[
          Row(
            children: [
              Text(
                'Статистика',
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: 24,
                    fontFamily: 'Tektur',
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 10),
          SizedBox(height: 10),
          Row(children: [
            Button(
              text: 'Страна',
              width: 76,
              height: 40,
              horizontalPadding: 12,
              verticalPadding: 8,
              buttonColor: MyColors.white,
              textColor: MyColors.black,
              fontSize: 14,
              fontWeight: FontWeight.normal,
              onPressed: printFunc,
            ),
            Button(
              text: 'Регион',
              width: 76,
              height: 40,
              horizontalPadding: 12,
              verticalPadding: 8,
              buttonColor: MyColors.white,
              textColor: MyColors.black,
              fontSize: 14,
              fontWeight: FontWeight.normal,
              onPressed: printFunc,
            ),
            Button(
              text: 'Город',
              width: 76,
              height: 40,
              horizontalPadding: 12,
              verticalPadding: 8,
              buttonColor: MyColors.white,
              textColor: MyColors.black,
              fontSize: 14,
              fontWeight: FontWeight.normal,
              onPressed: printFunc,
            ),
          ]),
        ]),
      ),
    ]),
  );
}
*/
