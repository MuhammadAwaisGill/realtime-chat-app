import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light) {
    _loadTheme();
  }

  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? theme = prefs.getString('theme');

    if (theme == 'light') {
      state = ThemeMode.light;
    } else if (theme == 'dark') {
      state = ThemeMode.dark;
    } else {
      state = ThemeMode.light;
    }
  }

  void setTheme(ThemeMode mode) async {
    state = mode;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (mode == ThemeMode.light) {
      prefs.setString('theme', 'light');
    } else if (mode == ThemeMode.dark) {
      prefs.setString('theme', 'dark');
    } else {
      prefs.setString('theme', 'light');
    }
  }
}