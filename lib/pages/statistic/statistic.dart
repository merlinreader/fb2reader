// ignore_for_file: deprecated_member_use
import 'package:merlin/UI/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:merlin/style/colors.dart';
import 'package:merlin/style/text.dart';
import 'package:merlin/components/table.dart';
import 'package:merlin/functions/location.dart';

class StatisticPage extends StatefulWidget {
  const StatisticPage({Key? key}) : super(key: key);

  @override
  _StatisticPageState createState() => _StatisticPageState();
}

class _StatisticPageState extends State<StatisticPage> {
  int _currentPageIndex = 0; // Индекс текущей страницы

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 20, 24, 16),
          child: Column(
            children: <Widget>[
              const Row(
                children: [
                  Text24(
                    text: "Статистика",
                    textColor: MyColors.black,
                    //fontWeight: FontWeight.w600,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  ElevatedButton(
                    style: getButtonStyle(
                      context,
                      isPressed: _currentPageIndex == 0,
                    ),
                    onPressed: () async {
                      // await getPageCountSimpleMode();

                      setState(() {
                        _currentPageIndex = 0;
                      });
                    },
                    child: Text11Bold(
                      text: 'Страна',
                      textColor: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  ElevatedButton(
                    style: getButtonStyle(
                      context,
                      isPressed: _currentPageIndex == 1,
                    ),
                    onPressed: () {
                      setState(() {
                        _currentPageIndex = 1;
                      });
                    },
                    child: Text11Bold(
                      text: 'Регион',
                      textColor: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  ElevatedButton(
                    style: getButtonStyle(
                      context,
                      isPressed: _currentPageIndex == 2,
                    ),
                    onPressed: () {
                      setState(() {
                        _currentPageIndex = 2;
                      });
                    },
                    child: Text11Bold(
                      text: 'Город',
                      textColor: Theme.of(context).colorScheme.onSurface,
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
    );
  }
}

class Country extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getSavedLocation(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            final locationData = snapshot.data!.split(', ');
            if (locationData.length >= 3) {
              final country = locationData[0];
              return Swipe(
                statDay: StatTable(
                  path: 'daily',
                  country: country.isNotEmpty ? country : 'Russia',
                  area: '',
                  city: '',
                ),
                statWeek: StatTable(
                  path: 'weekly',
                  country: country.isNotEmpty ? country : 'Russia',
                  area: '',
                  city: '',
                ),
                statMonth: StatTable(
                  path: 'monthly',
                  country: country.isNotEmpty ? country : 'Russia',
                  area: '',
                  city: '',
                ),
                statSemiAnnual: StatTable(
                  path: 'semi-annual',
                  country: country.isNotEmpty ? country : 'Russia',
                  area: '',
                  city: '',
                ),
                statAnnual: StatTable(
                  path: 'annual',
                  country: country.isNotEmpty ? country : 'Russia',
                  area: '',
                  city: '',
                ),
              );
            }
          }

          return Center(child: TextTektur(text: 'Нет данных о местоположении', fontsize: 16, textColor: MyColors.grey));
        }
        return const CircularProgressIndicator(
          color: MyColors.purple,
        );
      },
    );
  }
}

class Region extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getSavedLocation(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            final locationData = snapshot.data!.split(', ');
            if (locationData.length >= 3) {
              final country = locationData[0];
              final area = locationData[1];
              return Swipe(
                statDay: StatTable(
                  path: 'daily',
                  country: country,
                  area: area,
                  city: '',
                ),
                statWeek: StatTable(
                  path: 'weekly',
                  country: country,
                  area: area,
                  city: '',
                ),
                statMonth: StatTable(
                  path: 'monthly',
                  country: country,
                  area: area,
                  city: '',
                ),
                statSemiAnnual: StatTable(
                  path: 'semi-annual',
                  country: country,
                  area: area,
                  city: '',
                ),
                statAnnual: StatTable(
                  path: 'annual',
                  country: country,
                  area: area,
                  city: '',
                ),
              );
            }
          }

          return Center(child: TextTektur(text: 'Нет данных о местоположении', fontsize: 16, textColor: MyColors.grey));
        }
        return const CircularProgressIndicator(
          color: MyColors.purple,
        );
      },
    );
  }
}

class City extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getSavedLocation(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            final locationData = snapshot.data!.split(', ');
            if (locationData.length >= 3) {
              final country = locationData[0];
              final area = locationData[1];
              final city = locationData[2];
              return Swipe(
                statDay: StatTable(
                  path: 'daily',
                  country: country,
                  area: area,
                  city: city,
                ),
                statWeek: StatTable(
                  path: 'weekly',
                  country: country,
                  area: area,
                  city: city,
                ),
                statMonth: StatTable(
                  path: 'monthly',
                  country: country,
                  area: area,
                  city: city,
                ),
                statSemiAnnual: StatTable(
                  path: 'semi-annual',
                  country: country,
                  area: area,
                  city: city,
                ),
                statAnnual: StatTable(
                  path: 'annual',
                  country: country,
                  area: area,
                  city: city,
                ),
              );
            }
          }

          return Center(child: TextTektur(text: 'Нет данных о местоположении', fontsize: 16, textColor: MyColors.grey));
        }
        return const CircularProgressIndicator(
          color: MyColors.purple,
        );
      },
    );
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
  SwipeState createState() =>
      SwipeState(statDay: statDay, statWeek: statWeek, statMonth: statMonth, statSemiAnnual: statSemiAnnual, statAnnual: statAnnual);
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 2.0,
                color: isActive ? MyColors.purple : Colors.transparent,
              ),
            ),
          ),
          child: tabButton,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildTab(
                Container(
                  //width: 28,
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
                      textColor: currentIndex == 0 ? MyColors.black : MyColors.grey,
                    ),
                  ),
                ),
                currentIndex == 0,
              ),
              buildTab(
                Container(
                  //width: 43,
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
                      textColor: currentIndex == 1 ? MyColors.black : MyColors.grey,
                    ),
                  ),
                ),
                currentIndex == 1,
              ),
              buildTab(
                Container(
                  //width: 37,
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
                      textColor: currentIndex == 2 ? MyColors.black : MyColors.grey,
                    ),
                  ),
                ),
                currentIndex == 2,
              ),
              buildTab(
                Container(
                  //width: 50,
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
                      textColor: currentIndex == 3 ? MyColors.black : MyColors.grey,
                    ),
                  ),
                ),
                currentIndex == 3,
              ),
              buildTab(
                Container(
                  width: 20,
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
                      textColor: currentIndex == 4 ? MyColors.black : MyColors.grey,
                    ),
                  ),
                ),
                currentIndex == 4,
              ),
            ],
          ),
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
