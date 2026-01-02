import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/song_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class MusicController extends GetxController {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  final RxList<SongModel> songs = <SongModel>[].obs;
  final RxList<SongModel> favorites = <SongModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadTopSongs();
    loadFavorites();
  }

  Future<void> loadTopSongs() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      if (kDebugMode) {
        print('Starting to load top songs...');
      }
      final loadedSongs = await _apiService.getTopSongs();
      songs.value = loadedSongs;
      if (songs.isEmpty) {
        errorMessage.value =
            'No songs found. Please check your internet connection and try again.';
        if (kDebugMode) {
          print('No songs returned from API');
        }
      } else {
        if (kDebugMode) {
          print('Successfully loaded ${songs.length} songs');
        }
      }
    } catch (e) {
      final errorString = e.toString().toLowerCase();
      if (kDebugMode) {
        print('Error in loadTopSongs: $e');
        print('Error string: $errorString');
      }

      if (errorString.contains('timeout')) {
        errorMessage.value =
            'Request timed out. Please check your internet connection and try again.';
      } else if (errorString.contains('network') ||
          errorString.contains('socket')) {
        errorMessage.value =
            'Network error. Please check your internet connection.';
      } else if (errorString.contains('cors') ||
          errorString.contains('cross-origin')) {
        errorMessage.value =
            'Connection blocked. Please try refreshing the page or check your browser settings.';
      } else if (errorString.contains('failed')) {
        errorMessage.value =
            'Failed to load songs. Please try again or check your connection.';
      } else {
        errorMessage.value =
            'Unable to load songs. Please refresh the page and try again.';
      }
      songs.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchSongs(String query) async {
    if (query.isEmpty) {
      await loadTopSongs();
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      if (kDebugMode) {
        print('Starting search for: "$query"');
      }
      final loadedSongs = await _apiService.searchSongs(query);
      songs.value = loadedSongs;
      if (songs.isEmpty) {
        errorMessage.value =
            'No songs found for "$query". Try a different search term.';
        if (kDebugMode) {
          print('No songs returned from search');
        }
      } else {
        if (kDebugMode) {
          print(
            'Successfully loaded ${songs.length} songs for search: "$query"',
          );
        }
      }
    } catch (e) {
      final errorString = e.toString().toLowerCase();
      if (kDebugMode) {
        print('Error in searchSongs: $e');
        print('Error string: $errorString');
      }

      if (errorString.contains('timeout')) {
        errorMessage.value =
            'Search timed out. Please check your internet connection and try again.';
      } else if (errorString.contains('network') ||
          errorString.contains('socket')) {
        errorMessage.value =
            'Network error. Please check your internet connection.';
      } else if (errorString.contains('cors') ||
          errorString.contains('cross-origin')) {
        errorMessage.value =
            'Connection blocked. Please try refreshing the page or check your browser settings.';
      } else if (errorString.contains('failed')) {
        errorMessage.value =
            'Failed to search songs. Please try again or check your connection.';
      } else {
        errorMessage.value = 'Unable to search songs. Please try again.';
      }
      songs.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadFavorites() async {
    favorites.value = await _storageService.getFavorites();
  }

  Future<void> toggleFavorite(SongModel song) async {
    final isFav = await _storageService.isFavorite(song.trackId);
    if (isFav) {
      await _storageService.removeFavorite(song.trackId);
    } else {
      await _storageService.addFavorite(song);
    }
    await loadFavorites();
  }

  Future<bool> isFavorite(int trackId) async {
    return _storageService.isFavorite(trackId);
  }
}
