import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song_model.dart';

class StorageService {
  static const String _favoritesKey = 'favorites';

  Future<void> saveFavorites(List<SongModel> songs) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = songs.map((song) => song.toJson()).toList();
    await prefs.setString(_favoritesKey, json.encode(jsonList));
  }

  Future<List<SongModel>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_favoritesKey);
    if (jsonString == null) return [];
    
    final List jsonList = json.decode(jsonString);
    return jsonList.map((json) => SongModel.fromJson(json)).toList();
  }

  Future<void> addFavorite(SongModel song) async {
    final favorites = await getFavorites();
    if (!favorites.any((s) => s.trackId == song.trackId)) {
      favorites.add(song);
      await saveFavorites(favorites);
    }
  }

  Future<void> removeFavorite(int trackId) async {
    final favorites = await getFavorites();
    favorites.removeWhere((s) => s.trackId == trackId);
    await saveFavorites(favorites);
  }

  Future<bool> isFavorite(int trackId) async {
    final favorites = await getFavorites();
    return favorites.any((s) => s.trackId == trackId);
  }
}