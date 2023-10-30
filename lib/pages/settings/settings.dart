import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:merlin/style/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:merlin/style/text.dart';
import 'package:merlin/components/checkbox.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void initState() {
    loadCheckboxes();
    super.initState();
  }

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
      backgroundColor: darkThemeBackground ? themeBackground : themeBackground,
      appBar: AppBar(
        backgroundColor: themeAppBackground,
        shadowColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
            // Navigator.popAndPushNamed(context, RouteNames.reader);
          },
          child: SvgPicture.asset(
            'assets/images/chevron-left.svg',
            width: 16,
            height: 16,
          ),
        ),
        title: Text(
          'Настройки',
          style: TextStyle(
            color: darkThemeBackground ? themeTextColor : themeTextColor,
            fontFamily: 'Tektur',
            fontSize: 16,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            height: 1.0,
            color: const Color.fromRGBO(235, 235, 235, 1),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: themeBackground,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextTektur(
                  text: "Система",
                  fontsize: 18,
                  textColor: themeTextColor,
                ),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    TextTektur(
                      text: "Ночной режим",
                      fontsize: 14,
                      textColor: themeGrayTextColor,
                    ),
                    const Spacer(),
                    CustomCheckbox(
                      isChecked: isChecked,
                      bgColor: darkThemeBackground
                          ? themeAppBackground
                          : themeAppBackground,
                      borderColor:
                          darkThemeBackground ? themeTextColor : themeTextColor,
                      checkColor:
                          darkThemeBackground ? themeTextColor : themeTextColor,
                      onChanged: (newValue) {
                        setState(() {
                          isChecked = newValue;
                          updateTheme();
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
              color: themeBackground,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextTektur(
                  text: "Настраиваемая тема",
                  fontsize: 18,
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
                        TextTektur(
                          text: "Цвет текста",
                          fontsize: 14,
                          textColor: themeGrayTextColor,
                        ),
                        Row(
                          children: [
                            CustomCheckbox(
                              isChecked: textColorBlack,
                              bgColor: MyColors.black,
                              borderColor: MyColors.black,
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
                              borderColor: MyColors.black,
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
                              borderColor: MyColors.black,
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
                              borderColor: MyColors.black,
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
                        TextTektur(
                          text: "Цвет фона",
                          fontsize: 14,
                          textColor: themeGrayTextColor,
                        ),
                        Row(
                          children: [
                            CustomCheckbox(
                              isChecked: backgroundColorBlack,
                              bgColor: MyColors.black,
                              borderColor: MyColors.black,
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
                              borderColor: MyColors.black,
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
                              borderColor: MyColors.black,
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
                              borderColor: MyColors.black,
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
