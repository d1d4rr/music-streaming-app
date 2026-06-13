import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:music_streaming_app/controllers/theme_controller.dart';

void main() {
  group('ThemeController Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({'isDarkMode': false});
    });

    test('Loads dark mode preference correctly from storage', () async {
      final controller = Get.put(ThemeController());
      
      // Allow async initializations
      await Future.delayed(Duration.zero);

      expect(controller.isDarkMode.value, false);

      Get.delete<ThemeController>();
    });

    test('toggleTheme toggles the value and saves it to storage', () async {
      final controller = Get.put(ThemeController());

      await Future.delayed(Duration.zero);
      expect(controller.isDarkMode.value, false);

      await controller.toggleTheme();
      expect(controller.isDarkMode.value, true);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('isDarkMode'), true);

      Get.delete<ThemeController>();
    });
  });
}
