import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:merlin/UI/icon/custom_icon.dart';
import 'package:merlin/style/colors.dart';
import 'package:merlin/style/text.dart';
import 'package:merlin/main.dart';
import 'package:merlin/components/checkbox.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

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
  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isChecked = prefs.getBool('isDarkTheme') ?? false;
      backgroundColorBlack = prefs.getBool('backgroundColorBlack') ?? false;
      backgroundColorWhite = prefs.getBool('backgroundColorWhite') ?? false;
      backgroundColorMint = prefs.getBool('backgroundColorMint') ?? false;
      backgroundColorBeige = prefs.getBool('backgroundColorBeige') ?? false;

      textColorBlack = prefs.getBool('textColorBlack') ?? false;
      textColorWhite = prefs.getBool('textColorWhite') ?? false;
      textColorMint = prefs.getBool('textColorMint') ?? false;
      textColorBeige = prefs.getBool('textColorBlack') ?? false;

      // Восстанавливаем состояние темной темы
      isDarkTheme = isChecked;
    });
  }

  Future<void> saveSettings(bool isDarkTheme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', isDarkTheme);
  }

  // Перменная для изменения темы
  bool isDarkTheme = false;
  bool isChecked = false;
  // Переменные для темы
  bool darkThemeBackground = false;
  Color themeAppBackground = MyColors.bgWhite;
  Color themeBackground = MyColors.white;
  Color themeTextColor = MyColors.black;
  Color themeGrayTextColor = MyColors.grey;
  // Переменные для изменений цвета предпросмотра
  bool backgroundColorBlack = false;
  bool backgroundColorWhite = false;
  bool backgroundColorMint = false;
  bool backgroundColorBeige = false;
  Color backgroundColorPreview = MyColors.white;
  bool textColorBlack = false;
  bool textColorWhite = false;
  bool textColorMint = false;
  bool textColorBeige = false;
  Color textColorPreview = MyColors.black;

  void saveStylePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('backgroundColor', backgroundColorPreview.value);
    await prefs.setInt('textColor', textColorPreview.value);
  }

  void saveCheckboxes() async {
    final prefs = await SharedPreferences.getInstance();
    if (textColorBlack == true) {
      await prefs.setBool('textColorBlack', true);
    } else if (textColorBlack == false) {
      await prefs.setBool('textColorBlack', false);
    }
    if (textColorWhite == true) {
      await prefs.setBool('textColorWhite', true);
    } else if (textColorWhite == false) {
      await prefs.setBool('textColorWhite', false);
    }
    if (textColorMint == true) {
      await prefs.setBool('textColorMint', true);
    } else if (textColorMint == false) {
      await prefs.setBool('textColorMint', false);
    }
    if (textColorBeige == true) {
      await prefs.setBool('textColorBeige', true);
    } else if (textColorBeige == false) {
      await prefs.setBool('textColorBeige', false);
    }
    if (backgroundColorBlack == true) {
      await prefs.setBool('backgroundColorBlack', true);
    } else if (backgroundColorBlack == false) {
      await prefs.setBool('backgroundColorBlack', false);
    }
    if (backgroundColorWhite == true) {
      await prefs.setBool('backgroundColorWhite', true);
    } else if (backgroundColorWhite == false) {
      await prefs.setBool('backgroundColorWhite', false);
    }
    if (backgroundColorMint == true) {
      await prefs.setBool('backgroundColorMint', true);
    } else if (backgroundColorMint == false) {
      await prefs.setBool('backgroundColorMint', false);
    }
    if (backgroundColorBeige == true) {
      await prefs.setBool('backgroundColorBeige', true);
    } else if (backgroundColorBeige == false) {
      await prefs.setBool('backgroundColorBeige', false);
    }
  }

  void loadCheckboxes() async {
    final prefs = await SharedPreferences.getInstance();
    final textColorBlackCheck = prefs.getBool('textColorBlack');
    if (textColorBlackCheck != null) {
      setState(() {
        textColorBlack = textColorBlackCheck;
      });
    }
    final textColorWhiteCheck = prefs.getBool('textColorWhite');
    if (textColorWhiteCheck != null) {
      setState(() {
        textColorWhite = textColorWhiteCheck;
      });
    }
    final textColorMintCheck = prefs.getBool('textColorMint');
    if (textColorMintCheck != null) {
      setState(() {
        textColorMint = textColorMintCheck;
      });
    }
    final textColorBeigeCheck = prefs.getBool('textColorBeige');
    if (textColorBeigeCheck != null) {
      setState(() {
        textColorBeige = textColorBeigeCheck;
      });
    }
    final backgroundColorBlackCheck = prefs.getBool('backgroundColorBlack');
    if (backgroundColorBlackCheck != null) {
      setState(() {
        backgroundColorBlack = backgroundColorBlackCheck;
      });
    }
    final backgroundColorWhiteCheck = prefs.getBool('backgroundColorWhite');
    if (backgroundColorWhiteCheck != null) {
      setState(() {
        backgroundColorWhite = backgroundColorWhiteCheck;
      });
    }
    final backgroundColorMintCheck = prefs.getBool('backgroundColorMint');
    if (backgroundColorMintCheck != null) {
      setState(() {
        backgroundColorMint = backgroundColorMintCheck;
      });
    }
    final backgroundColorBeigeCheck = prefs.getBool('backgroundColorBeige');
    if (backgroundColorBeigeCheck != null) {
      setState(() {
        backgroundColorBeige = backgroundColorBeigeCheck;
      });
    }
  }

  void updateBackgroundColor(Color newColor) {
    backgroundColorPreview = newColor;
    saveStylePreferences();
  }

  void updateTextColor(Color newColor) {
    textColorPreview = newColor;
    saveStylePreferences();
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
                      text: "Ночной режим",
                      textColor: themeGrayTextColor,
                    ),
                    const Spacer(),
                    CustomCheckbox(
                      isChecked: isChecked,
                      bgColor: Theme.of(context).colorScheme.primary,
                      borderColor:
                          Theme.of(context).iconTheme.color ?? MyColors.white,
                      checkColor:
                          darkThemeBackground ? themeTextColor : themeTextColor,
                      onChanged: (newValue) {
                        final themeProvider =
                            Provider.of<ThemeProvider>(context, listen: false);
                        setState(() {
                          themeProvider.isDarkTheme = newValue;

                          isChecked = newValue;
                          saveSettings(isChecked);
                          saveSettings(themeProvider.isDarkTheme);
                          print('settings $newValue');
                        });
                      },
                    ),
                  ],
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
                Text14(
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
                          children: [
                            CustomCheckbox(
                              isChecked: textColorBlack,
                              bgColor: MyColors.black,
                              borderColor: Theme.of(context).iconTheme.color ??
                                  MyColors.white,
                              checkColor: MyColors.white,
                              onChanged: (newValue) {
                                setState(() {
                                  if (!textColorBlack &&
                                      !backgroundColorBlack) {
                                    textColorBlack = newValue;
                                    textColorWhite = false;
                                    textColorMint = false;
                                    textColorBeige = false;
                                    updateTextColor(MyColors.black);
                                    saveCheckboxes();
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
                            ),
                            CustomCheckbox(
                              isChecked: textColorWhite,
                              bgColor: MyColors.white,
                              borderColor: Theme.of(context).iconTheme.color ??
                                  MyColors.white,
                              checkColor: MyColors.black,
                              onChanged: (newValue) {
                                setState(() {
                                  if (!textColorWhite &&
                                      !backgroundColorWhite) {
                                    textColorBlack = false;
                                    textColorWhite = newValue;
                                    textColorMint = false;
                                    textColorBeige = false;
                                    updateTextColor(MyColors.white);
                                    saveCheckboxes();
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
                            ),
                            CustomCheckbox(
                              isChecked: textColorMint,
                              bgColor: MyColors.mint,
                              borderColor: Theme.of(context).iconTheme.color ??
                                  MyColors.white,
                              checkColor: MyColors.black,
                              onChanged: (newValue) {
                                setState(() {
                                  if (!textColorMint && !backgroundColorMint) {
                                    textColorBlack = false;
                                    textColorWhite = false;
                                    textColorMint = newValue;
                                    textColorBeige = false;
                                    updateTextColor(MyColors.mint);
                                    saveCheckboxes();
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
                            ),
                            CustomCheckbox(
                              isChecked: textColorBeige,
                              bgColor: MyColors.beige,
                              borderColor: Theme.of(context).iconTheme.color ??
                                  MyColors.white,
                              checkColor: MyColors.black,
                              onChanged: (newValue) {
                                setState(() {
                                  if (!textColorBeige &&
                                      !backgroundColorBeige) {
                                    textColorBlack = false;
                                    textColorWhite = false;
                                    textColorMint = false;
                                    textColorBeige = newValue;
                                    updateTextColor(MyColors.beige);
                                    saveCheckboxes();
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
                            ),
                          ],
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
                          children: [
                            CustomCheckbox(
                              isChecked: backgroundColorBlack,
                              bgColor: MyColors.black,
                              borderColor: Theme.of(context).iconTheme.color ??
                                  MyColors.white,
                              checkColor: MyColors.white,
                              onChanged: (newValue) {
                                setState(() {
                                  if (!backgroundColorBlack &&
                                      !textColorBlack) {
                                    backgroundColorBlack = newValue;
                                    backgroundColorWhite = false;
                                    backgroundColorMint = false;
                                    backgroundColorBeige = false;
                                    updateBackgroundColor(MyColors.black);
                                    saveCheckboxes();
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
                            ),
                            CustomCheckbox(
                              isChecked: backgroundColorWhite,
                              bgColor: MyColors.white,
                              borderColor: Theme.of(context).iconTheme.color ??
                                  MyColors.white,
                              checkColor: MyColors.black,
                              onChanged: (newValue) {
                                setState(() {
                                  if (!backgroundColorWhite &&
                                      !textColorWhite) {
                                    backgroundColorBlack = false;
                                    backgroundColorWhite = newValue;
                                    backgroundColorMint = false;
                                    backgroundColorBeige = false;
                                    updateBackgroundColor(MyColors.white);
                                    saveCheckboxes();
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
                            ),
                            CustomCheckbox(
                              isChecked: backgroundColorMint,
                              bgColor: MyColors.mint,
                              borderColor: Theme.of(context).iconTheme.color ??
                                  MyColors.white,
                              checkColor: MyColors.black,
                              onChanged: (newValue) {
                                setState(() {
                                  if (!backgroundColorMint && !textColorMint) {
                                    backgroundColorBlack = false;
                                    backgroundColorWhite = false;
                                    backgroundColorMint = newValue;
                                    backgroundColorBeige = false;
                                    updateBackgroundColor(MyColors.mint);
                                    saveCheckboxes();
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
                            ),
                            CustomCheckbox(
                              isChecked: backgroundColorBeige,
                              bgColor: MyColors.beige,
                              borderColor: Theme.of(context).iconTheme.color ??
                                  MyColors.white,
                              checkColor: MyColors.black,
                              onChanged: (newValue) {
                                setState(() {
                                  if (!backgroundColorBeige & !textColorBeige) {
                                    backgroundColorBlack = false;
                                    backgroundColorWhite = false;
                                    backgroundColorMint = false;
                                    backgroundColorBeige = newValue;
                                    updateBackgroundColor(MyColors.beige);
                                    saveCheckboxes();
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
                            ),
                          ],
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
                                    color: backgroundColorPreview,
                                  ))),
                          Center(
                              child: Text(
                            'Тестовый текст темы',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: textColorPreview,
                              fontFamily: 'Roboto',
                              fontSize: 14,
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
