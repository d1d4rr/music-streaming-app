class SongModel {
  final int trackId;
  final String trackName;
  final String artistName;
  final String collectionName;
  final String artworkUrl100;
  final String? previewUrl;
  final int trackTimeMillis;

  SongModel({
    required this.trackId,
    required this.trackName,
    required this.artistName,
    required this.collectionName,
    required this.artworkUrl100,
    this.previewUrl,
    required this.trackTimeMillis,
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      trackId: json['trackId'] ?? 0,
      trackName: json['trackName'] ?? 'Unknown',
      artistName: json['artistName'] ?? 'Unknown Artist',
      collectionName: json['collectionName'] ?? 'Unknown Album',
      artworkUrl100: json['artworkUrl100'] ?? '',
      previewUrl: json['previewUrl'],
      trackTimeMillis: json['trackTimeMillis'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trackId': trackId,
      'trackName': trackName,
      'artistName': artistName,
      'collectionName': collectionName,
      'artworkUrl100': artworkUrl100,
      'previewUrl': previewUrl,
      'trackTimeMillis': trackTimeMillis,
    };
  }

  String get artworkUrl600 {
    if (artworkUrl100.isEmpty) return '';
    return artworkUrl100.replaceAll('100x100', '600x600');
  }
}
