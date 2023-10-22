import 'package:flutter/material.dart';

class ThemeProviders extends ChangeNotifier {
  int _theme_number = 0;

  List<ThemeData> themes = [
    ThemeData.dark(useMaterial3: true),
    ThemeData.light(useMaterial3: true),
  ];
  ThemeData get themeData => themes[_theme_number];
  int get theme_number => _theme_number;

  updateTheme(int themeNumber) {
    _theme_number = themeNumber;
    notifyListeners();
  }
}
