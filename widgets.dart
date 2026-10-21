import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'song.dart';
import 'providers.dart';
import 'theme.dart';

String fmt(Duration d) =>
    '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

class Cover extends StatelessWidget {
  final Song song;
  final double size;
  const Cover({super.key, required this.song, required this.size});

  @override
  Widget build(BuildContext context) {
    final h =
        song.id.codeUnits.fold<int>(0, (a, b) => (a * 31 + b) % 360).toDouble();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            HSLColor.fromAHSL(1, h, 0.6, 0.45).toColor(),
            HSLColor.fromAHSL(1, (h + 60) % 360, 0.6, 0.25).toColor(),
          ],
        ),
      ),
      child: Icon(Icons.music_note_rounded,
          color: Colors.white70, size: size * 0.4),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const EmptyState(
      {super.key,
      required this.icon,
      required this.title,
      required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: VC.muted),
            const SizedBox(height: 12),
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: VC.muted, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class SongTile extends ConsumerWidget {
  final Song song;
  final List<Song> queue;
  const SongTile({super.key, required this.song, required this.queue});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liked = ref.watch(likedProvider).contains(song.id);
    final currentId = ref.watch(playerProvider.select((p) => p.current?.id));
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Cover(song: song, size: 52),
      title: Text(song.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontWeight: FontWeight.w600,
              color: currentId == song.id ? VC.glow : VC.text)),
      subtitle: Text('${song.artist} • ${song.era} • ${song.mood}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: VC.muted, fontSize: 12)),
      trailing: IconButton(
        icon: Icon(liked ? Icons.favorite : Icons.favorite_border,
            color: liked ? VC.pink : VC.muted),
        onPressed: () => ref.read(likedProvider.notifier).toggle(song.id),
      ),
      onTap: () => ref.read(playerProvider.notifier).play(song, queue: queue),
    );
  }
}
