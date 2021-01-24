import 'package:flutter/material.dart';

// const kColorPrimary = Color(0xffFA6700);
const kColorPrimary = Color(0xff744DB8);//yellow
const kColorPrimaryLight = Color(0x65F7D03A);//yellow
const kColorPrimaryDark = Color(0xFFFA6700);
const kColorAccent = Color(0xFFB9A994);
const kColorBlue = Color(0xFF3975EA);
const kColorAsh = Color(0xFFF8F8F9);
const kColorRed = Color(0xFFEB1555);
const kColorDarkBlue = Color(0xff464B4F);
const kColorBlueBlack = Color(0xff211F21);
const kColorAshLight2 = Color(0xffD2DAE2);


Color gradientColorStart = kColorAccent;
Color gradientColorEnd = kColorPrimary;
Gradient kFabGradient = LinearGradient(
    colors: [kColorPrimary, kColorAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight);

Map<int, Color> colorSwatch = {
  50: Color.fromRGBO(255, 92, 87, .1),
  100: Color.fromRGBO(255, 92, 87, .2),
  200: Color.fromRGBO(255, 92, 87, .3),
  300: Color.fromRGBO(255, 92, 87, .4),
  400: Color.fromRGBO(255, 92, 87, .5),
  500: Color.fromRGBO(255, 92, 87, .6),
  600: Color.fromRGBO(255, 92, 87, .7),
  700: Color.fromRGBO(255, 92, 87, .8),
  800: Color.fromRGBO(255, 92, 87, .9),
  900: Color.fromRGBO(255, 92, 87, 1),
};

