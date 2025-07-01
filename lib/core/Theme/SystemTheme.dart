import 'package:flutter/material.dart';

import 'IconTheme.dart';

class AppTheme{
  AppTheme._();

  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    primaryColor: Colors.white,
    brightness: Brightness.light,
    iconTheme: WIconTheme.lightIcon,
    fontFamily: 'Poppins',
    textTheme: TextTheme(),
    useMaterial3: true,
  );
  static ThemeData darkTheme = ThemeData(
      scaffoldBackgroundColor: Colors.black,
      primaryColor: Colors.black,
      brightness: Brightness.dark,
      fontFamily: 'Poppins',
      textTheme: TextTheme(),
      iconTheme: WIconTheme.darkIcon,
      useMaterial3: true
  );
}