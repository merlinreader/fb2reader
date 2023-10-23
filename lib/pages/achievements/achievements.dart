import 'package:flutter/material.dart';
//import 'package:merlin/components/appbar/appbar.dart';
//import 'package:merlin/components/navbar/navbar.dart';
import 'package:merlin/style/colors.dart';
//import 'package:merlin/style/text.dart';
import 'package:merlin/components/svg/svg_asset.dart';
//import 'package:merlin/components/svg/svg_widget.dart';
import 'package:merlin/components/achievement.dart';

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: MyColors.bgWhite,
        body: _buildBody(),
      ),
    );
  }
}

Widget _buildBody() {
  return SafeArea(
      child: Expanded(
    child: ListView(children: const [
      Column(children: <Widget>[
        Padding(
          padding: EdgeInsets.all(24),
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
                picture: SvgAsset.dragon1,
                isLocked: false),
            SizedBox(height: 8),
            AchievementCard(
                name: '1 место за что-то там',
                dataText: '',
                picture: SvgAsset.dragon2,
                isLocked: true),
            SizedBox(height: 8),
            AchievementCard(
                name: '1 место за что-то там',
                dataText: '',
                picture: SvgAsset.dragon3,
                isLocked: true),
            SizedBox(height: 8),
            AchievementCard(
                name: '3 место за что-то там',
                dataText: 'Март 2022',
                picture: SvgAsset.blood1,
                isLocked: false),
            SizedBox(height: 8),
            AchievementCard(
                name: '3 место за что-то там',
                dataText: 'Март 2022',
                picture: SvgAsset.blood1,
                isLocked: false),
            SizedBox(height: 8),
            AchievementCard(
                name: '3 место за что-то там',
                dataText: 'Март 2022',
                picture: SvgAsset.blood1,
                isLocked: false),
            SizedBox(height: 8),
            AchievementCard(
                name: '3 место за что-то там',
                dataText: 'Март 2022',
                picture: SvgAsset.blood1,
                isLocked: false),
            SizedBox(height: 8),
            AchievementCard(
                name: '3 место за что-то там',
                dataText: 'Март 2022',
                picture: SvgAsset.blood1,
                isLocked: false),
            SizedBox(height: 8),
            AchievementCard(
                name: '3 место за что-то там',
                dataText: 'Март 2022',
                picture: SvgAsset.blood1,
                isLocked: false),
            SizedBox(height: 8),
            AchievementCard(
                name: '3 место за что-то там',
                dataText: 'Март 2022',
                picture: SvgAsset.blood1,
                isLocked: false),
            SizedBox(height: 8),
            AchievementCard(
                name: '3 место за что-то там',
                dataText: 'Март 2022',
                picture: SvgAsset.blood1,
                isLocked: false),
            SizedBox(height: 8),
            AchievementCard(
                name: '3 место за что-то там',
                dataText: 'Март 2022',
                picture: SvgAsset.blood1,
                isLocked: false),
            SizedBox(height: 8),
            AchievementCard(
                name: '3 место за что-то там',
                dataText: 'Март 2022',
                picture: SvgAsset.blood1,
                isLocked: false),
            SizedBox(height: 8),
            AchievementCard(
                name: '3 место за что-то там',
                dataText: 'Март 2022',
                picture: SvgAsset.blood1,
                isLocked: false),
            SizedBox(height: 8),
          ]),
        ),
      ])
    ]),
  ));
}
