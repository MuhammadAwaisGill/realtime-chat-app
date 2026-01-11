
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realtime_chat_app/change_mode/theme_provider.dart';

class ThemeSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return PopupMenuButton<ThemeMode>(
      icon: Icon(Icons.brightness_6),
      onSelected: (ThemeMode mode) {
        themeProvider.setTheme(mode);
      },
      itemBuilder: (context) => <PopupMenuEntry<ThemeMode>>[
        PopupMenuItem<ThemeMode>(
          value: ThemeMode.system,
          child: Row(
            children: [
              Icon(Icons.phone_android),
              SizedBox(width: 8),
              Text('System'),
            ],
          ),
        ),
        PopupMenuItem<ThemeMode>(
          value: ThemeMode.light,
          child: Row(
            children: [
              Icon(Icons.light_mode),
              SizedBox(width: 8),
              Text('Light'),
            ],
          ),
        ),
        PopupMenuItem<ThemeMode>(
          value: ThemeMode.dark,
          child: Row(
            children: [
              Icon(Icons.dark_mode),
              SizedBox(width: 8),
              Text('Dark'),
            ],
          ),
        ),
      ],
    );
  }
}