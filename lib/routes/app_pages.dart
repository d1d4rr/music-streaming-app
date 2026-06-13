import 'package:get/get.dart';
import '../views/home_view.dart';
import '../views/search_view.dart';
import '../views/player_view.dart';
import '../views/favorites_view.dart';
import '../views/splash_view.dart';
import '../views/settings_view.dart';
import '../views/about_view.dart';

class AppPages {
  static const initial = '/splash';

  static final routes = [
    GetPage(
      name: '/splash',
      page: () => const SplashView(),
    ),
    GetPage(
      name: '/',
      page: () => const HomeView(),
    ),
    GetPage(
      name: '/search',
      page: () => const SearchView(),
    ),
    GetPage(
      name: '/player',
      page: () => const PlayerView(),
    ),
    GetPage(
      name: '/favorites',
      page: () => const FavoritesView(),
    ),
    GetPage(
      name: '/settings',
      page: () => const SettingsView(),
    ),
    GetPage(
      name: '/about',
      page: () => const AboutView(),
    ),
  ];
}
