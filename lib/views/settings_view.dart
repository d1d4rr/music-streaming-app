import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../controllers/player_controller.dart';
import '../widgets/app_drawer.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark
        ? const Color(0xFF2196F3)
        : const Color(0xFF1976D2);

    return Scaffold(
      drawer: const AppDrawer(),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 160,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [const Color(0xFF1A0B2E), const Color(0xFF0A0A0F)]
                        : [const Color(0xFFF3E8FF), const Color(0xFFF8F9FA)],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 24, bottom: 24, top: 60),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  accentColor,
                                  accentColor.withValues(alpha: 0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.settings_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Settings',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF1A1A24),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Customize your experience',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            leading: Builder(
              builder: (BuildContext context) {
                return Container(
                  margin: const EdgeInsets.all(8),
                  child: IconButton(
                    icon: const Icon(Icons.menu_rounded),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    style: IconButton.styleFrom(
                      backgroundColor: accentColor.withValues(alpha: 0.1),
                      foregroundColor: accentColor,
                    ),
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _SettingsSection(
                      title: 'App Settings',
                      icon: Icons.tune_rounded,
                      accentColor: accentColor,
                      isDark: isDark,
                      child: Obx(() {
                        final settingsController = Get.find<SettingsController>();
                        final playerController = Get.find<PlayerController>();
                        return Column(
                          children: [
                            _SettingTile(
                              icon: Icons.graphic_eq_rounded,
                              title: 'Audio Quality',
                              subtitle: settingsController.audioQuality.value,
                              accentColor: accentColor,
                              isDark: isDark,
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: accentColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: accentColor.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: DropdownButton<String>(
                                  value: settingsController.audioQuality.value,
                                  dropdownColor: isDark
                                      ? const Color(0xFF1A1A24)
                                      : Colors.white,
                                  underline: const SizedBox(),
                                  icon: Icon(
                                    Icons.arrow_drop_down_rounded,
                                    color: accentColor,
                                    size: 20,
                                  ),
                                  items: ['Low', 'Medium', 'High', 'Very High']
                                      .map((quality) {
                                        return DropdownMenuItem(
                                          value: quality,
                                          child: Text(
                                            quality,
                                            style: TextStyle(
                                              color: isDark
                                                  ? Colors.white
                                                  : const Color(0xFF1A1A24),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        );
                                      })
                                      .toList(),
                                  onChanged: (quality) {
                                    if (quality != null) {
                                      settingsController.setAudioQuality(quality);
                                      playerController.setAudioQualityMultiplier(
                                        settingsController.audioQualityMultiplier,
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _SettingTile(
                              icon: Icons.notifications_rounded,
                              title: 'Notifications',
                              subtitle: settingsController.notificationsEnabled.value
                                  ? 'Enabled'
                                  : 'Disabled',
                              accentColor: accentColor,
                              isDark: isDark,
                              trailing: Switch(
                                value: settingsController.notificationsEnabled.value,
                                onChanged: (_) =>
                                    settingsController.toggleNotifications(),
                                activeThumbColor: accentColor,
                                activeTrackColor: accentColor.withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _SettingTile(
                              icon: Icons.storage_rounded,
                              title: 'Cache Size',
                              subtitle: settingsController.cacheSizeDisplay,
                              accentColor: accentColor,
                              isDark: isDark,
                              trailing: settingsController.cacheSize.value > 0
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.delete_sweep_rounded,
                                        color: accentColor,
                                      ),
                                      onPressed: () {
                                        settingsController.clearCache();
                                        Get.snackbar(
                                          'Success',
                                          'Cache cleared successfully!',
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: accentColor,
                                          colorText: Colors.white,
                                          borderRadius: 12,
                                        );
                                      },
                                    )
                                  : Icon(
                                      Icons.storage_rounded,
                                      color: accentColor.withValues(alpha: 0.5),
                                    ),
                            ),
                          ],
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    _SettingsSection(
                      title: 'Playback Settings',
                      icon: Icons.play_circle_outline_rounded,
                      accentColor: accentColor,
                      isDark: isDark,
                      child: Obx(() {
                        final settingsController = Get.find<SettingsController>();
                        final playerController = Get.find<PlayerController>();
                        return Column(
                          children: [
                            _SettingTile(
                              icon: Icons.repeat_rounded,
                              title: 'Repeat Mode',
                              subtitle: playerController.repeatMode.value,
                              accentColor: accentColor,
                              isDark: isDark,
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: accentColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: accentColor.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: DropdownButton<String>(
                                  value: playerController.repeatMode.value,
                                  dropdownColor: isDark
                                      ? const Color(0xFF1A1A24)
                                      : Colors.white,
                                  underline: const SizedBox(),
                                  icon: Icon(
                                    Icons.arrow_drop_down_rounded,
                                    color: accentColor,
                                    size: 20,
                                  ),
                                  items: ['Off', 'One', 'All'].map((mode) {
                                    return DropdownMenuItem(
                                      value: mode,
                                      child: Text(
                                        mode,
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.white
                                              : const Color(0xFF1A1A24),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (mode) {
                                    if (mode != null) {
                                      playerController.setRepeatMode(mode);
                                      settingsController.setRepeatMode(mode);
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _SettingTile(
                              icon: Icons.shuffle_rounded,
                              title: 'Shuffle',
                              subtitle: playerController.shuffleEnabled.value ? 'On' : 'Off',
                              accentColor: accentColor,
                              isDark: isDark,
                              trailing: Switch(
                                value: playerController.shuffleEnabled.value,
                                onChanged: (_) {
                                  playerController.setShuffle(!playerController.shuffleEnabled.value);
                                  settingsController.toggleShuffle();
                                },
                                activeThumbColor: accentColor,
                                activeTrackColor: accentColor.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    _SettingsSection(
                      title: 'Info',
                      icon: Icons.info_outline_rounded,
                      accentColor: accentColor,
                      isDark: isDark,
                      child: _SettingTile(
                        icon: Icons.apps_rounded,
                        title: 'App Version',
                        subtitle: '1.0.0',
                        accentColor: accentColor,
                        isDark: isDark,
                        trailing: Icon(
                          Icons.info_rounded,
                          color: accentColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accentColor;
  final bool isDark;
  final Widget child;

  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.isDark,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A24) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1A1A24),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final bool isDark;
  final Widget? trailing;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.isDark,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.1), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A1A24),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
