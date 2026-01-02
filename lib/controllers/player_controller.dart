import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import '../models/song_model.dart';

class PlayerController extends GetxController {
  final AudioPlayer _audioPlayer = AudioPlayer();

  final Rx<SongModel?> currentSong = Rx<SongModel?>(null);
  final RxList<SongModel> playlist = <SongModel>[].obs;
  final RxInt currentIndex = 0.obs;
  final RxBool isPlaying = false.obs;
  final Rx<Duration> duration = Duration.zero.obs;
  final Rx<Duration> position = Duration.zero.obs;
  final RxDouble currentVolume = 1.0.obs;
  final RxDouble audioQualityMultiplier = 1.0.obs;

  final RxString repeatMode = 'Off'.obs;
  final RxBool shuffleEnabled = false.obs;
  final RxList<int> shuffleHistory = <int>[].obs;
  final RxList<int> shuffleRemaining = <int>[].obs;

  @override
  void onInit() {
    super.onInit();
    _audioPlayer.onDurationChanged.listen((d) {
      duration.value = d;
    });

    _audioPlayer.onPositionChanged.listen((p) {
      position.value = p;
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      isPlaying.value = false;
      position.value = Duration.zero;
      duration.value = Duration.zero;

      if (repeatMode.value == 'One' && currentSong.value != null) {
        playSong(currentSong.value!, forcePlay: true);
      } else if (repeatMode.value == 'All' && playlist.isNotEmpty) {
        playNext();
      }
    });
  }

  void initializeFromSettings(
    String repeat,
    bool shuffle,
    double qualityMultiplier,
  ) {
    repeatMode.value = repeat;
    shuffleEnabled.value = shuffle;
    audioQualityMultiplier.value = qualityMultiplier;
    if (isPlaying.value) {
      final effectiveVolume =
          currentVolume.value * audioQualityMultiplier.value;
      _audioPlayer.setVolume(effectiveVolume);
    }
  }

  void setPlaylist(List<SongModel> songs, int startIndex) {
    playlist.value = List<SongModel>.from(
      songs,
    );
    currentIndex.value = startIndex;
    shuffleHistory.clear();
    shuffleRemaining.value = List.generate(songs.length, (index) => index);
    if (shuffleEnabled.value && shuffleRemaining.isNotEmpty) {
      shuffleRemaining.remove(startIndex);
      shuffleHistory.add(startIndex);
    }
  }

  Future<void> playSong(SongModel song, {bool forcePlay = false}) async {
    if (song.previewUrl == null || song.previewUrl!.isEmpty) {
      return;
    }

    if (!forcePlay &&
        currentSong.value?.trackId == song.trackId &&
        isPlaying.value) {
      await pause();
      return;
    }

    try {
      currentSong.value = song;

      if (playlist.isNotEmpty) {
        final index = playlist.indexWhere((s) => s.trackId == song.trackId);
        if (index != -1) {
          currentIndex.value = index;
          if (shuffleEnabled.value) {
            shuffleRemaining.remove(index);
            if (!shuffleHistory.contains(index)) {
              shuffleHistory.add(index);
            }
          }
        }
      }

      final effectiveVolume =
          currentVolume.value * audioQualityMultiplier.value;
      await _audioPlayer.setVolume(effectiveVolume);
      await _audioPlayer.play(UrlSource(song.previewUrl!));
      isPlaying.value = true;
    } catch (e) {
      isPlaying.value = false;
      rethrow;
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
    isPlaying.value = false;
  }

  Future<void> resume() async {
    if (currentSong.value == null ||
        currentSong.value!.previewUrl == null ||
        currentSong.value!.previewUrl!.isEmpty) {
      return;
    }

    final hasFinished =
        (duration.value.inSeconds > 0 && position.value >= duration.value) ||
        (duration.value.inSeconds == 0 &&
            position.value.inSeconds == 0 &&
            !isPlaying.value);

    if (hasFinished) {
      await _audioPlayer.stop();
      position.value = Duration.zero;
      duration.value = Duration.zero;
      final effectiveVolume =
          currentVolume.value * audioQualityMultiplier.value;
      await _audioPlayer.setVolume(effectiveVolume);
      await _audioPlayer.play(UrlSource(currentSong.value!.previewUrl!));
      isPlaying.value = true;
      return;
    }

    try {
      final state = _audioPlayer.state;
      if (state == PlayerState.stopped || state == PlayerState.completed) {
        await _audioPlayer.stop();
        position.value = Duration.zero;
        duration.value = Duration.zero;
        final effectiveVolume =
            currentVolume.value * audioQualityMultiplier.value;
        await _audioPlayer.setVolume(effectiveVolume);
        await _audioPlayer.play(UrlSource(currentSong.value!.previewUrl!));
        isPlaying.value = true;
      } else {
        await _audioPlayer.resume();
        isPlaying.value = true;
      }
    } catch (e) {
      await _audioPlayer.stop();
      position.value = Duration.zero;
      duration.value = Duration.zero;
      final effectiveVolume =
          currentVolume.value * audioQualityMultiplier.value;
      await _audioPlayer.setVolume(effectiveVolume);
      await _audioPlayer.play(UrlSource(currentSong.value!.previewUrl!));
      isPlaying.value = true;
    }
  }

  Future<void> seek(Duration pos) async {
    await _audioPlayer.seek(pos);
  }

  Future<void> setVolume(double volume) async {
    currentVolume.value = volume.clamp(0.0, 1.0);
    final effectiveVolume = currentVolume.value * audioQualityMultiplier.value;
    await _audioPlayer.setVolume(effectiveVolume);
  }

  Future<void> playNext() async {
    if (playlist.isEmpty) return;

    int attempts = 0;
    const maxAttempts = 100;

    while (attempts < maxAttempts) {
      if (shuffleEnabled.value) {
        if (shuffleRemaining.isEmpty) {
          shuffleRemaining.value = List.generate(
            playlist.length,
            (index) => index,
          );
          shuffleRemaining.remove(currentIndex.value);
          shuffleHistory.value = [currentIndex.value];
        }

        if (shuffleRemaining.isNotEmpty) {
          final randomIndex = Random().nextInt(shuffleRemaining.length);
          currentIndex.value = shuffleRemaining[randomIndex];
        } else {
          currentIndex.value = Random().nextInt(playlist.length);
        }
      } else {
        currentIndex.value = (currentIndex.value + 1) % playlist.length;
      }

      final nextSong = playlist[currentIndex.value];
      if (nextSong.previewUrl != null && nextSong.previewUrl!.isNotEmpty) {
        await playSong(nextSong);
        return;
      }
      attempts++;
    }
  }

  void setAudioQualityMultiplier(double multiplier) {
    audioQualityMultiplier.value = multiplier.clamp(0.6, 1.0);
    if (isPlaying.value) {
      final effectiveVolume =
          currentVolume.value * audioQualityMultiplier.value;
      _audioPlayer.setVolume(effectiveVolume);
    }
  }

  Future<void> playPrevious() async {
    if (playlist.isEmpty) return;

    int attempts = 0;
    const maxAttempts = 100;

    while (attempts < maxAttempts) {
      if (shuffleEnabled.value) {
        if (shuffleHistory.length > 1) {
          shuffleHistory.removeLast();
          final previousIndex = shuffleHistory.last;
          currentIndex.value = previousIndex;
          if (!shuffleRemaining.contains(previousIndex)) {
            shuffleRemaining.add(previousIndex);
          }
        } else {
          currentIndex.value =
              (currentIndex.value - 1 + playlist.length) % playlist.length;
        }
      } else {
        currentIndex.value =
            (currentIndex.value - 1 + playlist.length) % playlist.length;
      }

      final previousSong = playlist[currentIndex.value];
      if (previousSong.previewUrl != null &&
          previousSong.previewUrl!.isNotEmpty) {
        await playSong(previousSong);
        return;
      }
      attempts++;
    }
  }

  void setRepeatMode(String mode) {
    repeatMode.value = mode;
  }

  void setShuffle(bool enabled) {
    shuffleEnabled.value = enabled;
    if (enabled) {
      if (playlist.isNotEmpty) {
        shuffleRemaining.value = List.generate(
          playlist.length,
          (index) => index,
        );
        if (currentIndex.value < playlist.length) {
          shuffleRemaining.remove(currentIndex.value);
          shuffleHistory.value = [currentIndex.value];
        }
      }
    } else {
      shuffleHistory.clear();
      shuffleRemaining.clear();
    }
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    currentSong.value = null;
    isPlaying.value = false;
    position.value = Duration.zero;
    duration.value = Duration.zero;
    currentIndex.value = 0;
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }
}
