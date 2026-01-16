import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_app/providers/theme_provider.dart';

class ThemeSwitcher extends ConsumerWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return PopupMenuButton<ThemeMode>(
      icon: Icon(Icons.brightness_6),
      onSelected: (ThemeMode mode) {
        ref.read(themeModeProvider.notifier).setTheme(mode);
      },
      itemBuilder: (context) => <PopupMenuEntry<ThemeMode>>[
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