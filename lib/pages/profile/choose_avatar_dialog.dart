import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:merlin/UI/theme/theme.dart';
import 'package:merlin/components/achievement.dart';
import 'package:merlin/components/svg/svg_widget.dart';
import 'package:merlin/domain/dto/achievements/get_achievements_response.dart';
import 'package:merlin/main.dart';
import 'package:merlin/pages/profile/profile.dart';
import 'package:merlin/style/colors.dart';
import 'package:merlin/style/text.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ChooseAvatarDialog extends StatefulWidget {
  const ChooseAvatarDialog({Key? key}) : super(key: key);

  @override
  _ChooseAvatarDialogState createState() => _ChooseAvatarDialogState();
}

class _ChooseAvatarDialogState extends State<ChooseAvatarDialog> {
  List<Achievement> achievements = [];
  Achievement? selectedAchievement;
  String? selectAvatar;

  @override
  void initState() {
    getAchievementsFromJson();
    getAvatarFromLocalStorage();

    //getAvatarFile();
    // TODO: взять из стораджа ссылку
    // _downloadImage(selectAvatar);
    super.initState();
  }

  Future<void> getAchievementsFromJson() async {
    achievements = await fetchJson();
    final prefs = await SharedPreferences.getInstance();
    final avatarUrl = prefs.getString('avatarUrl');
    selectedAchievement = achievements
        .where((element) => element.picture == avatarUrl)
        .firstOrNull;
    setState(() {});
  }

  Future<void> getAvatarFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectAvatar = prefs.getString('avatar');
    });
  }

  void saveAvatarToLocalStorage(String selectAvatar) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('avatar', selectAvatar);
  }

  // Future<void> getAvatarFile() async {
  //   // fileAvatar = ???
  //   final documentDirectory = await getApplicationDocumentsDirectory();
  //   fileAvatar = File('${documentDirectory.path}/image.jpg');
  // }

  // Future<void> _downloadImage(String? avatarUrl) async {
  //   if (avatarUrl == null) {
  //     return;
  //   }
  //   var response = await http.get(Uri.parse(avatarUrl));
  //   final documentDirectory = await getApplicationDocumentsDirectory();
  //   final avatar = File('${documentDirectory.path}/image.jpg');
  //   if (avatar.existsSync()) {
  //     print('exists 1');
  //   }
  //   avatar.writeAsBytesSync(response.bodyBytes);
  //   if (avatar.existsSync()) {
  //     print('exists 2');
  //   }
  //   // File avatar = File('${documentDirectory.path}/image.jpg');
  //   // avatar.deleteSync();
  //   // avatar.writeAsBytesSync(response.bodyBytes);
  //   setState(() {
  //     // fileAvatar = avatar;
  //   });
  //   print('успех');
  // }

  Future<List<Achievement>> fetchJson() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    final url =
        Uri.parse('https://fb2.cloud.leam.pro/api/account/achievements');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final ach = GetAchievementsResponse.fromJson(jsonResponse);
      final List<Achievement> achievements = [];
      achievements.add(ach.achievements.baby);
      achievements.add(ach.achievements.spell);
      achievements.addAll(ach.achievements.simpleModeAchievements);
      achievements.addAll(ach.achievements.wordModeAchievements);
      return achievements;
    } else {
      // print('Ошибка запроса достижений: ${response.statusCode}');
      // print('Токен: $token');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Theme(
      data: themeProvider.isDarkTheme ? darkTheme() : lightTheme(),
      child: AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        alignment: Alignment.center,
        titlePadding: const EdgeInsets.only(top: 10, bottom: 10),
        title: Center(
            child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: SizedBox(
                  height: 65,
                  width: 65,
                  child: selectedAchievement != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(48),
                          child: Image(
                            image: NetworkImage(selectedAchievement!.picture),
                            height: 96,
                            width: 96,
                          ))
                      : selectAvatar != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(48),
                              child: Image(
                                image: NetworkImage(selectAvatar!),
                                height: 96,
                                width: 96,
                              ))
                          : const MerlinWidget()
                  //Image.network(selectedAchievement!.picture) : const MerlinWidget(),
                  // : fileAvatar != null
                  //     ? Image.memory(fileAvatar! as Uint8List)
                  //     : const MerlinWidget(),
                  ),
            ),
            const Text24(text: 'Аватар', textColor: MyColors.black),
            const SizedBox(
              height: 10,
            ),
            Container(
              height: 10,
              width: double.infinity,
              color: themeProvider.isDarkTheme
                  ? MyColors.grey
                  : MyColors.lightGray,
            ),
          ],
        )),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Center(
              child: Text16(text: 'Выберите аватар', textColor: MyColors.black),
            ),
            Container(
              padding: const EdgeInsets.only(top: 15),
              height: MediaQuery.of(context).size.height / 3,
              width: MediaQuery.of(context).size.width,
              child: GridView.builder(
                  itemCount: achievements.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedAchievement = achievements[index];
                          String name = achievements[index].description;
                          print(name);
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: const [
                              BoxShadow(
                                  color: MyColors.black,
                                  offset: Offset.zero,
                                  blurRadius: 5,
                                  spreadRadius: 0.1,
                                  blurStyle: BlurStyle.normal)
                            ],
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: achievements[index].picture ==
                                        selectedAchievement?.picture
                                    ? MyColors.purple
                                    : MyColors.white,
                                width: 4,
                                style: BorderStyle.solid),
                            image: DecorationImage(
                                image:
                                    NetworkImage(achievements[index].picture)),
                            // image: NetworkImage(achievements[index].picture)),
                          ),
                        ),
                      ),
                    );
                  }),
            )
          ],
        ),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text16(text: 'Сбросить', textColor: MyColors.black)),
          TextButton(
              onPressed: () async {
                // final prefs = await SharedPreferences.getInstance();
                // if (selectedAchievement != null) {
                //   prefs.setString('avatarUrl', selectedAchievement!.picture);
                // }
                saveAvatarToLocalStorage(selectedAchievement!.picture);
                // saveAvatarToLocalStorage(selectAvatar);
                Navigator.of(context).pop();
              },
              child: const Text16(text: 'Сохранить', textColor: MyColors.black))
        ],
      ),
    );
  }
}
