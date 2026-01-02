import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/music_controller.dart';
import '../controllers/player_controller.dart';
import '../models/song_model.dart';
import '../widgets/app_drawer.dart';
import '../widgets/mini_player.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _searchAnimationController;
  late AnimationController _resultsAnimationController;
  late Animation<double> _searchFadeAnimation;
  late Animation<Offset> _searchSlideAnimation;
  final RxBool _hasSearched = false.obs;

  @override
  void initState() {
    super.initState();
    _searchAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _resultsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _searchFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _searchAnimationController,
        curve: Curves.easeOut,
      ),
    );
    _searchSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _searchAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _searchAnimationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchAnimationController.dispose();
    _resultsAnimationController.dispose();
    super.dispose();
  }

  void _performSearch() {
    if (_searchController.text.trim().isEmpty) return;

    _hasSearched.value = true;

    final musicController = Get.find<MusicController>();
    _resultsAnimationController.reset();
    musicController.searchSongs(_searchController.text.trim()).then((_) {
      if (mounted) {
        _resultsAnimationController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark
        ? const Color(0xFF2196F3)
        : const Color(0xFF1976D2);

    return Scaffold(
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 200,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [const Color(0xFF1A0B2E), const Color(0xFF0A0A0F)]
                            : [
                                const Color(0xFFF3E8FF),
                                const Color(0xFFF8F9FA),
                              ],
                      ),
                    ),
                    child: FadeTransition(
                      opacity: _searchFadeAnimation,
                      child: SlideTransition(
                        position: _searchSlideAnimation,
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 24,
                              right: 24,
                              bottom: 16,
                              top: 8,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF1A1A24)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.1,
                                        ),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    autofocus: true,
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF1A1A24),
                                      fontSize: 16,
                                    ),
                                    decoration: InputDecoration(
                                      hintText:
                                          'Search songs, artists, albums...',
                                      hintStyle: TextStyle(
                                        color: isDark
                                            ? Colors.white54
                                            : Colors.black45,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.search_rounded,
                                        color: accentColor,
                                      ),
                                      suffixIcon:
                                          _searchController.text.isNotEmpty
                                          ? IconButton(
                                              icon: Icon(
                                                Icons.clear_rounded,
                                                color: isDark
                                                    ? Colors.white54
                                                    : Colors.black45,
                                              ),
                                              onPressed: () {
                                                _searchController.clear();
                                                _hasSearched.value = false;
                                                Get.find<MusicController>().loadTopSongs();
                                              },
                                            )
                                          : const SizedBox.shrink(),
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 14,
                                          ),
                                    ),
                                    onSubmitted: (_) =>
                                        _performSearch(),
                                    onChanged: (value) {
                                      setState(() {});
                                    },
                                  ),
                                ),
                                const SizedBox(height: 10),
                                FadeTransition(
                                  opacity: _searchFadeAnimation,
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          _performSearch(),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: accentColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 32,
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        elevation: 4,
                                        shadowColor: accentColor.withValues(
                                          alpha: 0.4,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Search',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(Icons.search_rounded, size: 20),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
                title: GestureDetector(
                  onTap: () {
                    Get.offNamed('/');
                  },
                  child: ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        const Color(0xFF2196F3),
                        const Color(0xFFF44336),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      'Sputify',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                        shadows: [
                          Shadow(
                            color: const Color(0xFF2196F3).withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                          Shadow(
                            color: const Color(0xFFF44336).withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Obx(() {
                final musicController = Get.find<MusicController>();
                if (!_hasSearched.value) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptySearchState(
                      accentColor: accentColor,
                      isDark: isDark,
                    ),
                  );
                }

                if (musicController.isLoading.value) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              accentColor,
                            ),
                            strokeWidth: 3,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Searching...',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (musicController.errorMessage.value.isNotEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _ErrorState(
                      message: musicController.errorMessage.value,
                      onRetry: () => _performSearch(),
                      accentColor: accentColor,
                      isDark: isDark,
                    ),
                  );
                }

                if (musicController.songs.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _NoResultsState(
                      accentColor: accentColor,
                      isDark: isDark,
                      searchQuery: _searchController.text,
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.only(bottom: 80),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return FadeTransition(
                        opacity: _resultsAnimationController,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(
                            milliseconds: 300 + (index * 50),
                          ),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: _SongTile(
                            song: musicController.songs[index],
                            index: index,
                            accentColor: accentColor,
                            isDark: isDark,
                          ),
                        ),
                      );
                    }, childCount: musicController.songs.length),
                  ),
                );
              }),
            ],
          ),
          const Positioned(left: 0, right: 0, bottom: 0, child: MiniPlayer()),
        ],
      ),
    );
  }
}

class _SongTile extends StatelessWidget {
  final SongModel song;
  final int index;
  final Color accentColor;
  final bool isDark;

  const _SongTile({
    required this.song,
    required this.index,
    required this.accentColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final playerController = Get.find<PlayerController>();
    final musicController = Get.find<MusicController>();
    return Obx(() {
      final isCurrentSong = playerController.currentSong.value?.trackId == song.trackId;

      return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: isCurrentSong
            ? LinearGradient(
                colors: [
                  accentColor.withValues(alpha: 0.2),
                  accentColor.withValues(alpha: 0.1),
                ],
              )
            : null,
        color: isCurrentSong
            ? null
            : (isDark ? const Color(0xFF1A1A24) : Colors.white),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isCurrentSong
                ? accentColor.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: isCurrentSong ? 20 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            try {
              final musicController = Get.find<MusicController>();
              final playerController = Get.find<PlayerController>();
              playerController.setPlaylist(musicController.songs, index);
              await playerController.playSong(song);
              Get.toNamed('/player');
            } catch (e) {
              Get.snackbar(
                'Error',
                'Failed to play song: ${song.trackName}',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Hero(
                  tag: 'artwork-${song.trackId}',
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: song.artworkUrl100.isEmpty
                          ? Container(
                              color: accentColor.withValues(alpha: 0.2),
                              child: Icon(
                                Icons.music_note_rounded,
                                color: accentColor,
                                size: 32,
                              ),
                            )
                          : Image.network(
                              song.artworkUrl100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: accentColor.withValues(alpha: 0.2),
                                    child: Icon(
                                      Icons.music_note_rounded,
                                      color: accentColor,
                                      size: 32,
                                    ),
                                  ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag: 'title-${song.trackId}',
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            song.trackName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isCurrentSong
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: isCurrentSong
                                  ? accentColor
                                  : (isDark
                                        ? Colors.white
                                        : const Color(0xFF1A1A24)),
                              letterSpacing: 0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        song.artistName,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white60 : Colors.black54,
                          letterSpacing: 0.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Obx(() {
                  final isFavorite = musicController.favorites
                      .any((fav) => fav.trackId == song.trackId);
                  return IconButton(
                    icon: Icon(
                      isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: isFavorite ? Colors.red : Colors.grey,
                    ),
                    onPressed: () => musicController.toggleFavorite(song),
                  );
                }),
                const SizedBox(width: 4),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentColor, accentColor.withValues(alpha: 0.8)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      isCurrentSong && playerController.isPlaying.value
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      try {
                        final musicController = Get.find<MusicController>();
                        final playerController = Get.find<PlayerController>();
                        playerController.setPlaylist(musicController.songs, index);
                        await playerController.playSong(song);
                      } catch (e) {
                        Get.snackbar(
                          'Error',
                          'Failed to play song: ${song.trackName}',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    });
  }
}

class _EmptySearchState extends StatelessWidget {
  final Color accentColor;
  final bool isDark;

  const _EmptySearchState({required this.accentColor, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (0.2 * value),
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: Icon(
                Icons.search_rounded,
                size: 80,
                color: accentColor.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Search for Music',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A1A24),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Discover millions of songs, artists, and albums',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoResultsState extends StatelessWidget {
  final Color accentColor;
  final bool isDark;
  final String searchQuery;

  const _NoResultsState({
    required this.accentColor,
    required this.isDark,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_off_rounded,
              size: 64,
              color: accentColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching for something else',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white60 : Colors.black45,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final Color accentColor;
  final bool isDark;

  const _ErrorState({
    required this.message,
    required this.onRetry,
    required this.accentColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: accentColor),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
