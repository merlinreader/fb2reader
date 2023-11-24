import 'package:flutter/material.dart';
import 'package:merlin/components/achievement.dart';
import 'package:merlin/components/achievement_card.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:merlin/domain/dto/achievements/get_achievements_response.dart';
import 'package:merlin/style/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:merlin/style/text.dart';

// пока не забыл
// Создаем список с name полученных ачивок
// Пихаем это в попап в профиле на карандшик
// Выводим из нашего кода только те, что в списке
// Чтобы список обновился, надо заходить в Достижения. Но это каждый человек будет делать, чтобы убедиться, чо ачивка есть.

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  final List<Achievement> _achievements = [];
  int? errorCode;
  bool _isLoading = true;

  @override
  void initState() {
    fetchJson();
    super.initState();
  }

  Future<void> fetchJson() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    final url =
        Uri.parse('https://fb2.cloud.leam.pro/api/account/achievements');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    setState(() {
      errorCode = response.statusCode;
    });
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final ach = GetAchievementsResponse.fromJson(jsonResponse);
      setState(() {
        _achievements.add(ach.achievements.baby);
        _achievements.add(ach.achievements.spell);
        _achievements.addAll(ach.achievements.simpleModeAchievements);
        _achievements.addAll(ach.achievements.wordModeAchievements);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print(_achievements);
    return Stack(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(18, 20, 24, 16),
          child: Text24(
            text: "Достижения",
            textColor: MyColors.black,
            //fontWeight: FontWeight.w600,
          ),
        ),
        Padding(
            padding: const EdgeInsets.only(top: 72),
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: MyColors.purple),
                  )
                : errorCode != 200
                    ? Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextTektur(
                                text: "Авторизуйтесь, чтобы открыть достижения",
                                fontsize: 16,
                                textColor: MyColors.grey)
                          ],
                        ),
                      )
                    : ListView(
                        children: [
                          ..._achievements
                              .map((e) => AchievementCard(achievement: e))
                              .toList()
                        ],
                      ))
      ],
    );
  }
}
