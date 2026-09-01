import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocabulary_builder/features/settings/presentation/providers/theme_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeController Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Initial theme mode is ThemeMode.system when no preference is saved', () async {
      SharedPreferences.setMockInitialValues({});
      final controller = ThemeController();
      expect(controller.state, equals(ThemeMode.system));
    });

    test('Loads light theme mode from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({kThemeModePrefKey: 'light'});
      final controller = ThemeController();
      // Allow async _loadThemeMode to complete
      await Future.delayed(const Duration(milliseconds: 50));
      expect(controller.state, equals(ThemeMode.light));
    });

    test('Loads dark theme mode from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({kThemeModePrefKey: 'dark'});
      final controller = ThemeController();
      // Allow async _loadThemeMode to complete
      await Future.delayed(const Duration(milliseconds: 50));
      expect(controller.state, equals(ThemeMode.dark));
    });

    test('setThemeMode updates state and saves to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final controller = ThemeController();

      await controller.setThemeMode(ThemeMode.dark);
      expect(controller.state, equals(ThemeMode.dark));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(kThemeModePrefKey), equals('dark'));

      await controller.setThemeMode(ThemeMode.light);
      expect(controller.state, equals(ThemeMode.light));
      expect(prefs.getString(kThemeModePrefKey), equals('light'));

      await controller.setThemeMode(ThemeMode.system);
      expect(controller.state, equals(ThemeMode.system));
      expect(prefs.getString(kThemeModePrefKey), equals('system'));
    });
  });
}
