import 'package:flutter/material.dart';

class ThemeController {
  static final ValueNotifier<ThemeMode> mode = ValueNotifier(ThemeMode.system);

  static bool isDark(BuildContext context) {
    final currentMode = mode.value;

    if (currentMode == ThemeMode.system) {
      return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    }

    return currentMode == ThemeMode.dark;
  }

  static void setDarkMode(bool enabled) {
    mode.value = enabled ? ThemeMode.dark : ThemeMode.light;
  }
}



