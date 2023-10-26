// ignore_for_file: deprecated_member_use

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
            padding: const EdgeInsets.all(24),
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
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
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
                          borderRadius: BorderRadius.zero,
                        ),
                        minimumSize: const Size(76, 40),
                        elevation: 0,
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
                          fontWeight: FontWeight.bold,
                        ),
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
                          borderRadius: BorderRadius.zero,
                        ),
                        minimumSize: const Size(76, 40),
                        elevation: 0,
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
                          fontWeight: FontWeight.bold,
                        ),
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
                          borderRadius: BorderRadius.zero,
                        ),
                        minimumSize: const Size(76, 40),
                        elevation: 0,
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
                          fontWeight: FontWeight.bold,
                        ),
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
                Country(), // Страница "Страна"
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
    return const Swipe(
        statDay: StatTable(
          path: 'daily',
          country: 'Russia',
          area: '',
          city: '',
        ),
        statWeek: StatTable(
          path: 'weekly',
          country: 'Russia',
          area: '',
          city: '',
        ),
        statMonth: StatTable(
          path: 'monthly',
          country: 'Russia',
          area: '',
          city: '',
        ),
        statSemiAnnual: StatTable(
          path: 'semi-annual',
          country: 'Russia',
          area: '',
          city: '',
        ),
        statAnnual: StatTable(
          path: 'annual',
          country: 'Russia',
          area: '',
          city: '',
        ));
  }
}

class Region extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Swipe(
        statDay: StatTable(
          path: 'daily',
          country: '',
          area: '',
          city: '',
        ),
        statWeek: StatTable(
          path: 'weekly',
          country: '',
          area: '',
          city: '',
        ),
        statMonth: StatTable(
          path: 'monthly',
          country: '',
          area: '',
          city: '',
        ),
        statSemiAnnual: StatTable(
          path: 'semi-annual',
          country: '',
          area: '',
          city: '',
        ),
        statAnnual: StatTable(
          path: 'annual',
          country: '',
          area: '',
          city: '',
        ));
  }
}

class City extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Swipe(
        statDay: StatTable(
          path: 'daily',
          country: '',
          area: '',
          city: 'YURGA',
        ),
        statWeek: StatTable(
          path: 'weekly',
          country: '',
          area: '',
          city: 'YURGA',
        ),
        statMonth: StatTable(
          path: 'monthly',
          country: '',
          area: '',
          city: 'YURGA',
        ),
        statSemiAnnual: StatTable(
          path: 'semi-annual',
          country: '',
          area: '',
          city: 'YURGA',
        ),
        statAnnual: StatTable(
          path: 'annual',
          country: '',
          area: '',
          city: 'YURGA',
        ));
  }
}

class Swipe extends StatefulWidget {
  final StatTable statDay;
  final StatTable statWeek;
  final StatTable statMonth;
  final StatTable statSemiAnnual;
  final StatTable statAnnual;

  const Swipe({
    super.key,
    required this.statDay,
    required this.statWeek,
    required this.statMonth,
    required this.statSemiAnnual,
    required this.statAnnual,
  });

  @override
  // ignore: no_logic_in_create_state
  SwipeState createState() => SwipeState(
      statDay: statDay,
      statWeek: statWeek,
      statMonth: statMonth,
      statSemiAnnual: statSemiAnnual,
      statAnnual: statAnnual);
}

class SwipeState extends State<Swipe> with SingleTickerProviderStateMixin {
  final StatTable statDay;
  final StatTable statWeek;
  final StatTable statMonth;
  final StatTable statSemiAnnual;
  final StatTable statAnnual;

  SwipeState({
    required this.statDay,
    required this.statWeek,
    required this.statMonth,
    required this.statSemiAnnual,
    required this.statAnnual,
    Key? key,
  }) : super();

  late TabController tabController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 5, vsync: this);
    tabController.addListener(updateIndex);
  }

  @override
  void dispose() {
    tabController.removeListener(updateIndex);
    tabController.dispose();
    super.dispose();
  }

  void updateIndex() {
    setState(() {
      currentIndex = tabController.index;
    });
  }

  Widget buildTab(Container tabButton, bool isActive) {
    final mediaQuery = MediaQuery.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        tabButton,
        isActive
            ? Container(
                height: 2,
                color: MyColors.purple,
                width: currentIndex == 0
                    ? 30
                    : currentIndex == 1
                        ? 43
                        : currentIndex == 2
                            ? 37
                            : currentIndex == 3
                                ? 48
                                : currentIndex == 4
                                    ? 20
                                    : 0,
              )
            : Container(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: 20),
            Expanded(
              child: buildTab(
                Container(
                  width: 30, // Установите нужную ширину
                  height: 24,
                  child: InkWell(
                    onTap: () {
                      tabController.animateTo(0);
                      setState(() {
                        currentIndex = 0;
                      });
                    },
                    child: Text14Bold(
                      text: 'День',
                      textColor:
                          currentIndex == 0 ? MyColors.black : MyColors.grey,
                    ),
                  ),
                ),
                currentIndex == 0,
              ),
            ),
            Expanded(
              child: buildTab(
                Container(
                  width: 43, // Установите нужную ширину
                  height: 24,
                  child: InkWell(
                    onTap: () {
                      tabController.animateTo(1);
                      setState(() {
                        currentIndex = 1;
                      });
                    },
                    child: Text14Bold(
                      text: 'Неделя',
                      textColor:
                          currentIndex == 1 ? MyColors.black : MyColors.grey,
                    ),
                  ),
                ),
                currentIndex == 1,
              ),
            ),
            Expanded(
              child: buildTab(
                Container(
                  width: 37, // Установите нужную ширину
                  height: 24,
                  child: InkWell(
                    onTap: () {
                      tabController.animateTo(2);
                      setState(() {
                        currentIndex = 2;
                      });
                    },
                    child: Text14Bold(
                      text: 'Месяц',
                      textColor:
                          currentIndex == 2 ? MyColors.black : MyColors.grey,
                    ),
                  ),
                ),
                currentIndex == 2,
              ),
            ),
            Expanded(
              child: buildTab(
                Container(
                  width: 48, // Установите нужную ширину
                  height: 24,
                  child: InkWell(
                    onTap: () {
                      tabController.animateTo(3);
                      setState(() {
                        currentIndex = 3;
                      });
                    },
                    child: Text14Bold(
                      text: 'Полгода',
                      textColor:
                          currentIndex == 3 ? MyColors.black : MyColors.grey,
                    ),
                  ),
                ),
                currentIndex == 3,
              ),
            ),
            Expanded(
              child: buildTab(
                Container(
                  width: 20, // Установите нужную ширину
                  height: 24,
                  child: InkWell(
                    onTap: () {
                      tabController.animateTo(4);
                      setState(() {
                        currentIndex = 4;
                      });
                    },
                    child: Text14Bold(
                      text: 'Год',
                      textColor:
                          currentIndex == 4 ? MyColors.black : MyColors.grey,
                    ),
                  ),
                ),
                currentIndex == 4,
              ),
            ),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              statDay,
              statWeek,
              statMonth,
              statSemiAnnual,
              statAnnual,
            ],
          ),
        ),
      ],
    );
  }
}
