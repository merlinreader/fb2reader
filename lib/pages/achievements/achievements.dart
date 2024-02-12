import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:merlin/components/achievement.dart';
import 'package:merlin/components/achievement_card.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:merlin/domain/dto/achievements/get_achievements_response.dart';
import 'package:merlin/style/colors.dart';
import 'package:merlin/style/text.dart';

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
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();
    String? tokenSecure = await secureStorage.read(key: 'token');
    String token = '';
    if (tokenSecure != null) {
      token = tokenSecure;
    }

    final url = Uri.parse('https://merlin.su/account/achievements');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    errorCode = response.statusCode;
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
      _isLoading = false;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // print(_achievements);
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
            padding: errorCode != 200 ? const EdgeInsets.only(top: 0) : const EdgeInsets.only(top: 72),
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: MyColors.purple),
                  )
                : errorCode != 200
                    ? Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [TextTektur(text: "Авторизуйтесь, чтобы открыть достижения", fontsize: 16, textColor: MyColors.grey)],
                        ),
                      )
                    : ListView.separated(
                        itemCount: _achievements.length,
                        itemBuilder: ((context, index) => AchievementCard(achievement: _achievements[index])),
                        separatorBuilder: (context, index) => const SizedBox(
                          height: 8,
                        ),
                      ))
      ],
    );
  }
}
