import 'package:flutter/material.dart';
import 'package:merlin/components/appbar.dart';
import 'package:merlin/components/navbar.dart';

class StatPage extends StatelessWidget {
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
  return const SingleChildScrollView(
    child: Column(children: <Widget>[
      SafeArea(
          child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(children: <Widget>[
          Divider(
            height: 10,
          ),
          Text(
            'Статистика',
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 24, fontFamily: 'Tektur'),
          ),
          Divider(
            height: 10,
          ),
          Divider(
            height: 50,
          ),
          SingleChoice(),
        ]),
      )),
    ]),
  );
}

enum Calendar { day, week, month, year }

class SingleChoice extends StatefulWidget {
  const SingleChoice({super.key});

  @override
  State<SingleChoice> createState() => _SingleChoiceState();
}

class _SingleChoiceState extends State<SingleChoice> {
  Calendar calendarView = Calendar.day;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<Calendar>(
      segments: const <ButtonSegment<Calendar>>[
        ButtonSegment<Calendar>(
          value: Calendar.day,
          label: Text('День'),
        ),
        ButtonSegment<Calendar>(
          value: Calendar.week,
          label: Text('Неделя'),
        ),
        ButtonSegment<Calendar>(
          value: Calendar.month,
          label: Text('Месяц'),
        ),
        ButtonSegment<Calendar>(
          value: Calendar.year,
          label: Text('Год'),
        ),
      ],
      selected: <Calendar>{calendarView},
      onSelectionChanged: (Set<Calendar> newSelection) {
        setState(() {
          calendarView = newSelection.first;
        });
      },
    );
  }
}
