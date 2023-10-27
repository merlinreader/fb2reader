import 'package:flutter/material.dart';
import 'package:merlin/style/colors.dart';
import 'package:merlin/style/text.dart';
import 'package:merlin/components/table.dart';

class StatisticPage extends StatefulWidget {
  const StatisticPage({Key? key}) : super(key: key);

  @override
  _StatisticPageState createState() => _StatisticPageState();
}

class _StatisticPageState extends State<StatisticPage> {
  int _currentPageIndex = 0; // Индекс текущей страницы

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: <Widget>[
                const Row(
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
                Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: _currentPageIndex == 0
                            ? MyColors.purple
                            : MyColors.white,
                        onPrimary: _currentPageIndex == 0
                            ? MyColors.white
                            : MyColors.black,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero),
                      ),
                      onPressed: () {
                        setState(() {
                          _currentPageIndex = 0;
                        });
                      },
                      child: const Text(
                        'Страна',
                        style: TextStyle(
                            fontFamily: 'Tektur',
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: _currentPageIndex == 1
                            ? MyColors.purple
                            : MyColors.white,
                        onPrimary: _currentPageIndex == 1
                            ? MyColors.white
                            : MyColors.black,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero),
                      ),
                      onPressed: () {
                        setState(() {
                          _currentPageIndex = 1;
                        });
                      },
                      child: const Text(
                        'Регион',
                        style: TextStyle(
                            fontFamily: 'Tektur',
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: _currentPageIndex == 2
                            ? MyColors.purple
                            : MyColors.white,
                        onPrimary: _currentPageIndex == 2
                            ? MyColors.white
                            : MyColors.black,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero),
                      ),
                      onPressed: () {
                        setState(() {
                          _currentPageIndex = 2;
                        });
                      },
                      child: const Text(
                        'Город',
                        style: TextStyle(
                            fontFamily: 'Tektur',
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _currentPageIndex,
              children: [
                Swipe(), // Страница "Страна"
                Region(), // Страница "Регион"
                City(), // Страница "Город"
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Country extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Swipe();
  }
}

class Region extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Swipe();
  }
}

class City extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Swipe();
  }
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
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          const SizedBox(width: 24),
          TextButton(
              onPressed: () => tabController.animateTo(0),
              child: const Text14Bold(
                text: 'День',
                textColor: MyColors.black,
              )),
          const SizedBox(width: 16),
          TextButton(
              onPressed: () => tabController.animateTo(1),
              child: const Text14Bold(
                text: 'Неделя',
                textColor: MyColors.black,
              )),
          const SizedBox(width: 16),
          TextButton(
              onPressed: () => tabController.animateTo(2),
              child: const Text14Bold(
                text: 'Месяц',
                textColor: MyColors.black,
              )),
          const SizedBox(width: 16),
          TextButton(
              onPressed: () => tabController.animateTo(3),
              child: const Text14Bold(
                text: 'Год',
                textColor: MyColors.black,
              )),
        ]),
        Expanded(
            child: TabBarView(
          controller: tabController,
          children: [
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
