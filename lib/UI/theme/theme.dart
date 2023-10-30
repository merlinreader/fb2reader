import 'package:flutter/material.dart';
import 'package:merlin/style/colors.dart';

ThemeData darkTheme() => ThemeData(
    brightness: Brightness.dark,
    primaryColor: MyColors.black,
    textTheme: const TextTheme(
        //text24
        titleLarge: TextStyle(
            color: MyColors.bgWhite,
            fontFamily: 'Tektur',
            fontSize: 24,
            fontWeight: FontWeight.bold),
        //Text14
        bodySmall: TextStyle(
            fontFamily: 'Tektur',
            color: MyColors.bgWhite,
            fontSize: 14,
            fontWeight: FontWeight.bold),
        //Text14bold
        bodyLarge: TextStyle(
          fontFamily: 'Tektur',
          color: MyColors.bgWhite,
          fontSize: 14,
          fontWeight: FontWeight.normal
        )));
