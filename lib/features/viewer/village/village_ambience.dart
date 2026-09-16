import 'dart:async';

import 'package:just_audio/just_audio.dart';

import 'day_night.dart';
import 'village_season.dart';

/// Owns the Village's quiet soundscape.
///
/// The base recording follows the part of the village being viewed. Monsoon
/// rain is a second, softer layer so it does not erase the life underneath it.
/// The stronger forest recording is deliberately opt-in and never autoplays.
class VillageAmbienceController {
  final AudioPlayer _basePlayer = AudioPlayer();
  final AudioPlayer _weatherPlayer = AudioPlayer();
  final AudioPlayer _effectPlayer = AudioPlayer();

  String? _baseAsset;
  String? _weatherAsset;
  int _request = 0;
  bool _disposed = false;

  static const _birds = 'assets/audio/village/birds.mp3';
  static const _nearbyLife = 'assets/audio/village/nearby_life.mp3';
  static const _quietNature = 'assets/audio/village/quiet_nature.mp3';
  static const _rain = 'assets/audio/village/rain.mp3';
  static const _forestTree = 'assets/audio/village/forest_tree.mp3';

  Future<void> update({
    required String area,
    required VillageSeason season,
    required VillagePhase phase,
    required bool enabled,
  }) async {
    if (_disposed) return;
    final request = ++_request;

    if (!enabled) {
      await pause();
      return;
    }

    final night = phase == VillagePhase.night;
    final base = _baseFor(area, night: night);
    await _switchLoop(
      player: _basePlayer,
      currentAsset: _baseAsset,
      nextAsset: base,
      volume: night ? 0.09 : 0.14,
      request: request,
      remember: (asset) => _baseAsset = asset,
    );
    if (_disposed || request != _request) return;

    if (season == VillageSeason.monsoon) {
      await _switchLoop(
        player: _weatherPlayer,
        currentAsset: _weatherAsset,
        nextAsset: _rain,
        volume: night ? 0.055 : 0.075,
        request: request,
        remember: (asset) => _weatherAsset = asset,
      );
    } else {
      await _weatherPlayer.stop();
      _weatherAsset = null;
    }
  }

  String _baseFor(String area, {required bool night}) {
    if (night) return _quietNature;
    return switch (area) {
      'homestead' => _nearbyLife,
      'heart' => _birds,
      'fields' => _quietNature,
      'viewpoint' => _birds,
      _ => _quietNature,
    };
  }

  Future<void> _switchLoop({
    required AudioPlayer player,
    required String? currentAsset,
    required String nextAsset,
    required double volume,
    required int request,
    required void Function(String) remember,
  }) async {
    try {
      if (currentAsset != nextAsset) {
        await player.stop();
        await player.setAsset(nextAsset);
        if (_disposed || request != _request) return;
        await player.setLoopMode(LoopMode.one);
        remember(nextAsset);
      }
      await player.setVolume(volume);
      if (!player.playing) unawaited(player.play());
    } catch (_) {
      // Ambience is decorative. The village must remain fully usable silently.
    }
  }

  /// The fallen-tree recording is intentionally tied to a visible discovery.
  Future<void> playForestDiscovery() async {
    if (_disposed) return;
    try {
      await _effectPlayer.stop();
      await _effectPlayer.setAsset(_forestTree);
      await _effectPlayer.setVolume(0.16);
      unawaited(_effectPlayer.play());
    } catch (_) {
      // The discovery still reveals its story if audio is unavailable.
    }
  }

  Future<void> pause() async {
    if (_disposed) return;
    ++_request;
    await Future.wait([
      _basePlayer.pause(),
      _weatherPlayer.pause(),
      _effectPlayer.stop(),
    ]);
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    ++_request;
    unawaited(_basePlayer.dispose());
    unawaited(_weatherPlayer.dispose());
    unawaited(_effectPlayer.dispose());
  }
}
