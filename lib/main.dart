import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/app_pages.dart';
import 'controllers/music_controller.dart';
import 'controllers/player_controller.dart';
import 'controllers/theme_controller.dart';
import 'controllers/settings_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Get.put(MusicController(), permanent: true);
  Get.put(PlayerController(), permanent: true);
  Get.put(ThemeController(), permanent: true);
  Get.put(SettingsController(), permanent: true);

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kDebugMode) {
      print(details.exceptionAsString());
    }

    if (kDebugMode) {
      print(details.stack);
    }
  };

  runZonedGuarded(
    () {
      runApp(const MyApp());
    },
    (error, stack) {
      if (kDebugMode) {
        print(error);
      }
      if (kDebugMode) {
        print(stack);
      }
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return _AppInitializer(
      child: Obx(() {
        final themeController = Get.find<ThemeController>();
        return GetMaterialApp(
          title: 'Sputify',
          debugShowCheckedModeBanner: false,
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          themeMode: themeController.isDarkMode.value
              ? ThemeMode.dark
              : ThemeMode.light,
          initialRoute: AppPages.initial,
          getPages: AppPages.routes,
        );
      }),
    );
  }

  ThemeData _buildDarkTheme() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2196F3),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF0A1628),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      textTheme: base.textTheme.copyWith(
        displayLarge: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        titleLarge: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        bodyLarge: const TextStyle(fontSize: 16, letterSpacing: 0.2),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: const Color(0xFF1A2332).withValues(alpha: 0.6),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  ThemeData _buildLightTheme() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2196F3),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFE3F2FD),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: Color(0xFF1A1A24),
        ),
        iconTheme: IconThemeData(color: Color(0xFF1A1A24)),
      ),
      textTheme: base.textTheme.copyWith(
        displayLarge: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: Color(0xFF1A1A24),
        ),
        titleLarge: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: Color(0xFF1A1A24),
        ),
        bodyLarge: const TextStyle(
          fontSize: 16,
          letterSpacing: 0.2,
          color: Color(0xFF1A1A24),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: Colors.white.withValues(alpha: 0.9),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}

class _AppInitializer extends StatefulWidget {
  final Widget child;

  const _AppInitializer({required this.child});

  @override
  State<_AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<_AppInitializer> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    if (!mounted) return;

    final settingsController = Get.find<SettingsController>();
    final playerController = Get.find<PlayerController>();

    int attempts = 0;
    while (!settingsController.isLoaded.value && attempts < 10 && mounted) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }

    if (mounted && !_initialized && settingsController.isLoaded.value) {
      playerController.initializeFromSettings(
        settingsController.repeatMode.value,
        settingsController.shuffleEnabled.value,
        settingsController.audioQualityMultiplier,
      );
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
