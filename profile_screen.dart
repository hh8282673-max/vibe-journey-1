import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';
import 'theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liked = ref.watch(likedProvider).length;
    final played = ref.watch(recentProvider).length;

    Widget stat(String n, String label) => Expanded(
          child: Column(children: [
            Text(n,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            Text(label, style: const TextStyle(color: VC.muted, fontSize: 12)),
          ]),
        );

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 12),
          const Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: VC.high,
              child: Icon(Icons.person_rounded, size: 40, color: VC.muted),
            ),
          ),
          const SizedBox(height: 12),
          const Center(
              child: Text('Guest',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
          const Center(
              child: Text('Sign in arrives with Supabase auth',
                  style: TextStyle(color: VC.muted, fontSize: 12))),
          const SizedBox(height: 24),
          Row(children: [stat('$liked', 'Liked'), stat('$played', 'Played')]),
          const SizedBox(height: 24),
          for (final item in [
            'Appearance',
            'Audio quality',
            'Notifications',
            'About'
          ])
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(item),
              trailing:
                  const Icon(Icons.chevron_right_rounded, color: VC.muted),
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming in a later phase'))),
            ),
        ],
      ),
    );
  }
}
