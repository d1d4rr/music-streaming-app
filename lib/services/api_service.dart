import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/song_model.dart';

class ApiService {
  static const String _baseUrl = 'https://itunes.apple.com';

  Future<List<SongModel>> searchSongs(String query) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final uri = Uri.parse(
        '$_baseUrl/search?term=$encodedQuery&media=music&entity=song&limit=50',
      );

      final client = http.Client();

      try {
        final response = await client
            .get(
              uri,
              headers: {
                'Accept': 'application/json',
                'User-Agent': 'Mozilla/5.0 (compatible; FlutterApp/1.0)',
              },
            )
            .timeout(
              const Duration(seconds: 30),
              onTimeout: () {
                throw Exception('Request timeout after 30 seconds');
              },
            );

        if (response.statusCode == 200) {
          final data = json.decode(response.body) as Map<String, dynamic>;
          final List? results = data['results'];
          if (results != null && results.isNotEmpty) {
            final songs = results
                .map((json) => SongModel.fromJson(json as Map<String, dynamic>))
                .where((song) => song.previewUrl != null && song.previewUrl!.isNotEmpty)
                .toList();
            if (kDebugMode) {
              print('Search returned ${songs.length} songs with preview URLs');
            }
            return songs;
          } else {
            if (kDebugMode) {
              print('Search returned no results');
            }
            return [];
          }
        } else {
          if (kDebugMode) {
            print(
              'API Error: ${response.statusCode} - ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}',
            );
          }
          throw Exception('API returned status code ${response.statusCode}');
        }
      } finally {
        client.close();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error searching songs: $e');
        print('Full error details: ${e.toString()}');
      }
      rethrow;
    }
  }

  Future<List<SongModel>> getTopSongs() async {
    final searchTerms = [
      'rock',
      'pop',
      'love',
      'dance',
      'jazz',
      'classical',
      'electronic',
    ];

    final List<SongModel> allSongs = [];
    final Set<int> seenTrackIds = {};
    final int songsPerTerm = 10;

    for (final term in searchTerms) {
      if (allSongs.length >= 50) {
        break;
      }
      
      for (int attempt = 0; attempt < 3; attempt++) {
        try {
          if (attempt > 0) {
            await Future.delayed(Duration(seconds: attempt));
            if (kDebugMode) {
              print('Retrying search for "$term" (attempt ${attempt + 1})');
            }
          }
          final songs = await searchSongs(term);
          if (songs.isNotEmpty) {
            int addedCount = 0;
            for (final song in songs) {
              if (!seenTrackIds.contains(song.trackId)) {
                allSongs.add(song);
                seenTrackIds.add(song.trackId);
                addedCount++;
                if (allSongs.length >= 50) {
                  break;
                }
                if (addedCount >= songsPerTerm) {
                  break;
                }
              }
            }
            if (kDebugMode) {
              print(
                'Successfully loaded $addedCount songs for term "$term" (total: ${allSongs.length})',
              );
            }
            if (allSongs.length >= 50) {
              break;
            }
          }
          break;
        } catch (e) {
          final errorMsg = e.toString().toLowerCase();
          if (kDebugMode) {
            print(
              'Failed to get songs for term "$term" (attempt ${attempt + 1}): $e',
            );
          }

          if (errorMsg.contains('cors') ||
              errorMsg.contains('cross-origin') ||
              errorMsg.contains('failed') && errorMsg.contains('network')) {
            if (kDebugMode) {
              print('Network/CORS error detected, moving to next term');
            }
            break;
          }

          if (attempt == 2) {
            continue;
          }
        }
      }
    }

    if (allSongs.isEmpty) {
      if (kDebugMode) {
        print('All search terms exhausted, returning empty list');
      }
      return [];
    }

    allSongs.shuffle();
    final result = allSongs.take(50).toList();
    
    if (kDebugMode) {
      print('Returning ${result.length} randomized songs from multiple genres');
    }
    
    return result;
  }
}
