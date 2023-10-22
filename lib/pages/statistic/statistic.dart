import 'package:flutter/material.dart';
//import 'package:merlin/components/appbar/appbar.dart';
//import 'package:merlin/components/navbar/navbar.dart';
import 'package:merlin/style/colors.dart';
import 'package:merlin/style/text.dart';
import 'package:merlin/components/button/button.dart';
import 'package:merlin/components/table.dart';

class StatisticPage extends StatelessWidget {
  const StatisticPage({super.key});

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
  return const SafeArea(
    child: Column(children: <Widget>[
      Padding(
        padding: EdgeInsets.all(24),
        child: Column(children: <Widget>[
          Row(
            children: [
              TextTektur(
                  text: 'Статистика', fontsize: 24, textColor: MyColors.black),
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
              fontWeight: FontWeight.bold,
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
              fontWeight: FontWeight.bold,
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
              fontWeight: FontWeight.bold,
              onPressed: printFunc,
            ),
          ]),
        ]),
      ),
      Expanded(child: Swipe()),
    ]),
  );
}

class Swipe extends StatefulWidget {
  const Swipe({super.key});

  @override
  SwipeState createState() => SwipeState();
}

class SwipeState extends State<Swipe> with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          TextButton(
              onPressed: () => tabController.animateTo(0),
              child: const Text14(
                text: 'День',
                textColor: MyColors.black,
              )),
          const SizedBox(width: 28),
          TextButton(
              onPressed: () => tabController.animateTo(1),
              child: const Text14(
                text: 'Неделя',
                textColor: MyColors.black,
              )),
          const SizedBox(width: 28),
          TextButton(
              onPressed: () => tabController.animateTo(2),
              child: const Text14(
                text: 'Месяц',
                textColor: MyColors.black,
              )),
          const SizedBox(width: 28),
          TextButton(
              onPressed: () => tabController.animateTo(3),
              child: const Text14(
                text: 'Год',
                textColor: MyColors.black,
              )),
        ]),
        Expanded(
            child: TabBarView(
          controller: tabController,
          children: const [
            StatTable(),
            StatTable(),
            StatTable(),
            StatTable(),
          ],
        ))
      ],
    );
  }
}

void printFunc() {
  print("Stas STAS STAS I CHE LOL STAS?");
}
