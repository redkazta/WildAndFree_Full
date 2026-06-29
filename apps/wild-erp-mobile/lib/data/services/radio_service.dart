import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

class RadioConfig {
  final int id;
  String zenoStreamUrl;
  String zenoEmbedUrl;
  bool isLive;
  String currentShow;
  String currentHost;
  String whatsapp;
  bool autoRadio;
  String autoRadioSpotifyPlaylist;
  String updatedAt;

  RadioConfig({
    required this.id,
    this.zenoStreamUrl = 'https://stream.zeno.fm/placeholder',
    this.zenoEmbedUrl = 'https://zeno.fm/embed/placeholder',
    this.isLive = false,
    this.currentShow = 'Wild Gvng Radio',
    this.currentHost = 'KAZTA',
    this.whatsapp = '+52 (871) 111-1111',
    this.autoRadio = false,
    this.autoRadioSpotifyPlaylist = '',
    this.updatedAt = '',
  });

  factory RadioConfig.fromJson(Map<String, dynamic> json) {
    return RadioConfig(
      id: json['id'] ?? 1,
      zenoStreamUrl: json['zeno_stream_url'] ?? 'https://stream.zeno.fm/placeholder',
      zenoEmbedUrl: json['zeno_embed_url'] ?? 'https://zeno.fm/embed/placeholder',
      isLive: json['is_live'] ?? false,
      currentShow: json['current_show'] ?? 'Wild Gvng Radio',
      currentHost: json['current_host'] ?? 'KAZTA',
      whatsapp: json['whatsapp'] ?? '+52 (871) 111-1111',
      autoRadio: json['auto_radio'] ?? false,
      autoRadioSpotifyPlaylist: json['auto_radio_spotify_playlist'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'zeno_stream_url': zenoStreamUrl,
      'zeno_embed_url': zenoEmbedUrl,
      'is_live': isLive,
      'current_show': currentShow,
      'current_host': currentHost,
      'whatsapp': whatsapp,
      'auto_radio': autoRadio,
      'auto_radio_spotify_playlist': autoRadioSpotifyPlaylist,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  String get modeLabel {
    if (isLive) return 'EN VIVO';
    if (autoRadio) return 'AUTO RADIO';
    return 'OFFLINE';
  }
}

class RadioAutoTrack {
  final int id;
  final String spotifyTrackUrl;
  final String spotifyEmbedUrl;
  final String? title;
  final String? artist;
  final String? coverUrl;
  final int sortOrder;
  final bool isActive;
  final String createdAt;

  RadioAutoTrack({
    required this.id,
    required this.spotifyTrackUrl,
    required this.spotifyEmbedUrl,
    this.title,
    this.artist,
    this.coverUrl,
    this.sortOrder = 0,
    this.isActive = true,
    this.createdAt = '',
  });

  factory RadioAutoTrack.fromJson(Map<String, dynamic> json) {
    return RadioAutoTrack(
      id: json['id'] ?? 0,
      spotifyTrackUrl: json['spotify_track_url'] ?? '',
      spotifyEmbedUrl: json['spotify_embed_url'] ?? '',
      title: json['title'],
      artist: json['artist'],
      coverUrl: json['cover_url'],
      sortOrder: json['sort_order'] ?? 0,
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'spotify_track_url': spotifyTrackUrl,
      'spotify_embed_url': spotifyEmbedUrl,
      'title': title,
      'artist': artist,
      'cover_url': coverUrl,
      'sort_order': sortOrder,
      'is_active': isActive,
    };
  }
}

class RadioEpisode {
  final String id;
  final String title;
  final String? description;
  final String host;
  final String audioUrl;
  final String? coverUrl;
  final String? duration;
  final String? category;
  final bool isPublished;
  final bool isLive;
  final String? liveUrl;
  final String? publishedAt;
  final String? createdAt;

  RadioEpisode({
    required this.id,
    required this.title,
    this.description,
    this.host = 'KAZTA',
    required this.audioUrl,
    this.coverUrl,
    this.duration,
    this.category = 'mix',
    this.isPublished = false,
    this.isLive = false,
    this.liveUrl,
    this.publishedAt,
    this.createdAt,
  });

  factory RadioEpisode.fromJson(Map<String, dynamic> json) {
    return RadioEpisode(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      host: json['host'] ?? 'KAZTA',
      audioUrl: json['audio_url'] ?? '',
      coverUrl: json['cover_url'],
      duration: json['duration'],
      category: json['category'] ?? 'mix',
      isPublished: json['is_published'] ?? false,
      isLive: json['is_live'] ?? false,
      liveUrl: json['live_url'],
      publishedAt: json['published_at'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toInsertJson(String userId) {
    return {
      'title': title,
      'description': description ?? '',
      'host': host,
      'audio_url': audioUrl,
      'cover_url': coverUrl,
      'duration': duration,
      'category': category ?? 'mix',
      'is_published': true,
      'is_live': false,
      'created_by': userId,
      'published_at': DateTime.now().toIso8601String(),
    };
  }
}

class RadioShow {
  final int id;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final String showName;
  final String host;
  final String? description;
  final bool isActive;

  RadioShow({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.showName,
    this.host = 'KAZTA',
    this.description,
    this.isActive = true,
  });

  factory RadioShow.fromJson(Map<String, dynamic> json) {
    return RadioShow(
      id: json['id'] ?? 0,
      dayOfWeek: json['day_of_week'] ?? 0,
      startTime: json['start_time']?.toString().substring(0, 5) ?? '00:00',
      endTime: json['end_time']?.toString().substring(0, 5) ?? '00:00',
      showName: json['show_name'] ?? '',
      host: json['host'] ?? 'KAZTA',
      description: json['description'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'show_name': showName,
      'host': host,
      'description': description,
      'is_active': isActive,
    };
  }

  static const dayNames = [
    'Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'
  ];
  String get dayName => dayNames[dayOfWeek];
}

class RadioService {
  static SupabaseClient get _client => SupabaseService.client;

  // ====== CONFIG ======
  static Future<RadioConfig> getConfig() async {
    try {
      final data = await _client
          .from('radio_config')
          .select('*')
          .limit(1)
          .single();
      return RadioConfig.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateConfig(RadioConfig config) async {
    try {
      await _client
          .from('radio_config')
          .update(config.toJson())
          .eq('id', 1);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> toggleLive(bool isLive) async {
    try {
      await _client
          .from('radio_config')
          .update({'is_live': isLive, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', 1);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> toggleAutoRadio(bool autoRadio) async {
    try {
      await _client
          .from('radio_config')
          .update({'auto_radio': autoRadio, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', 1);
    } catch (e) {
      rethrow;
    }
  }

  // ====== AUTO TRACKS ======
  static Future<List<RadioAutoTrack>> getAutoTracks() async {
    try {
      final data = await _client
          .from('radio_auto_tracks')
          .select('*')
          .order('sort_order', ascending: true)
          .order('created_at', ascending: false);
      return (data as List).map((json) => RadioAutoTrack.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> createAutoTrack(RadioAutoTrack track) async {
    try {
      await _client
          .from('radio_auto_tracks')
          .insert(track.toJson());
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateAutoTrack(int id, RadioAutoTrack track) async {
    try {
      await _client
          .from('radio_auto_tracks')
          .update(track.toJson())
          .eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteAutoTrack(int id) async {
    try {
      await _client
          .from('radio_auto_tracks')
          .delete()
          .eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  // ====== EPISODES ======
  static Future<List<RadioEpisode>> getEpisodes() async {
    try {
      final data = await _client
          .from('radio_episodes')
          .select('*')
          .order('created_at', ascending: false);
      return (data as List).map((json) => RadioEpisode.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<RadioEpisode> uploadEpisode({
    required String title,
    String? description,
    String host = 'KAZTA',
    String? duration,
    String category = 'mix',
    required String audioFilePath,
    String? coverFilePath,
    required String userId,
  }) async {
    try {
      // Upload audio file
      final audioBytes = await _client.storage.from('radio-audio').uploadBinary(
        'episodes/${DateTime.now().millisecondsSinceEpoch}-${audioFilePath.split('/').last}',
        await _readFileBytes(audioFilePath),
        fileOptions: const FileOptions(contentType: 'audio/mpeg'),
      );

      if (audioBytes.error != null) throw Exception(audioBytes.error!.message);

      final audioUrl = _client.storage.from('radio-audio').getPublicUrl(
        audioBytes.data!.path,
      );

      // Upload cover if provided
      String? coverUrl;
      if (coverFilePath != null) {
        final coverBytes = await _client.storage.from('radio-audio').uploadBinary(
          'covers/${DateTime.now().millisecondsSinceEpoch}-${coverFilePath.split('/').last}',
          await _readFileBytes(coverFilePath),
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
        if (coverBytes.error == null) {
          coverUrl = _client.storage.from('radio-audio').getPublicUrl(
            coverBytes.data!.path,
          );
        }
      }

      // Create record
      final episode = RadioEpisode(
        id: '',
        title: title,
        description: description,
        host: host,
        audioUrl: audioUrl,
        coverUrl: coverUrl,
        duration: duration,
        category: category,
        isPublished: true,
      );

      final result = await _client
          .from('radio_episodes')
          .insert(episode.toInsertJson(userId))
          .select()
          .single();

      return RadioEpisode.fromJson(result);
    } catch (e) {
      rethrow;
    }
  }

  static Future<RadioEpisode> updateEpisode(String id, Map<String, dynamic> updates) async {
    try {
      final data = await _client
          .from('radio_episodes')
          .update({
            ...updates,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();
      return RadioEpisode.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteEpisode(String id) async {
    try {
      await _client
          .from('radio_episodes')
          .delete()
          .eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  // ====== SCHEDULE ======
  static Future<List<RadioShow>> getSchedule() async {
    try {
      final data = await _client
          .from('radio_schedule')
          .select('*')
          .order('day_of_week', ascending: true)
          .order('start_time', ascending: true);
      return (data as List).map((json) => RadioShow.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> createShow(RadioShow show) async {
    try {
      await _client
          .from('radio_schedule')
          .insert(show.toJson());
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateShow(int id, RadioShow show) async {
    try {
      await _client
          .from('radio_schedule')
          .update(show.toJson())
          .eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteShow(int id) async {
    try {
      await _client
          .from('radio_schedule')
          .delete()
          .eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  static Future<Uint8List> _readFileBytes(String path) async {
    final file = io.File(path);
    return await file.readAsBytes();
  }
}
