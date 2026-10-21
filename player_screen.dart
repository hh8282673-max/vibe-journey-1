import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';
import 'theme.dart';
import 'widgets.dart';

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(playerProvider);
    final ctrl = ref.read(playerProvider.notifier);
    final song = p.current;
    if (song == null) return const Scaffold(body: SizedBox.shrink());

    final liked = ref.watch(likedProvider).contains(song.id);
    final width = MediaQuery.of(context).size.width;
    final art = (width - 64).clamp(180.0, 320.0).toDouble();
    final maxMs = p.duration.inMilliseconds.toDouble();
    final hasDuration = maxMs > 0;
    final value = hasDuration
        ? p.position.inMilliseconds.toDouble().clamp(0.0, maxMs).toDouble()
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Now Playing', style: TextStyle(fontSize: 14)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Cover(song: song, size: art),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w800)),
                        Text(song.artist,
                            style: const TextStyle(color: VC.muted)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(liked ? Icons.favorite : Icons.favorite_border,
                        color: liked ? VC.pink : VC.muted),
                    onPressed: () =>
                        ref.read(likedProvider.notifier).toggle(song.id),
                  ),
                ],
              ),
              if (p.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(p.error!,
                      style: const TextStyle(
                          color: Colors.redAccent, fontSize: 12)),
                ),
              const SizedBox(height: 12),
              Slider(
                value: value,
                min: 0,
                max: hasDuration ? maxMs : 1,
                onChanged: hasDuration
                    ? (v) => ctrl.seek(Duration(milliseconds: v.toInt()))
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(fmt(p.position),
                        style: const TextStyle(color: VC.muted, fontSize: 12)),
                    Text(fmt(p.duration),
                        style: const TextStyle(color: VC.muted, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.shuffle_rounded,
                        color: p.shuffle ? VC.glow : VC.muted),
                    onPressed: ctrl.toggleShuffle,
                  ),
                  IconButton(
                    iconSize: 38,
                    icon: const Icon(Icons.skip_previous_rounded),
                    onPressed: ctrl.previous,
                  ),
                  p.loading
                      ? const SizedBox(
                          width: 64,
                          height: 64,
                          child: Padding(
                              padding: EdgeInsets.all(18),
                              child: CircularProgressIndicator(strokeWidth: 3)),
                        )
                      : IconButton.filled(
                          iconSize: 40,
                          style:
                              IconButton.styleFrom(backgroundColor: VC.primary),
                          icon: Icon(p.playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded),
                          onPressed: ctrl.toggle,
                        ),
                  IconButton(
                    iconSize: 38,
                    icon: const Icon(Icons.skip_next_rounded),
                    onPressed: ctrl.next,
                  ),
                  IconButton(
                    icon: Icon(Icons.repeat_one_rounded,
                        color: p.repeatOne ? VC.glow : VC.muted),
                    onPressed: ctrl.toggleRepeat,
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
