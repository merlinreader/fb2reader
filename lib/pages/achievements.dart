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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: const CustomAppBar(),
        body: _buildBody(),
        bottomNavigationBar: const CustomNavBar(),
      ),
    );
  }
}

Widget _buildBody() {
  return const SafeArea(
    child: Column(children: <Widget>[
      Padding(
        padding: EdgeInsets.all(24),
        //mainAxisAlignment: MainAxisAlignment.center,
        //padding: const EdgeInsets.only(top: 16, bottom: 16, right: 8),
        child: Column(children: <Widget>[
          Row(
            children: [
              Text(
                'Достижения',
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: 24,
                    fontFamily: 'Tektur',
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          AchievementCard(
            name: '1 место за что-то там',
            dataText: 'Июль 2023',
            icon: 'assets/images/merlin.svg',
          ),
          SizedBox(height: 8),
          AchievementCard(
            name: '1 место за что-то там',
            dataText: 'Июль 2023',
            icon: 'assets/images/merlin.svg',
          ),
          SizedBox(height: 8),
          AchievementCard(
            name: '1 место за что-то там',
            dataText: 'Июль 2023',
            icon: 'assets/images/merlin.svg',
          ),
          SizedBox(height: 8),
          AchievementCard(
            name: '1 место за что-то там',
            dataText: 'Июль 2023',
            icon: 'assets/images/merlin.svg',
          ),
        ]),
      ),
    ]),
  );
}
