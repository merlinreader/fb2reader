import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:merlin/UI/icon/custom_icon.dart';
import 'package:merlin/domain/data_providers/color_provider.dart';
import 'package:merlin/style/colors.dart';
import 'package:merlin/style/text.dart';
import 'package:merlin/main.dart';
import 'package:merlin/components/checkbox.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

const colors = [MyColors.black, MyColors.white, MyColors.mint, MyColors.beige];

class ReaderStyle {
  int textColor;
  int bgcColor;

  ReaderStyle({required this.textColor, required this.bgcColor});

  Map<String, dynamic> toJson() {
    return {
      'textColor': textColor,
      'bgcColor': bgcColor,
    };
  }

  factory ReaderStyle.fromJson(Map<String, dynamic> json) {
    return ReaderStyle(
      textColor: json['textColor'],
      bgcColor: json['bgcColor'],
    );
  }
}

class MySettings extends StatelessWidget {
  const MySettings({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            background: const Color.fromRGBO(250, 250, 250, 1)),
        useMaterial3: true,
      ),
      home: const SettingsPage(),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Перменная для изменения темы
  bool isDarkTheme = false;
  bool isChecked = false;
  // Переменная размера шрифта
  double fontSize = 18;
  // Переменные для темы
  bool darkThemeBackground = false;
  Color themeAppBackground = MyColors.bgWhite;
  Color themeBackground = MyColors.white;
  Color themeTextColor = MyColors.black;
  Color themeGrayTextColor = MyColors.grey;
  // Переменные для изменений цвета предпросмотра
  final ColorProvider _colorProvider = ColorProvider();
  Color currentBackgroundColor = MyColors.white;
  Color currentTextColor = MyColors.black;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final backgroundColorFromStorage =
        await _colorProvider.getColor(ColorKeys.readerBackgroundColor);
    final textColorFromStorage =
        await _colorProvider.getColor(ColorKeys.readerTextColor);
    setState(() {
      isChecked = prefs.getBool('isDarkTheme') ?? false;
      fontSize = prefs.getDouble('fontSize') ?? 18;
      currentBackgroundColor = backgroundColorFromStorage ?? MyColors.white;
      currentTextColor = textColorFromStorage ?? MyColors.black;
      // Восстанавливаем состояние темной темы
      isDarkTheme = isChecked;
    });
  }

  Future<void> saveSettings(double fontSize) async {
    final prefs = await SharedPreferences.getInstance();
    //await prefs.setBool('isDarkTheme', isDarkTheme);
    await prefs.setDouble('fontSize', fontSize);
  }

  void updateTheme() {
    if (isChecked) {
      // Включена темная тема
      darkThemeBackground = true;
      themeAppBackground = MyColors.blackGray;
      themeBackground = MyColors.darkGray;
      themeTextColor = MyColors.white;
      themeGrayTextColor = MyColors.white;
      ThemeData(
          colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        background: MyColors.darkGray,
      ));
      // Обновите остальные переменные темной темы при необходимости
    } else {
      // Включена светлая тема
      darkThemeBackground = false;
      themeAppBackground = MyColors.white;
      themeBackground = MyColors.bgWhite;
      themeTextColor = Colors.black;
      themeGrayTextColor = MyColors.grey;
      ThemeData(
          colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        background: MyColors.white,
      ));
      // Обновите остальные переменные светлой темы при необходимости
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      //darkThemeBackground ? themeBackground : themeBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        //shadowColor: Colors.transparent,

        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
            // Navigator.popAndPushNamed(context, RouteNames.reader);
          },
          child: Icon(
            CustomIcons.chevronLeft,
            size: 40,
            color: Theme.of(context).iconTheme.color,
          ),
        ),
        title: Text(
          'Настройки',
          style: TextStyle(
            color: Theme.of(context).iconTheme.color,
            fontFamily: 'Tektur',
            fontSize: 16,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text24(text: "Система", textColor: MyColors.black),
                // TextTektur(
                //   text: "Система",
                //   fontsize: 18,
                //   textColor: themeTextColor,
                // ),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Text14(
                      text: "Размер шрифта",
                      textColor: themeGrayTextColor,
                    ),
                    const Spacer(),
                    // CustomCheckbox(
                    //   isChecked: isChecked,
                    //   bgColor: Theme.of(context).colorScheme.primary,
                    //   borderColor:
                    //       Theme.of(context).iconTheme.color ?? MyColors.white,
                    //   onChanged: (newValue) {
                    //     final themeProvider =
                    //         Provider.of<ThemeProvider>(context, listen: false);
                    //     setState(() {
                    //       themeProvider.isDarkTheme = newValue;

                    //       isChecked = newValue;
                    //       saveSettings(isChecked);
                    //       saveSettings(themeProvider.isDarkTheme);
                    //       // print('settings $newValue');
                    //     });
                    //   },
                    //   iconColor:
                    //       Theme.of(context).iconTheme.color ?? MyColors.white,
                    // ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 5.0,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 10.0),
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 20.0),
                      thumbColor: isDarkTheme
                          ? MyColors.white
                          : const Color.fromRGBO(29, 29, 33, 1),
                      activeTrackColor: isDarkTheme
                          ? MyColors.white
                          : const Color.fromRGBO(29, 29, 33, 1),
                      inactiveTrackColor: isDarkTheme
                          ? const Color.fromRGBO(96, 96, 96, 1)
                          : const Color.fromRGBO(96, 96, 96, 1),
                    ),
                    child: Slider(
                      value: fontSize,
                      onChanged: (double s) {
                        setState(() {
                          fontSize = s;
                          saveSettings(fontSize);
                        });
                      },
                      divisions: 10,
                      min: 10.0,
                      max: 30.0,
                      label: fontSize.round().toString(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text18(
                  text: "Настраиваемая тема",
                  //fontsize: 18,
                  textColor: themeTextColor,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment
                      .spaceBetween, // Этот атрибут прижмет дочерние элементы к краям
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text14(
                          text: "Цвет текста",
                          textColor: themeGrayTextColor,
                        ),
                        Row(
                          children: colors
                              .map((color) => (CustomCheckbox(
                                    isChecked: color == currentTextColor,
                                    bgColor: color,
                                    borderColor:
                                        Theme.of(context).iconTheme.color ??
                                            MyColors.white,
                                    iconColor: color == MyColors.black
                                        ? MyColors.white
                                        : MyColors.black,
                                    onChanged: (newValue) {
                                      setState(() {
                                        if (currentTextColor == color) {
                                          return;
                                        }
                                        if (currentBackgroundColor != color) {
                                          currentTextColor = color;
                                          _colorProvider.setColor(
                                              ColorKeys.readerTextColor, color);
                                        } else {
                                          Fluttertoast.showToast(
                                            msg: 'Цвета совпадают',
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                          );
                                        }
                                      });
                                    },
                                  )))
                              .toList(),
                        )
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text14(
                          text: "Цвет фона",
                          textColor: themeGrayTextColor,
                        ),
                        Row(
                          children: colors
                              .map((color) => (CustomCheckbox(
                                    isChecked: color == currentBackgroundColor,
                                    bgColor: color,
                                    borderColor:
                                        Theme.of(context).iconTheme.color ??
                                            MyColors.white,
                                    iconColor: color == MyColors.black
                                        ? MyColors.white
                                        : MyColors.black,
                                    onChanged: (newValue) {
                                      setState(() {
                                        if (currentBackgroundColor == color) {
                                          return;
                                        }
                                        if (currentTextColor != color) {
                                          currentBackgroundColor = color;
                                          _colorProvider.setColor(
                                              ColorKeys.readerBackgroundColor,
                                              color);
                                        } else {
                                          Fluttertoast.showToast(
                                            msg: 'Цвета совпадают',
                                            toastLength: Toast
                                                .LENGTH_SHORT, // Длительность отображения
                                            gravity: ToastGravity
                                                .BOTTOM, // Расположение уведомления
                                          );
                                        }
                                      });
                                    },
                                  )))
                              .toList(),
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 56,
                        decoration: const BoxDecoration(),
                        child: Stack(children: <Widget>[
                          Center(
                              child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: MyColors.black),
                                    color: currentBackgroundColor,
                                  ))),
                          Center(
                              child: Text(
                            'Тестовый текст темы',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: currentTextColor,
                              fontFamily: 'Roboto',
                              fontSize: fontSize,
                              fontWeight:
                                  FontWeight.normal, /*PERCENT not supported*/
                            ),
                          )),
                        ])))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
