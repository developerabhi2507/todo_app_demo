import 'package:flutter/material.dart';

// app color initialize
const scaffoldBGColor = Color(0xFF25272A);
const appbarTitleColor = Color(0xFFFFFFFF);
const appBarTitleIconColor = Color(0xFF000000);
const appBarTitleIconBGColor = Color(0xFF00FFFF);
const iconColor = Color(0xFFFFFFFF);
const fontColor = Color(0xFFFFFFFF);
const outlineButtonColor = Color(0xFF202123);
const outlineButtonBGColor = Color(0xFF00FFFF);
const overlayColor = Color(0xFF00FFFF);
const iconBackgroundColor1 = Color(0xFF00FFFF);
const iconBackgroundColor2 = Color(0xFF00FFFF);
const iconColor1 = Color(0xFF000000);
const textButtonColor = Color(0xFF202123);
const myListAppBarColor = Color(0xFF202123);
const textButtonBackgroundColor = Color(0xFF00FFFF);
const prefixIconColor = Color(0xFF00FFFF);
const socialIconBackgroundColor = Color(0xFF2D2F33);
const fbIconColor = Color(0xFF3B5998);
const homeSlide1Color = Color(0xFF25272A);
const playButtonColor = Color(0xFF202123);
const editProfileCameraIconBackgroundColor = Color(0xFF202123);

// app constant values
const appTitle = 'Halkut';

IconThemeData _customIconTheme1(IconThemeData original) {
  return original.copyWith(color: appBarTitleIconColor);
}

ThemeData buildDarkTheme() {
  final ThemeData base = ThemeData.dark();
  return base.copyWith(
      brightness: Brightness.dark,
      primaryColor: scaffoldBGColor,
      scaffoldBackgroundColor: scaffoldBGColor,
      appBarTheme: AppBarTheme(
          titleTextStyle: const TextTheme(
              titleLarge: TextStyle(
        color: appbarTitleColor,
      )).titleLarge),
      iconTheme: const IconThemeData(color: iconColor),
      textTheme: _buildTextTheme(base.textTheme),
      textButtonTheme: textButtonTheme,
      outlinedButtonTheme: oulinedButtonTheme,
      elevatedButtonTheme: elevatedButtonTheme);
}

TextTheme _buildTextTheme(TextTheme base) {
  return base
      .copyWith(
        titleLarge: base.titleLarge!
            .copyWith(fontSize: 25.0, fontWeight: FontWeight.w700),
        titleMedium: base.titleMedium!
            .copyWith(fontSize: 20.0, fontWeight: FontWeight.w700),
        titleSmall: base.titleSmall!
            .copyWith(fontSize: 16.0, fontWeight: FontWeight.w400),
        labelLarge: base.labelLarge!
            .copyWith(fontSize: 20.0, fontWeight: FontWeight.w700),
        labelMedium: base.labelMedium!
            .copyWith(fontSize: 16.0, fontWeight: FontWeight.w400),
        labelSmall: base.labelSmall!
            .copyWith(fontSize: 12.0, fontWeight: FontWeight.w400),
        bodyLarge: base.bodyLarge!
            .copyWith(fontSize: 16.0, fontWeight: FontWeight.w400),
        bodyMedium: base.bodyMedium!
            .copyWith(fontSize: 12.0, fontWeight: FontWeight.w400),
        bodySmall: base.bodyMedium!
            .copyWith(fontSize: 10.0, fontWeight: FontWeight.w400),
      )
      .apply(
          fontFamily: 'SF Pro Display',
          displayColor: fontColor,
          bodyColor: fontColor);
}

TextButtonThemeData textButtonTheme = const TextButtonThemeData(
    style: ButtonStyle(
  overlayColor: MaterialStatePropertyAll(overlayColor),
));

ElevatedButtonThemeData elevatedButtonTheme = const ElevatedButtonThemeData(
    style: ButtonStyle(
  backgroundColor: MaterialStatePropertyAll(Colors.transparent),
  overlayColor: MaterialStatePropertyAll(overlayColor),
));

OutlinedButtonThemeData oulinedButtonTheme = const OutlinedButtonThemeData(
    style: ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(outlineButtonBGColor),
        foregroundColor: MaterialStatePropertyAll(outlineButtonColor),
        textStyle: MaterialStatePropertyAll(
            TextStyle(fontSize: 14, fontWeight: FontWeight.w400))));
