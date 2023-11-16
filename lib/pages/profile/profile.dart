import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:merlin/UI/icon/custom_icon.dart';
import 'package:merlin/UI/theme/theme.dart';
import 'package:merlin/components/achievement.dart';
import 'package:merlin/components/svg/svg_widget.dart';
import 'package:merlin/domain/dto/achievements/get_achievements_response.dart';
import 'package:merlin/style/colors.dart';
import 'package:merlin/style/text.dart';
import 'package:merlin/components/button/button.dart';
import 'package:merlin/functions/sendmail.dart';
import 'package:merlin/functions/location.dart';
import 'package:merlin/main.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:uni_links/uni_links.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AchievementStatus {
  Achievement achievement;
  bool isUnlocked;

  AchievementStatus(this.achievement, this.isUnlocked);
}

class Profile extends StatelessWidget {
  const Profile({super.key});
  @override
  Widget build(BuildContext context) {
    return const ProfilePage();
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {
  late String country;
  late String adminArea;
  late String locality;

  String token = '';
  late String getToken;
  late String qwerty;
  String firstName = 'Merlin';
  List<AchievementStatus> getAchievements = [];
  late var achievements;

  // ignore: unused_field
  String? _link = 'unknown';
  @override
  void initState() {
    super.initState();
    initUniLinks();
    getTokenFromLocalStorage();
    getAchievementsFromJson();
  }

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
      final jsonResponse = json.decode(response.body);
      final ach = GetAchievementsResponse.fromJson(jsonResponse);
      final List<Achievement> achievements = [];
      achievements.add(ach.achievements.baby);
      achievements.add(ach.achievements.spell);
      achievements.addAll(ach.achievements.simpleModeAchievements);
      achievements.addAll(ach.achievements.wordModeAchievements);
      print('pizda ${achievements.length}');
      return achievements;
    } else {
      // print('Ошибка запроса достижений: ${response.statusCode}');
      // print('Токен: $token');
      return [];
    }
  }

  Future<void> getAchievementsFromJson() async {
    print('start');
    achievements = await fetchJson();
    for (var entry in achievements) {
      getAchievements.add(AchievementStatus(entry, false));
    }
    print('done');
    print(getAchievements.length);
  }

  Future<void> getTokenFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      getToken = prefs.getString('token') ?? '';
      token = getToken;
    });
  }

  Future<void> initUniLinks() async {
    // Подписываемся на поток приходящих ссылок
    linkStream.listen((String? link) {
      // Если ссылка есть, обновляем состояние приложения
      if (!mounted) return;
      setState(() {
        _link = link;
      });
    }, onError: (err) {
      // Обработка ошибок
      if (!mounted) return;
      setState(() {
        _link = 'Failed to get latest link: $err';
      });
    });

    // Получение начальной ссылки
    try {
      String? initialLink = await getInitialLink();
      if (initialLink != null) {
        setState(() {
          Uri uri = Uri.parse(initialLink);
          token = uri.queryParameters['token']!;
          saveTokenToLocalStorage(token);
        });
      }
    } catch (err) {
      setState(() {
        _link = 'Failed to get initial link: $err';
      });
    }
  }

  void saveTokenToLocalStorage(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> getFirstName() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    const url = 'https://fb2.cloud.leam.pro/api/account/';
    final fetchedName;
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = json.decode(response.body);
    print(data['firstName']);

    if (response.statusCode == 200) {
      if (data['firstName'].isNotEmpty) {
        fetchedName = data['firstName'];
        firstName = fetchedName.toString();

        print(fetchedName.toString());
        setState(() {
          firstName = fetchedName.toString();
        });
      }
    }
    await prefs.setString('firstName', firstName);
  }

  Future<void> getFirstNameFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      firstName = prefs.getString('firstName') ?? 'Merlin';
    });
  }

  @override
  Widget build(BuildContext context) {
    getFirstNameFromLocalStorage();
    double size = 20;
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Container(
            padding: const EdgeInsets.only(left: 24, top: 24),
            child: const Row(
              children: [
                Text24(
                  text: 'Мой профиль',
                  textColor: MyColors.black,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
              child: Column(children: [
            Stack(
              children: <Widget>[
                const MerlinWidget(),
                Positioned(
                  bottom: -15,
                  left: 250,
                  child: IconButton(
                      onPressed: chooseAvatar,
                      icon: Icon(
                        CustomIcons.pen,
                        size: size,
                      )),
                )
              ],
            ),
            const SizedBox(height: 12),
            Text24(
              text: firstName,
              textColor: MyColors.black,
            ),
            FutureBuilder(
              future: getSavedLocation(),
              builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                if (!snapshot.hasData) {
                  return const Text('Мы тебя не видим, включи геолокацию');
                } else {
                  final locationData =
                      snapshot.data ?? 'Нет данных о местоположении';
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: size),
                      Text14(text: locationData, textColor: MyColors.black),
                      IconButton(
                          onPressed: geo,
                          icon: Icon(
                            CustomIcons.pen,
                            size: size,
                          )),
                    ],
                  );
                }
              },
            )
          ])),
          const SizedBox(height: 81),
          token == ''
              ? Expanded(
                  child: Column(
                    children: [
                      Theme(
                        data: purpleButton(),
                        child: Button(
                          text: 'Авторизоваться',
                          width: 312,
                          height: 48,
                          horizontalPadding: 97,
                          verticalPadding: 12,
                          textColor: MyColors.white,
                          fontSize: 14,
                          onPressed: () {
                            final tgUrl = Uri.parse(
                                'https://t.me/merlin_auth_bot?start=1');
                            launchUrl(tgUrl,
                                mode: LaunchMode.externalApplication);
                          },
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Expanded(
                        child: Align(
                            alignment: AlignmentDirectional.bottomCenter,
                            child: Theme(
                              data: themeProvider.isDarkTheme
                                  ? darkTheme()
                                  : lightTheme(),
                              child: Button(
                                  text: 'Написать нам',
                                  width: 312,
                                  height: 48,
                                  horizontalPadding: 97,
                                  verticalPadding: 12,
                                  textColor:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  onPressed: () {
                                    mail();
                                  }),
                            )),
                      ),
                      const SizedBox(height: 24)
                    ],
                  ),
                )
              : Expanded(
                  child: Column(
                    children: [
                      Theme(
                        data: purpleButton(),
                        child: Button(
                          text: 'Купить слова',
                          width: 312,
                          height: 48,
                          horizontalPadding: 97,
                          verticalPadding: 12,
                          textColor: MyColors.white,
                          fontSize: 14,
                          onPressed: () {},
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Theme(
                        data: purpleButton(),
                        child: Button(
                          text: 'Убрать рекламу',
                          width: 312,
                          height: 48,
                          horizontalPadding: 97,
                          verticalPadding: 12,
                          textColor: MyColors.white,
                          fontSize: 14,
                          onPressed: () {},
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Expanded(
                        child: Align(
                            alignment: AlignmentDirectional.bottomCenter,
                            child: Theme(
                              data: themeProvider.isDarkTheme
                                  ? darkTheme()
                                  : lightTheme(),
                              child: Button(
                                  text: 'Написать нам',
                                  width: 312,
                                  height: 48,
                                  horizontalPadding: 97,
                                  verticalPadding: 12,
                                  textColor:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  onPressed: () {
                                    mail();
                                  }),
                            )),
                      ),
                      const SizedBox(height: 24)
                    ],
                  ),
                ),
        ]),
      ),
    );
  }

  void mail() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Center(
                  child: Text18(
                      text: 'readermerlin@gmail.com',
                      textColor: MyColors.black)),
              alignment: Alignment.center,
              actions: [
                Center(
                  child: Column(
                    children: [
                      Theme(
                          data: purpleButton(),
                          child: const Button(
                              text: "Написать",
                              width: 250,
                              height: 50,
                              horizontalPadding: 10,
                              verticalPadding: 10,
                              textColor: MyColors.white,
                              fontSize: 14,
                              onPressed: sendEmail,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      Theme(
                          data: themeProvider.isDarkTheme
                              ? darkTheme()
                              : lightTheme(),
                          child: Button(
                              text: "Отмена",
                              width: 250,
                              height: 50,
                              horizontalPadding: 10,
                              verticalPadding: 10,
                              textColor:
                                  Theme.of(context).colorScheme.onSurface,
                              fontSize: 14,
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              fontWeight: FontWeight.bold))
                    ],
                  ),
                )
              ],
            ));
  }

  void geo() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => Theme(
        data: themeProvider.isDarkTheme ? darkTheme() : lightTheme(),
        child: AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: const Center(
            child: Text20(text: 'Геолокация', textColor: MyColors.black),
          ),
          alignment: Alignment.center,
          actions: [
            CSCPicker(
              layout: Layout.vertical,
              onCountryChanged: (country) {},
              onStateChanged: (state) {},
              onCityChanged: (city) {},
            ),
          ],
        ),
      ),
    );
  }

  void chooseAvatar() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    print(getAchievements.length);
    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (context) => Theme(
        data: themeProvider.isDarkTheme ? darkTheme() : lightTheme(),
        child: AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          alignment: Alignment.center,
          titlePadding: const EdgeInsets.only(top: 10, bottom: 10),
          title: Center(
              child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: SizedBox(
                  height: 65,
                  width: 65,
                  child: MerlinWidget(),
                ),
              ),
              const Text24(text: 'Аватар', textColor: MyColors.black),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 10,
                width: double.infinity,
                color: MyColors.bgWhite,
              ),
            ],
          )),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Center(
                child:
                    Text16(text: 'Выберите аватар', textColor: MyColors.black),
              ),
              Container(
                padding: const EdgeInsets.only(top: 15),
                height: MediaQuery.of(context).size.height / 3,
                width: MediaQuery.of(context).size.width,
                child: GridView.builder(
                    itemCount: achievements.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          print('asdsa');
                          for (var entry in getAchievements) {
                            entry.isUnlocked = false;
                          }
                          getAchievements[index].isUnlocked = true;
                          setState(() {
                            getAchievements[index].isUnlocked = true;
                            //TODO: убрать этот костыль когда-нибудь на 100500 итерации
                            Navigator.of(context).pop();
                            chooseAvatar();
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
                                  color: getAchievements[index].isUnlocked
                                      ? MyColors.purple
                                      : MyColors.white,
                                  width: 4,
                                  style: BorderStyle.solid),
                              image: DecorationImage(
                                  image: NetworkImage(getAchievements[index]
                                      .achievement
                                      .picture)),
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
                  for (var entry in getAchievements) {
                    entry.isUnlocked = false;
                  }
                  setState(() {
                    Navigator.of(context).pop();
                    chooseAvatar();
                  });
                },
                child:
                    const Text16(text: 'Сбросить', textColor: MyColors.black)),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child:
                    const Text16(text: 'Сохранить', textColor: MyColors.black))
          ],
        ),
      ),
    );
  }
}
/*..._achievements
                        .map((e) => AchievementCard(achievement: e))
                        .toList() */
