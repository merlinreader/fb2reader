import 'package:flutter/material.dart';
import 'package:merlin/UI/icon/custom_icon.dart';
import 'package:merlin/UI/theme/theme.dart';
import 'package:merlin/components/svg/svg_widget.dart';
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
  late String firstName;

  String? _link = 'unknown';
  @override
  void initState() {
    super.initState();
    initUniLinks();
    getTokenFromLocalStorage();
  }

  Future<void> getTokenFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      getToken = prefs.getString('token') ?? '';
      token = getToken;
    });
  }

  // Future<void> initUniLinks() async {
  //   getLinksStream().listen(() {
  //     // Парсинг ссылки и переход в нужное место в приложении
  //     setState(() {
  //       qwerty = link; // Полученная deep link ссылка
  //     });
  //   }, onError: (err) {
  //     // Обработка ошибки
  //   });
  // }
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
    if (data['firstName'] == null) {
      fetchedName = 'Merlin';
    } else {
      fetchedName = data['firstName'];
    }
    print(fetchedName.toString());
    if (response.statusCode == 200) {
      setState(() {
        firstName = fetchedName.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            const MerlinWidget(),
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
                      Text14(text: locationData, textColor: MyColors.black),
                      IconButton(
                          onPressed: geo,
                          icon: const Icon(
                            CustomIcons.pen,
                            size: 20,
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
          title: const Center(
            child: Text18(text: 'Данные', textColor: MyColors.black),
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
}
