import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final SharedPreferences prefs;

  ThemeCubit({required this.prefs}) : super(_getInitialTheme(prefs));

  static ThemeMode _getInitialTheme(SharedPreferences prefs) {
    final saved = prefs.getString(AppConstants.themeKey);
    if (saved == 'light') return ThemeMode.light;
    return ThemeMode.dark; // Default to Obsidian IDE Dark
  }

  void toggleTheme() {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setTheme(next);
  }

  void setTheme(ThemeMode mode) {
    prefs.setString(
      AppConstants.themeKey,
      mode == ThemeMode.light ? 'light' : 'dark',
    );
    emit(mode);
  }
}
