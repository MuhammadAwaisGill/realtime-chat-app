
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier{
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? theme = prefs.getString('theme');
    if (theme == 'light') {
      _themeMode = ThemeMode.light;
    }
    else if (theme == 'dark') {
      _themeMode = ThemeMode.dark;
    }
    else {
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  void setTheme(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(mode == ThemeMode.light) {
      prefs.setString('theme', 'light');
    }
    else if (mode == ThemeMode.dark) {
      prefs.setString('theme', 'dark');
    }
    else {
      prefs.setString('theme', 'system');
    }
  }
}
