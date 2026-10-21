import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'song.dart';

class VibePlayerState {
  final Song? current;
  final List<Song> queue;
  final bool playing;
  final bool loading;
  final bool shuffle;
  final bool repeatOne;
  final Duration position;
  final Duration duration;
  final String? error;

  const VibePlayerState({
    this.current,
    this.queue = const [],
    this.playing = false,
    this.loading = false,
    this.shuffle = false,
    this.repeatOne = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.error,
  });

  VibePlayerState copyWith({
    Song? current,
    List<Song>? queue,
    bool? playing,
    bool? loading,
    bool? shuffle,
    bool? repeatOne,
    Duration? position,
    Duration? duration,
    String? error,
    bool clearError = false,
  }) {
    return VibePlayerState(
      current: current ?? this.current,
      queue: queue ?? this.queue,
      playing: playing ?? this.playing,
      loading: loading ?? this.loading,
      shuffle: shuffle ?? this.shuffle,
      repeatOne: repeatOne ?? this.repeatOne,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class PlayerController extends Notifier<VibePlayerState> {
  final AudioPlayer _player = AudioPlayer();

  @override
  VibePlayerState build() {
    final subs = <StreamSubscription>[
      _player.playerStateStream.listen((s) {
        state = state.copyWith(
          playing: s.playing,
          loading: s.processingState == ProcessingState.loading ||
              s.processingState == ProcessingState.buffering,
        );
        if (s.processingState == ProcessingState.completed) _onComplete();
      }),
      _player.positionStream.listen((p) => state = state.copyWith(position: p)),
      _player.durationStream
          .listen((d) => state = state.copyWith(duration: d ?? Duration.zero)),
    ];
    ref.onDispose(() {
      for (final s in subs) {
        s.cancel();
      }
      _player.dispose();
    });
    return const VibePlayerState();
  }

  Future<void> play(Song song, {List<Song>? queue}) async {
    state = state.copyWith(
      current: song,
      queue: queue ?? state.queue,
      position: Duration.zero,
      duration: Duration.zero,
      clearError: true,
    );
    ref.read(recentProvider.notifier).add(song);
    try {
      await _player.setUrl(song.audioUrl);
      unawaited(_player.play());
    } catch (_) {
      state = state.copyWith(
        playing: false,
        loading: false,
        error: 'Could not play this track. Check your internet connection.',
      );
    }
  }

  void toggle() {
    if (state.current == null) return;
    if (state.playing) {
      _player.pause();
    } else {
      unawaited(_player.play());
    }
  }

  void seek(Duration d) => _player.seek(d);

  void next() {
    final q = state.queue;
    final cur = state.current;
    if (q.isEmpty || cur == null) return;
    final i = q.indexWhere((s) => s.id == cur.id);
    Song n;
    if (state.shuffle && q.length > 1) {
      final others = q.where((s) => s.id != cur.id).toList();
      n = others[Random().nextInt(others.length)];
    } else {
      n = q[(i + 1) % q.length];
    }
    play(n);
  }

  void previous() {
    final q = state.queue;
    final cur = state.current;
    if (q.isEmpty || cur == null) return;
    if (state.position > const Duration(seconds: 3)) {
      _player.seek(Duration.zero);
      return;
    }
    final i = q.indexWhere((s) => s.id == cur.id);
    play(q[(i - 1 + q.length) % q.length]);
  }

  void toggleShuffle() => state = state.copyWith(shuffle: !state.shuffle);
  void toggleRepeat() => state = state.copyWith(repeatOne: !state.repeatOne);

  void _onComplete() {
    if (state.repeatOne) {
      _player.seek(Duration.zero);
      unawaited(_player.play());
    } else {
      next();
    }
  }
}

final playerProvider =
    NotifierProvider<PlayerController, VibePlayerState>(PlayerController.new);

// In-memory for now. Move to Supabase favorites table in Phase 2/4.
class LikedController extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void toggle(String id) {
    final s = {...state};
    if (!s.remove(id)) s.add(id);
    state = s;
  }
}

final likedProvider =
    NotifierProvider<LikedController, Set<String>>(LikedController.new);

class RecentController extends Notifier<List<Song>> {
  @override
  List<Song> build() => [];

  void add(Song s) {
    state = [s, ...state.where((x) => x.id != s.id)].take(20).toList();
  }
}

final recentProvider =
    NotifierProvider<RecentController, List<Song>>(RecentController.new);

final filterProvider = StateProvider<String?>((ref) => null);
