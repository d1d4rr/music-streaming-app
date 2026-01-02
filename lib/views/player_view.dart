import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/player_controller.dart';
import '../controllers/music_controller.dart';

class PlayerView extends StatefulWidget {
  const PlayerView({super.key});

  @override
  State<PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends State<PlayerView> with TickerProviderStateMixin {
  late final AnimationController _rotationCtrl;
  late final AnimationController _fadeCtrl;
  late final AnimationController _scaleCtrl;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _pulseAnimation;

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void initState() {
    super.initState();
    _rotationCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut));
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOutCubic));
    _pulseAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _fadeCtrl.forward();
    _scaleCtrl.forward();
  }

  @override
  void dispose() {
    _rotationCtrl.dispose();
    _fadeCtrl.dispose();
    _scaleCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark
        ? const Color(0xFF2196F3)
        : const Color(0xFF1976D2);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            color: accentColor,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Obx(() {
          final playerController = Get.find<PlayerController>();
          return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.8 + (0.2 * value),
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accentColor,
                          accentColor.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      playerController.isPlaying.value
                          ? Icons.graphic_eq_rounded
                          : Icons.music_note_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      isDark ? Colors.white : const Color(0xFF1A1A24),
                      accentColor,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ).createShader(bounds),
                  child: Text(
                    'Now Playing',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (playerController.isPlaying.value)
                  FadeTransition(
                    opacity: _pulseAnimation,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.6),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          }),
        centerTitle: true,
      ),
      body: Obx(() {
        final playerController = Get.find<PlayerController>();
        final song = playerController.currentSong.value;
        if (song == null) {
          return Center(
            child: Text(
              'No song playing',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          );
        }

        if (playerController.isPlaying.value) {
          _rotationCtrl.repeat();
          _pulseCtrl.repeat(reverse: true);
        } else {
          _rotationCtrl.stop();
          _pulseCtrl.stop();
        }

          return Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            accentColor.withValues(alpha: 0.3),
                            const Color(0xFF0A0A0F),
                            const Color(0xFF1A0B2E),
                          ]
                        : [
                            accentColor.withValues(alpha: 0.2),
                            const Color(0xFFF8F9FA),
                            const Color(0xFFF3E8FF),
                          ],
                  ),
                ),
              ),
              Positioned.fill(
                child: song.artworkUrl600.isNotEmpty
                    ? Opacity(
                        opacity: 0.15,
                        child: Image.network(
                          song.artworkUrl600,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox.shrink(),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24.0, 120.0, 24.0, 24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: Hero(
                            tag: 'artwork-${song.trackId}',
                            child: Container(
                              width: 240,
                              height: 240,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: accentColor.withValues(alpha: 0.4),
                                    blurRadius: 30,
                                    offset: const Offset(0, 15),
                                  ),
                                ],
                              ),
                              child: RotationTransition(
                                turns: _rotationCtrl,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: accentColor.withValues(alpha: 0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(22),
                                    child: song.artworkUrl600.isEmpty
                                        ? Container(
                                            color: accentColor.withValues(
                                              alpha: 0.2,
                                            ),
                                            child: Icon(
                                              Icons.music_note_rounded,
                                              size: 80,
                                              color: accentColor,
                                            ),
                                          )
                                        : CachedNetworkImage(
                                            imageUrl: song.artworkUrl600,
                                            fit: BoxFit.cover,
                                            errorWidget:
                                                (
                                                  context,
                                                  url,
                                                  error,
                                                ) => Container(
                                                  color: accentColor.withValues(
                                                    alpha: 0.2,
                                                  ),
                                                  child: Icon(
                                                    Icons.music_note_rounded,
                                                    size: 80,
                                                    color: accentColor,
                                                  ),
                                                ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Hero(
                          tag: 'title-${song.trackId}',
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              song.trackName,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1A1A24),
                                letterSpacing: -0.5,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          song.artistName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white70 : Colors.black54,
                            letterSpacing: 0.2,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          song.collectionName,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white60 : Colors.black45,
                            letterSpacing: 0.1,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 40),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: accentColor,
                            inactiveTrackColor: accentColor.withValues(
                              alpha: 0.2,
                            ),
                            thumbColor: accentColor,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 8,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 20,
                            ),
                            trackHeight: 4,
                          ),
                          child: Slider(
                            value: (playerController.duration.value.inSeconds > 0)
                                ? playerController.position.value.inSeconds
                                      .clamp(
                                        0,
                                        playerController.duration.value.inSeconds,
                                      )
                                      .toDouble()
                                : 0.0,
                            max: (playerController.duration.value.inSeconds > 0)
                                ? playerController.duration.value.inSeconds.toDouble()
                                : 1.0,
                            onChanged: (value) {
                              if (playerController.duration.value.inSeconds > 0) {
                                playerController.seek(
                                  Duration(seconds: value.toInt()),
                                );
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(playerController.position.value),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.white60
                                      : Colors.black54,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                _formatDuration(playerController.duration.value),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.white60
                                      : Colors.black54,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _ControlButton(
                              icon: Icons.volume_up_rounded,
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => _VolumeDialog(
                                    accentColor: accentColor,
                                    isDark: isDark,
                                  ),
                                );
                              },
                              accentColor: accentColor,
                              isDark: isDark,
                            ),
                            const SizedBox(width: 16),
                            Obx(() {
                              final playerController = Get.find<PlayerController>();
                              final canGoPrevious =
                                  playerController.currentSong.value != null;
                              return _ControlButton(
                                icon: Icons.skip_previous_rounded,
                                size: 56,
                                onPressed: canGoPrevious
                                    ? () async {
                                        await playerController.playPrevious();
                                      }
                                    : null,
                                accentColor: accentColor,
                                isDark: isDark,
                              );
                            }),
                            const SizedBox(width: 16),
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    accentColor,
                                    accentColor.withValues(alpha: 0.8),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: accentColor.withValues(alpha: 0.5),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    if (playerController.isPlaying.value) {
                                      playerController.pause();
                                    } else {
                                      playerController.resume();
                                    }
                                  },
                                  customBorder: const CircleBorder(),
                                  child: Icon(
                                    playerController.isPlaying.value
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Obx(() {
                              final playerController = Get.find<PlayerController>();
                              final canGoNext = playerController.currentSong.value != null;
                              return _ControlButton(
                                icon: Icons.skip_next_rounded,
                                size: 56,
                                onPressed: canGoNext
                                    ? () async {
                                        await playerController.playNext();
                                      }
                                    : null,
                                accentColor: accentColor,
                                isDark: isDark,
                              );
                            }),
                            const SizedBox(width: 16),
                            Obx(() {
                              final playerController = Get.find<PlayerController>();
                              final musicController = Get.find<MusicController>();
                              final currentSong = playerController.currentSong.value;
                              if (currentSong == null) {
                                return const SizedBox.shrink();
                              }
                              final isFavorite = musicController.favorites
                                  .any((fav) => fav.trackId == currentSong.trackId);
                              return _ControlButton(
                                icon: isFavorite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                onPressed: () =>
                                    musicController.toggleFavorite(currentSong),
                                accentColor: isFavorite
                                    ? Colors.red
                                    : accentColor,
                                isDark: isDark,
                              );
                            }),
                          ],
                        ),
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _RepeatShuffleButton(
                              icon: playerController.repeatMode.value == 'Off'
                                  ? Icons.repeat_rounded
                                  : playerController.repeatMode.value == 'One'
                                  ? Icons.repeat_one_rounded
                                  : Icons.repeat_rounded,
                              isActive: playerController.repeatMode.value != 'Off',
                              label: playerController.repeatMode.value,
                              onPressed: () {
                                final modes = ['Off', 'One', 'All'];
                                final currentIndex = modes.indexOf(
                                  playerController.repeatMode.value,
                                );
                                final nextMode =
                                    modes[(currentIndex + 1) % modes.length];
                                playerController.setRepeatMode(nextMode);
                              },
                              accentColor: accentColor,
                              isDark: isDark,
                            ),
                            const SizedBox(width: 24),
                            _RepeatShuffleButton(
                              icon: Icons.shuffle_rounded,
                              isActive: playerController.shuffleEnabled.value,
                              label: playerController.shuffleEnabled.value
                                  ? 'On'
                                  : 'Off',
                              onPressed: () {
                                playerController.setShuffle(
                                  !playerController.shuffleEnabled.value,
                                );
                              },
                              accentColor: accentColor,
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color accentColor;
  final bool isDark;
  final double size;

  const _ControlButton({
    required this.icon,
    this.onPressed,
    required this.accentColor,
    required this.isDark,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isEnabled
            ? accentColor.withValues(alpha: 0.15)
            : accentColor.withValues(alpha: 0.05),
        shape: BoxShape.circle,
        border: Border.all(
          color: isEnabled
              ? accentColor.withValues(alpha: 0.3)
              : accentColor.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Icon(
            icon,
            color: isEnabled ? accentColor : accentColor.withValues(alpha: 0.4),
            size: size * 0.5,
          ),
        ),
      ),
    );
  }
}

class _RepeatShuffleButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final String label;
  final VoidCallback onPressed;
  final Color accentColor;
  final bool isDark;

  const _RepeatShuffleButton({
    required this.icon,
    required this.isActive,
    required this.label,
    required this.onPressed,
    required this.accentColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? accentColor.withValues(alpha: 0.2)
              : (isDark ? const Color(0xFF1A1A24) : Colors.white).withValues(
                  alpha: 0.5,
                ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? accentColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive
                  ? accentColor
                  : (isDark ? Colors.white60 : Colors.black54),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? accentColor
                    : (isDark ? Colors.white60 : Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VolumeDialog extends StatefulWidget {
  final Color accentColor;
  final bool isDark;

  const _VolumeDialog({required this.accentColor, required this.isDark});

  @override
  State<_VolumeDialog> createState() => _VolumeDialogState();
}

class _VolumeDialogState extends State<_VolumeDialog> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final playerController = Get.find<PlayerController>();
      final volume = playerController.currentVolume.value;

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: widget.isDark ? const Color(0xFF1A1A24) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Volume',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: widget.isDark
                        ? Colors.white
                        : const Color(0xFF1A1A24),
                  ),
                ),
                const SizedBox(height: 24),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: widget.accentColor,
                    inactiveTrackColor: widget.accentColor.withValues(
                      alpha: 0.2,
                    ),
                    thumbColor: widget.accentColor,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 10,
                    ),
                    trackHeight: 6,
                  ),
                  child: Slider(
                    value: volume,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (value) {
                      playerController.setVolume(value);
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(volume * 100).round()}%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: widget.accentColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
