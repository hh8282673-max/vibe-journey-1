import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'demo_songs.dart';
import 'providers.dart';
import 'widgets.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likedIds = ref.watch(likedProvider);
    final liked = demoSongs.where((s) => likedIds.contains(s.id)).toList();
    final recent = ref.watch(recentProvider);

    Widget list(List songs, Widget empty) => songs.isEmpty
        ? empty
        : ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              for (final s in songs) SongTile(song: s, queue: List.from(songs)),
            ],
          );

    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('Library',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              ),
            ),
            const TabBar(
                tabs: [Tab(text: 'Liked Songs'), Tab(text: 'Recently Played')]),
            Expanded(
              child: TabBarView(
                children: [
                  list(
                    liked,
                    const EmptyState(
                      icon: Icons.favorite_border_rounded,
                      title: 'No liked songs',
                      subtitle: 'Tap the heart on any song to save it here.',
                    ),
                  ),
                  list(
                    recent,
                    const EmptyState(
                      icon: Icons.history_rounded,
                      title: 'Nothing played yet',
                      subtitle: 'Songs you play will show up here.',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
