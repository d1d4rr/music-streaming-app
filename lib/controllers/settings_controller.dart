import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends GetxController {
  final RxString audioQuality = 'High'.obs;
  final RxBool notificationsEnabled = true.obs;
  final RxDouble cacheSize = 0.0.obs;

  final RxString repeatMode = 'Off'.obs;
  final RxBool shuffleEnabled = false.obs;

  double get audioQualityMultiplier {
    switch (audioQuality.value) {
      case 'Low':
        return 0.6;
      case 'Medium':
        return 0.8;
      case 'High':
        return 1.0;
      case 'Very High':
        return 1.0;
      default:
        return 1.0;
    }
  }

  final RxBool isLoaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    audioQuality.value = prefs.getString('audioQuality') ?? 'High';
    notificationsEnabled.value = prefs.getBool('notificationsEnabled') ?? true;
    repeatMode.value = prefs.getString('repeatMode') ?? 'Off';
    shuffleEnabled.value = prefs.getBool('shuffleEnabled') ?? false;
    cacheSize.value = prefs.getDouble('cacheSize') ?? 0.0;
    isLoaded.value = true;
  }

  Future<void> setAudioQuality(String quality) async {
    audioQuality.value = quality;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('audioQuality', quality);
  }

  Future<void> toggleNotifications() async {
    notificationsEnabled.value = !notificationsEnabled.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', notificationsEnabled.value);
  }

  Future<void> setRepeatMode(String mode) async {
    repeatMode.value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('repeatMode', mode);
  }

  Future<void> toggleShuffle() async {
    shuffleEnabled.value = !shuffleEnabled.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('shuffleEnabled', shuffleEnabled.value);
  }

  Future<void> clearCache() async {
    cacheSize.value = 0.0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('cacheSize', 0.0);
  }

  Future<void> simulateCacheUsage(double amount) async {
    cacheSize.value = (cacheSize.value + amount).clamp(0.0, double.infinity);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('cacheSize', cacheSize.value);
  }

  String get cacheSizeDisplay {
    if (cacheSize.value < 1024) {
      return '${cacheSize.value.toStringAsFixed(2)} MB';
    } else {
      return '${(cacheSize.value / 1024).toStringAsFixed(2)} GB';
    }
  }
}
