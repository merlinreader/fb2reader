import 'package:flutter/material.dart';
import 'package:merlin/style/colors.dart';

ThemeData darkTheme() => ThemeData(
    //brightness: Brightness.dark,
    colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: MyColors.blackGray,
        onPrimary: MyColors.white,
        secondary: Colors.red,
        onSecondary: MyColors.darkGray,
        error: Colors.red,
        onError: Colors.red,
        background: MyColors.darkGray,
        onBackground: Colors.black,
        surface: MyColors.blackGray,
        onSurface: Colors.white,
        scrim: Colors.blue),
    //primarySwatch: Colors.blue,
    textTheme: const TextTheme(
        //text24
        titleLarge: TextStyle(
            color: MyColors.bgWhite,
            fontFamily: 'Tektur',
            fontSize: 24,
            fontWeight: FontWeight.bold),
        //text20
        labelMedium: TextStyle(
            color: MyColors.bgWhite,
            fontFamily: 'Tektur',
            fontSize: 20,
            fontWeight: FontWeight.bold),
        //Text11
        bodySmall: TextStyle(
            fontFamily: 'Tektur',
            color: MyColors.bgWhite,
            fontSize: 11,
            fontWeight: FontWeight.bold),
        //Text14
        bodyLarge: TextStyle(
            fontFamily: 'Tektur',
            color: MyColors.bgWhite,
            fontSize: 14,
            fontWeight: FontWeight.normal),
        //Text18
        titleMedium: TextStyle(
            fontFamily: 'Tektur',
            color: MyColors.bgWhite,
            fontSize: 18,
            fontWeight: FontWeight.normal),
        //Text12
        titleSmall: TextStyle(
            fontFamily: 'Tektur',
            color: MyColors.bgWhite,
            fontSize: 12,
            fontWeight: FontWeight.normal),
        //Text7
        displaySmall: TextStyle(
            fontFamily: 'Tektur',
            color: MyColors.black,
            fontSize: 7,
            fontWeight: FontWeight.normal),
        //Text16
        displayMedium: TextStyle(
            fontFamily: 'Tektur',
            color: MyColors.bgWhite,
            fontSize: 16,
            fontWeight: FontWeight.bold),
        bodyMedium: TextStyle(
            fontFamily: 'Roboto',
            color: MyColors.bgWhite,
            fontWeight: FontWeight.normal)),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  0), // Установите радиус закругления на 0, чтобы убрать закругление.
            ),
          ),
          backgroundColor: const MaterialStatePropertyAll(MyColors.blackBt),
          textStyle:
              const MaterialStatePropertyAll(TextStyle(color: MyColors.white))),
    ),
    iconTheme: const IconThemeData(color: MyColors.white),
    //dataTableTheme: DataTableThemeData(headingCellCursor: MaterialStateColor.resolveWith(states){return MyColors.darkGray;})
    dataTableTheme: DataTableThemeData(
      headingRowColor:
          MaterialStateColor.resolveWith((states) => MyColors.darkGray),
      dataRowColor:
          MaterialStateColor.resolveWith((states) => MyColors.darkGray),
    ));

ThemeData purpleButton() => ThemeData(
        elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  0), // Установите радиус закругления на 0, чтобы убрать закругление.
            ),
          ),
          elevation: null,
          backgroundColor: const MaterialStatePropertyAll(MyColors.purple),
          textStyle:
              const MaterialStatePropertyAll(TextStyle(color: MyColors.white))),
    ));

ThemeData lightTheme() => ThemeData(
    colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: MyColors.white,
        onPrimary: MyColors.white,
        secondary: Colors.red,
        onSecondary: MyColors.darkGray,
        error: Colors.red,
        onError: Colors.red,
        background: MyColors.white,
        onBackground: Colors.black,
        surface: MyColors.blackGray,
        onSurface: Colors.black,
        scrim: Colors.blue),
    //primarySwatch: Colors.blue,
    textTheme: const TextTheme(
        //text24
        titleLarge: TextStyle(
            color: MyColors.black,
            fontFamily: 'Tektur',
            fontSize: 24,
            fontWeight: FontWeight.bold),
        //Text11
        bodySmall: TextStyle(
            fontFamily: 'Tektur',
            color: MyColors.black,
            fontSize: 11,
            fontWeight: FontWeight.bold),
        //Text14
        bodyLarge: TextStyle(
            fontFamily: 'Tektur',
            color: MyColors.black,
            fontSize: 14,
            fontWeight: FontWeight.normal),
        //Text18
        titleMedium: TextStyle(
            fontFamily: 'Tektur',
            color: MyColors.black,
            fontSize: 18,
            fontWeight: FontWeight.normal),
        //text20
        labelMedium: TextStyle(
            color: MyColors.bgWhite,
            fontFamily: 'Tektur',
            fontSize: 20,
            fontWeight: FontWeight.bold),
        //Text12
        titleSmall: TextStyle(
            fontFamily: 'Tektur',
            color: MyColors.black,
            fontSize: 12,
            fontWeight: FontWeight.normal),
        //Text7
        displaySmall: TextStyle(
            fontFamily: 'Tektur',
            color: MyColors.bgWhite,
            fontSize: 7,
            fontWeight: FontWeight.normal),
        //Text16
        displayMedium: TextStyle(
            fontFamily: 'Tektur',
            color: MyColors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold),
        bodyMedium: TextStyle(
            fontFamily: 'Roboto',
            color: MyColors.black,
            fontWeight: FontWeight.normal)),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  0), // Установите радиус закругления на 0, чтобы убрать закругление.
            ),
          ),
          backgroundColor: const MaterialStatePropertyAll(MyColors.bgWhite),
          textStyle:
              const MaterialStatePropertyAll(TextStyle(color: MyColors.black))),
    ),
    iconTheme: const IconThemeData(color: MyColors.black),
    //dataTableTheme: DataTableThemeData(headingCellCursor: MaterialStateColor.resolveWith(states){return MyColors.darkGray;})
    dataTableTheme: DataTableThemeData(
      headingRowColor:
          MaterialStateColor.resolveWith((states) => MyColors.white),
      dataRowColor: MaterialStateColor.resolveWith((states) => MyColors.white),
    ));

ButtonStyle getButtonStyle(BuildContext context, {bool isPressed = false}) {
  final currentTheme = Theme.of(context);
  Color backgroundColor;
  Color textColor;

  if (currentTheme.brightness == Brightness.light) {
    backgroundColor = isPressed ? MyColors.purple : MyColors.white;
    textColor = isPressed ? MyColors.white : MyColors.black;
  } else {
    backgroundColor = isPressed ? MyColors.purple : MyColors.darkGray;
    textColor = isPressed ? MyColors.white : MyColors.black;
  }

  return ButtonStyle(
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
    ),
    elevation: MaterialStateProperty.all(0),
    backgroundColor: MaterialStateProperty.all(backgroundColor),
    textStyle: MaterialStateProperty.all(TextStyle(color: textColor)),
  );
}
