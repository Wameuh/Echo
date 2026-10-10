import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../data/models.dart';

abstract interface class AudioPlayback {
  bool get playing;
  bool get completed;
  Duration get position;
  Duration? get duration;
  int? get currentIndex;
  List<Stream<Object?>> get changeStreams;

  Future<void> load(List<String> assetPaths);
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position, {int? index});
  Future<void> stop();
  Future<void> dispose();
}

class JustAudioPlayback implements AudioPlayback {
  JustAudioPlayback({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  final AudioPlayer _player;

  @override
  bool get playing => _player.playing;

  @override
  bool get completed => _player.processingState == ProcessingState.completed;

  @override
  Duration get position => _player.position;

  @override
  Duration? get duration => _player.duration;

  @override
  int? get currentIndex => _player.currentIndex;

  @override
  List<Stream<Object?>> get changeStreams => [
    _player.playerStateStream,
    _player.positionStream,
    _player.durationStream,
    _player.currentIndexStream,
  ];

  @override
  Future<void> load(List<String> assetPaths) async {
    await _player.setAudioSources(
      assetPaths.map(AudioSource.asset).toList(growable: false),
      initialIndex: 0,
      initialPosition: Duration.zero,
    );
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position, {int? index}) =>
      _player.seek(position, index: index);

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> dispose() => _player.dispose();
}

class AudioController extends ChangeNotifier {
  AudioController({AudioPlayback? playback})
    : _playback = playback ?? JustAudioPlayback() {
    for (final stream in _playback.changeStreams) {
      _subscriptions.add(stream.listen((_) => notifyListeners()));
    }
  }

  final AudioPlayback _playback;
  final List<StreamSubscription<Object?>> _subscriptions = [];
  List<LessonAudio> _loadedAudio = const [];
  Future<void>? _pendingLoad;
  List<String> _pendingAssetPaths = const [];

  bool get isPlaying => _playback.playing;
  bool get completed => _playback.completed;
  Duration get position {
    if (_loadedAudio.isEmpty) return Duration.zero;
    final currentIndex = (_playback.currentIndex ?? 0).clamp(
      0,
      _loadedAudio.length - 1,
    );
    final previous = _loadedAudio
        .take(currentIndex)
        .fold(Duration.zero, (total, audio) => total + audio.duration);
    return previous + _playback.position;
  }

  Duration get duration => _loadedAudio.fold(
    Duration.zero,
    (total, audio) => total + audio.duration,
  );

  bool isActive(List<LessonAudio> audio) => listEquals(
    _loadedAudio.map((item) => item.assetPath).toList(growable: false),
    audio.map((item) => item.assetPath).toList(growable: false),
  );

  bool isLoading(List<LessonAudio> audio) => listEquals(
    _pendingAssetPaths,
    audio.map((item) => item.assetPath).toList(growable: false),
  );

  Future<void> _load(List<LessonAudio> audio) async {
    if (audio.isEmpty) {
      throw ArgumentError.value(
        audio,
        'audio',
        'La liste ne peut pas être vide.',
      );
    }
    await _playback.stop();
    await _playback.load(
      audio.map((item) => item.assetPath).toList(growable: false),
    );
    _loadedAudio = List.unmodifiable(audio);
    notifyListeners();
  }

  Future<void> _ensureLoaded(List<LessonAudio> audio) async {
    if (isActive(audio)) return;
    final paths = audio.map((item) => item.assetPath).toList(growable: false);
    if (listEquals(_pendingAssetPaths, paths) && _pendingLoad != null) {
      await _pendingLoad;
      return;
    }

    final previous = _pendingLoad;
    late final Future<void> pending;
    pending = () async {
      if (previous != null) {
        try {
          await previous;
        } catch (_) {
          // A failed preload must not prevent a later explicit request.
        }
      }
      if (!isActive(audio)) await _load(audio);
    }();
    _pendingAssetPaths = List.unmodifiable(paths);
    _pendingLoad = pending;
    notifyListeners();
    try {
      await pending;
    } finally {
      if (identical(_pendingLoad, pending)) {
        _pendingLoad = null;
        _pendingAssetPaths = const [];
        notifyListeners();
      }
    }
  }

  Future<void> preload(List<LessonAudio> audio) => _ensureLoaded(audio);

  Future<void> toggle(List<LessonAudio> audio) async {
    final active = isActive(audio);
    if (active && _playback.completed) {
      await _load(audio);
    } else if (active && _playback.playing) {
      await pause();
      return;
    } else if (!active) {
      await _ensureLoaded(audio);
    }
    await _playback.play();
  }

  Future<void> play(List<LessonAudio> audio) async {
    await _load(audio);
    await _playback.play();
  }

  Future<void> pause() => _playback.pause();

  Future<void> seek(Duration position) async {
    if (_loadedAudio.isEmpty) return;
    final bounded = position < Duration.zero
        ? Duration.zero
        : position > duration
        ? duration
        : position;
    var remaining = bounded;
    for (var index = 0; index < _loadedAudio.length; index++) {
      final itemDuration = _loadedAudio[index].duration;
      final isLast = index == _loadedAudio.length - 1;
      if (remaining < itemDuration || isLast) {
        final localPosition = remaining > itemDuration
            ? itemDuration
            : remaining;
        await _playback.seek(localPosition, index: index);
        return;
      }
      remaining -= itemDuration;
    }
  }

  Future<void> stop() async {
    await _playback.stop();
    notifyListeners();
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _playback.dispose();
    super.dispose();
  }
}
