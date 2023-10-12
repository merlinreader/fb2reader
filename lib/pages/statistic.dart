import 'package:flutter/material.dart';
import 'package:merlin/components/appbar.dart';
import 'package:merlin/components/navbar.dart';
import 'package:merlin/style/colors.dart';
import 'package:merlin/style/text.dart';
import 'package:merlin/components/button.dart';

class StatisticPage extends StatelessWidget {
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
      Expanded(child: Swipe()),
    ]),
  );
}

enum Calendar { day, week, month, year }

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
            Center(
                child: Text14(
              text: 'Вот',
              textColor: MyColors.black,
            )),
            Center(
                child: Text14(
              text: 'Листающиеся',
              textColor: MyColors.black,
            )),
            Center(
                child: Text14(
              text: 'Страницы',
              textColor: MyColors.black,
            )),
            Center(
                child: Text14(
              text: ':)',
              textColor: MyColors.black,
            )),
          ],
        ))
      ],
    );
  }
}

void printFunc() {
  print("Stas STAS STAS I CHE LOL STAS?");
}
