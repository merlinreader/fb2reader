import 'package:flutter/material.dart';
import 'package:merlin/components/svg/svg_asset.dart';
import 'package:merlin/components/achievement.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AchievementsPage extends StatelessWidget {
  final String token;
  const AchievementsPage({
    required this.token,
    Key? key,
  }) : super(key: key);

  Future<List<dynamic>> fetchJson() async {
    final url =
        Uri.parse('https://fb2.cloud.leam.pro/api/account/achievements');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      // Обработка полученного JSON-объекта здесь
      return jsonResponse ?? [];
    } else {
      print('Ошибка запроса достижений: ${response.statusCode}');
      return []; // Возвращаем пустой список в случае ошибки
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Expanded(
      child: ListView(children: [
        Column(children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: <Widget>[
              const Row(
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
              FutureBuilder<List<dynamic>>(
                future: fetchJson(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final dataList = snapshot.data!;
                    return Column(
                      children: List.generate(
                        dataList.length,
                        (index) => AchievementCard(
                            name: dataList[index]['message'],
                            dataText: dataList[index]['date'],
                            picture: SvgAsset.dragon1,
                            isReceived: dataList[index]['isReceived']),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return const Row(
                      children: [
                        SizedBox(width: 20),
                        Text(
                            'Наш сервер сейчас отдыхает, извините за неудобства'),
                      ],
                    );
                    // return Text('Ошибка: ${snapshot.error}');
                  } else {
                    return const Center(
                        child: Column(children: [
                      SizedBox(height: 20),
                      SizedBox(
                        width: 30, // Задайте желаемую ширину
                        height: 30, // Задайте желаемую высоту
                        child: CircularProgressIndicator(),
                      ),
                    ]));
                  }
                },
              ),
            ]),
          ),
        ])
      ]),
    ));
  }
}
