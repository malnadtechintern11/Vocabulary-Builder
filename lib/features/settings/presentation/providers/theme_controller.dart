import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preference storage key for theme mode
const String kThemeModePrefKey = 'app_theme_mode';

/// StateNotifier to manage and persist ThemeMode across app restarts
class ThemeController extends StateNotifier<ThemeMode> {
  ThemeController() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  /// Loads saved theme mode from SharedPreferences
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString(kThemeModePrefKey);

      if (savedMode == 'light') {
        state = ThemeMode.light;
      } else if (savedMode == 'dark') {
        state = ThemeMode.dark;
      } else {
        state = ThemeMode.system;
      }
    } catch (e) {
      debugPrint('Error loading theme mode: $e');
    }
  }

  /// Updates and persists the selected ThemeMode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (state == mode) return;

    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      final String modeString = switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };
      await prefs.setString(kThemeModePrefKey, modeString);
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
    }
  }
}

/// Provider for ThemeController
final themeControllerProvider = StateNotifierProvider<ThemeController, ThemeMode>((ref) {
  return ThemeController();
});
