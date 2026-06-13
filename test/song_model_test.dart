import 'package:flutter_test/flutter_test.dart';
import 'package:music_streaming_app/models/song_model.dart';

void main() {
  group('SongModel Tests', () {
    test('fromJson should parse correctly', () {
      final json = {
        'trackId': 12345,
        'trackName': 'Test Song',
        'artistName': 'Test Artist',
        'collectionName': 'Test Album',
        'artworkUrl100': 'https://example.com/100x100.jpg',
        'previewUrl': 'https://example.com/preview.mp3',
        'trackTimeMillis': 180000,
      };

      final song = SongModel.fromJson(json);

      expect(song.trackId, 12345);
      expect(song.trackName, 'Test Song');
      expect(song.artistName, 'Test Artist');
      expect(song.collectionName, 'Test Album');
      expect(song.artworkUrl100, 'https://example.com/100x100.jpg');
      expect(song.previewUrl, 'https://example.com/preview.mp3');
      expect(song.trackTimeMillis, 180000);
      expect(song.artworkUrl600, 'https://example.com/600x600.jpg');
    });

    test('toJson should serialize correctly', () {
      final song = SongModel(
        trackId: 12345,
        trackName: 'Test Song',
        artistName: 'Test Artist',
        collectionName: 'Test Album',
        artworkUrl100: 'https://example.com/100x100.jpg',
        previewUrl: 'https://example.com/preview.mp3',
        trackTimeMillis: 180000,
      );

      final json = song.toJson();

      expect(json['trackId'], 12345);
      expect(json['trackName'], 'Test Song');
      expect(json['artistName'], 'Test Artist');
      expect(json['collectionName'], 'Test Album');
      expect(json['artworkUrl100'], 'https://example.com/100x100.jpg');
      expect(json['previewUrl'], 'https://example.com/preview.mp3');
      expect(json['trackTimeMillis'], 180000);
    });

    test('artworkUrl600 handles empty url', () {
      final song = SongModel(
        trackId: 123,
        trackName: 'Test',
        artistName: 'Artist',
        collectionName: 'Album',
        artworkUrl100: '',
        trackTimeMillis: 0,
      );

      expect(song.artworkUrl600, '');
    });
  });
}
