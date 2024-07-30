// ignore_for_file: deprecated_member_use, sized_box_for_whitespace
import 'dart:math';

import 'package:merlin/UI/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:merlin/style/colors.dart';
import 'package:merlin/style/text.dart';
import 'package:merlin/components/table.dart';
import 'package:merlin/functions/location.dart';

class StatisticPage extends StatefulWidget {
  const StatisticPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _StatisticPageState createState() => _StatisticPageState();
}

class _StatisticPageState extends State<StatisticPage> with TickerProviderStateMixin {
  int _currentPageIndex = 0; // Индекс текущей страницы
  int currentIndex = 0;
  late TabController tabController;

  void updateIndex() {
    setState(() {
      currentIndex = tabController.index;
    });
  }

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
                      isPressed: _currentPageIndex == 2,
                    ),
                    onPressed: () async {
                      // await getPageCountSimpleMode();

                      setState(() {
                        _currentPageIndex = 2;
                      });
                    },
                    child: Text11Bold(
                      text: 'Город',
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
                      isPressed: _currentPageIndex == 0,
                    ),
                    onPressed: () {
                      setState(() {
                        _currentPageIndex = 0;
                      });
                    },
                    child: Text11Bold(
                      text: 'Страна',
                      textColor: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<String>(
            future: getSavedLocation(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  final locationData = snapshot.data!.split(', ');
                  if (locationData.length > _currentPageIndex) {
                    final country = locationData.elementAtOrNull(0) ?? '';
                    final area = _currentPageIndex >= 1 ? locationData.elementAtOrNull(1) : '';
                    final city = _currentPageIndex >= 2 ? locationData.elementAtOrNull(2) : '';
                    return Swipe(
                      updateIndex: (int val) {
                        currentIndex = val;
                        tabController.animateTo(val);
                      },
                      currentIndex: currentIndex,
                      child: Expanded(
                        child: TabBarView(
                          controller: tabController,
                          children: [
                            StatTable(
                              path: 'daily',
                              country: country,
                              area: area,
                              city: city,
                            ),
                            StatTable(
                              path: 'weekly',
                              country: country,
                              area: area,
                              city: city,
                            ),
                            StatTable(
                              path: 'monthly',
                              country: country,
                              area: area,
                              city: city,
                            ),
                            StatTable(
                              path: 'semi-annual',
                              country: country,
                              area: area,
                              city: city,
                            ),
                            StatTable(
                              path: 'annual',
                              country: country,
                              area: area,
                              city: city,
                            ),
                          ],
                        ),
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
          )
        ),
      ],
    );
  }
}

class Swipe extends StatelessWidget {
  final int currentIndex;
  final void Function(int val) updateIndex;
  Widget child;

  Swipe({super.key,
    required this.updateIndex,
    required this.currentIndex,
    required this.child
  });

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
                      updateIndex(0);
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
                      updateIndex(1);
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
                      updateIndex(2);
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
                      updateIndex(3);
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
                  //width: 20,
                  height: 24,
                  child: InkWell(
                    onTap: () {
                      updateIndex(4);
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
        child
      ],
    );
  }
}
