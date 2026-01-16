import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/theme_service.dart';

final themeModeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

