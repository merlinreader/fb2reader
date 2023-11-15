import 'package:flutter/material.dart';
import 'package:merlin/components/achievement.dart';
import 'package:merlin/components/achievement_card.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:merlin/domain/dto/achievements/get_achievements_response.dart';
import 'package:merlin/style/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:merlin/style/text.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  final List<Achievement> _achievements = [];
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
      headers: {
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2NTRlMGNkNjNmYjZmNWJlOGQzMzNlMTIiLCJ0ZWxlZ3JhbUlkIjoiNTEzNTMxIiwiaWF0IjoxNzAwMDM4NjU1fQ.dCKX6jX5CpVshWcir87sfqqJbmrhYmBJbvNZNdt4XAA'
      },
    );
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
      print('Ошибка запроса достижений: ${response.statusCode}');
      print('Токен: $token');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              : ListView(
                  children: [
                    ..._achievements
                        .map((e) => AchievementCard(achievement: e))
                        .toList()
                  ],
                ),
        )
      ],
    );
  }
}
