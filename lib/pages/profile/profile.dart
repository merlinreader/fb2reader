import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:merlin/UI/icon/custom_icon.dart';
import 'package:merlin/UI/theme/theme.dart';
import 'package:merlin/components/achievement.dart';
import 'package:merlin/components/ads/network_provider.dart';
import 'package:merlin/components/svg/svg_widget.dart';
import 'package:merlin/domain/dto/achievements/get_achievements_response.dart';
import 'package:merlin/pages/profile/dialogs/choose_avatar_dialog/choose_avatar_dialog.dart';
import 'package:merlin/pages/profile/profile_view_model.dart';
import 'package:merlin/style/colors.dart';
import 'package:merlin/style/text.dart';
import 'package:merlin/components/button/button.dart';
import 'package:merlin/functions/sendmail.dart';
import 'package:merlin/functions/location.dart';
import 'package:merlin/components/ads/advertisement.dart';
import 'package:merlin/main.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:uni_links/uni_links.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:yandex_mobileads/mobile_ads.dart';

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
  late RewardedAdPage rewardedAdPage;
  String? selectedCountry;
  String? selectedState;
  String? selectedCity;

  String token = '';
  late String getToken;
  String firstName = 'Merlin';
  List<AchievementStatus> getAchievements = [];
  late var achievements;

  final networks = NetworkProvider.instance.rewardedNetworks;

  late var adUnitId = networks.first.adUnitId;
  RewardedAd? _ad;
  late final RewardedAdLoader _adLoader;
  var adRequest = const AdRequest();
  late final AdRequestConfiguration _adRequestConfiguration = AdRequestConfiguration(adUnitId: adUnitId);
  var isLoading = false;

  // кол-во доступнх юзеру слов
  int words = 10;
  late int getWords;

  // ignore: unused_field
  String? _link = 'unknown';
  @override
  void initState() {
    super.initState();
    initUniLinks();
    getTokenFromLocalStorage();
    getWordsFromLocalStorage();
    getFirstName();
    MobileAds.initialize();
    _initAds();
  }

  void saveWordsToLocalStorage(int words) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('words', words);
  }

  Future<void> getWordsFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      getWords = prefs.getInt('words') ?? 10;
      words = getWords;
    });
  }

  Future<void> _initAds() async {
    _adLoader = await RewardedAdLoader.create(
      onAdLoaded: (RewardedAd rewardedAd) {
        setState(() => {_ad = rewardedAd, isLoading = false});
        _showRewardedAd();
        // logMessage('callback: rewarded ad loaded');
      },
      onAdFailedToLoad: (error) {
        setState(() => {_ad = null, isLoading = false});
        // logMessage('callback: rewarded ad failed to load, '
        //     'code: ${error.code}, description: ${error.description}');
      },
    );
  }

  Future<void> _showRewardedAd() async {
    final ad = _ad;
    if (ad != null) {
      _setAdEventListener(ad);
      await ad.show();
      // logMessage('async: shown rewarded ad');
      // logMessage('async: dismissed rewarded ad, '
      // 'reward: ${reward?.amount} of ${reward?.type}');
      setState(() => _ad = null);
    }
  }

  void _setAdEventListener(RewardedAd ad) async {
    ad.setAdEventListener(
        eventListener: RewardedAdEventListener(
            // onAdShown: () => print("callback: rewarded ad shown."),
            // onAdFailedToShow: (error) => print(
            //     "callback: rewarded ad failed to show: ${error.description}."),
            // onAdDismissed: () => print("\ncallback: rewarded ad dismissed.\n"),
            // onAdClicked: () => print("callback: rewarded ad clicked."),
            // onAdImpression: (data) =>
            //     print("callback: rewarded ad impression: ${data.getRawData()}"),
            onRewarded: (Reward reward) async => saveWordsToLocalStorage(words + 5)));
  }

  void saveGeo(String country, String area, String locality) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("country", country ?? '');
    prefs.setString("adminArea", area ?? '');
    prefs.setString("locality", locality ?? '');
    Map<String, String> locationData = {
      'country': country ?? '',
      'area': area ?? '',
      'city': locality ?? '',
    };
    await sendLocationDataToServer(locationData, prefs.getString('token') ?? '');
  }

  Future<List<Achievement>> fetchJson() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    final url = Uri.parse('https://fb2.cloud.leam.pro/api/account/achievements');
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
      return achievements;
    } else {
      // print('Ошибка запроса достижений: ${response.statusCode}');
      // print('Токен: $token');
      return [];
    }
  }

  Future<void> getAchievementsFromJson() async {
    achievements = await fetchJson();
    for (var entry in achievements) {
      getAchievements.add(AchievementStatus(entry, false));
    }
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

    if (response.statusCode == 200) {
      if (data['firstName'].isNotEmpty) {
        fetchedName = data['firstName'];
        firstName = fetchedName.toString();

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
      firstName = prefs.getString('firstName') ?? firstName;
    });
  }

  @override
  Widget build(BuildContext context) {
    getFirstNameFromLocalStorage();
    double size = 20;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final avatar = context.watch<ProfileViewModel>().storedAvatar;
    final setNewAvatar = context.read<ProfileViewModel>().setNewAvatar;
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
              clipBehavior: Clip.none,
              alignment: AlignmentDirectional.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    avatar == null
                        ? const MerlinWidget()
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.memory(
                              avatar,
                              width: 100,
                              height: 100,
                            ))
                  ],
                ),
                if (token != '')
                  Positioned(
                    bottom: -14,
                    right: MediaQuery.of(context).size.width / 2 - 48 - 24,
                    child: IconButton(
                        onPressed: () async {
                          final avatarChanged = await showChooseAvatarDialog(context);
                          setNewAvatar(avatarChanged);
                        },
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
                  final locationData = snapshot.data ?? 'Нет данных о местоположении';
                  return selectedCountry != '' && selectedState != '' && selectedCity != ''
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: size),
                            Text16(text: locationData, textColor: MyColors.black),
                            IconButton(
                                onPressed: geo,
                                icon: Icon(
                                  CustomIcons.pen,
                                  size: size,
                                )),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: size),
                            Text14(text: "$selectedCountry, $selectedState, $selectedCity", textColor: MyColors.black),
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
                            final tgUrl = Uri.parse('https://t.me/merlin_auth_bot?start=1');
                            launchUrl(tgUrl, mode: LaunchMode.externalApplication);
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
                              data: themeProvider.isDarkTheme ? darkTheme() : lightTheme(),
                              child: Button(
                                  text: 'Написать нам',
                                  width: 312,
                                  height: 48,
                                  horizontalPadding: 97,
                                  verticalPadding: 12,
                                  textColor: Theme.of(context).colorScheme.onSurface,
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
                          text: 'Получить 5 слов',
                          width: 312,
                          height: 48,
                          horizontalPadding: 97,
                          verticalPadding: 12,
                          textColor: MyColors.white,
                          fontSize: 14,
                          onPressed: () {
                            // print(words);
                            // print('Added 5 words');
                            _adLoader.loadAd(adRequestConfiguration: _adRequestConfiguration);
                            // saveWordsToLocalStorage(100);
                            // saveWordsToLocalStorage(words + 5);
                            Fluttertoast.showToast(msg: 'Вам доступно $words слов', toastLength: Toast.LENGTH_LONG);
                            // print(words);
                            // Navigator.pushNamed(context, RouteNames.rewardedAd);
                            //rewardedAdPage.callShowRewardedAd();
                          },
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Theme(
                        data: grayButton(),
                        child: Button(
                          text: 'Убрать рекламу',
                          width: 312,
                          height: 48,
                          horizontalPadding: 97,
                          verticalPadding: 12,
                          textColor: Theme.of(context).disabledColor,
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
                              data: themeProvider.isDarkTheme ? darkTheme() : lightTheme(),
                              child: Button(
                                  text: 'Написать нам',
                                  width: 312,
                                  height: 48,
                                  horizontalPadding: 97,
                                  verticalPadding: 12,
                                  textColor: Theme.of(context).colorScheme.onSurface,
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
              title: Center(
                child: TextButton(
                    onPressed: () {
                      Clipboard.setData(const ClipboardData(text: 'readermerlin@gmail.com'));
                      Fluttertoast.showToast(
                        msg: 'Почта скопирована',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );
                    },
                    child: const Text18(text: 'readermerlin@gmail.com', textColor: MyColors.black)),

                // child: Text18(
                //     text: 'readermerlin@gmail.com',
                //     textColor: MyColors.black)
              ),
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
                          data: themeProvider.isDarkTheme ? darkTheme() : lightTheme(),
                          child: Button(
                              text: "Отмена",
                              width: 250,
                              height: 50,
                              horizontalPadding: 10,
                              verticalPadding: 10,
                              textColor: Theme.of(context).colorScheme.onSurface,
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
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: const Center(
            child: Text20(text: 'Геолокация', textColor: MyColors.black),
          ),
          alignment: Alignment.center,
          actions: [
            CSCPicker(
              stateDropdownLabel: 'Область',
              countryDropdownLabel: 'Страна',
              cityDropdownLabel: 'Город',
              layout: Layout.vertical,
              selectedItemStyle: TextStyle(color: themeProvider.isDarkTheme ? MyColors.white : MyColors.black),
              dropdownDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                  border: Border.all(color: MyColors.lightGray)),
              disabledDropdownDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                  border: Border.all(color: MyColors.lightGray)),
              onCountryChanged: (value) {
                setState(() {
                  selectedCountry = value;
                });
              },
              onStateChanged: (value) {
                setState(() {
                  selectedState = value;
                });
              },
              onCityChanged: (value) {
                setState(() {
                  selectedCity = value;
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
              child: Center(
                child: SizedBox(
                  width: 400, // Увеличиваем ширину кнопки
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.purple, // Цвет кнопки
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Скругление углов
                      ),
                    ),
                    onPressed: () {
                      saveGeo(selectedCountry!, selectedState!, selectedCity!);
                      Navigator.of(context).pop();
                    },
                    child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                        child: Text(
                          'Сохранить',
                          style: TextStyle(color: MyColors.white, fontFamily: 'Tektur', fontSize: 16),
                        )),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
