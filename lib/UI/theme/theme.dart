import 'package:flutter/material.dart';
import 'package:merlin/style/colors.dart';

ThemeData darkTheme() => ThemeData(
    brightness: Brightness.dark,
    primaryColor: MyColors.black,
    //primarySwatch: Colors.blue,
    textTheme: const TextTheme(
        //text24
        titleLarge: TextStyle(
            color: MyColors.bgWhite,
            fontFamily: 'Tektur',
            fontSize: 24,
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
            fontWeight: FontWeight.normal)),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  0), // Установите радиус закругления на 0, чтобы убрать закругление.
            ),
          ),
          backgroundColor: MaterialStatePropertyAll(MyColors.blackBt),
          textStyle:
              MaterialStatePropertyAll(TextStyle(color: MyColors.white))),
    ),
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
          backgroundColor: MaterialStatePropertyAll(MyColors.purple),
          textStyle:
              MaterialStatePropertyAll(TextStyle(color: MyColors.white))),
    ));

ThemeData whiteButton() => ThemeData(
        elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
          ),
          elevation: null,
          backgroundColor: MaterialStatePropertyAll(MyColors.white),
          textStyle:
              MaterialStatePropertyAll(TextStyle(color: MyColors.white))),
    ));

ThemeData lightTheme() => ThemeData(
    brightness: Brightness.light,
    primaryColor: MyColors.white,
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
            fontWeight: FontWeight.normal)),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  0), // Установите радиус закругления на 0, чтобы убрать закругление.
            ),
          ),
          backgroundColor: MaterialStatePropertyAll(MyColors.bgWhite),
          textStyle:
              MaterialStatePropertyAll(TextStyle(color: MyColors.black))),
    ),
    //dataTableTheme: DataTableThemeData(headingCellCursor: MaterialStateColor.resolveWith(states){return MyColors.darkGray;})
    dataTableTheme: DataTableThemeData(
      headingRowColor:
          MaterialStateColor.resolveWith((states) => MyColors.white),
      dataRowColor: MaterialStateColor.resolveWith((states) => MyColors.white),
    ));

ButtonStyle getButtonStyle(BuildContext context) {
  final currentTheme = Theme.of(context);
  if (currentTheme.brightness == Brightness.light) {
    return ButtonStyle(
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),
      elevation: null,
      backgroundColor: MaterialStateProperty.all(MyColors.white),
      textStyle: MaterialStateProperty.all(TextStyle(color: MyColors.black)),
    );
  } else {
    return ButtonStyle(
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),
      elevation: null,
      backgroundColor: MaterialStateProperty.all(MyColors.black),
      textStyle: MaterialStateProperty.all(TextStyle(color: MyColors.white)),
    );
  }
}
