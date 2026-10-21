import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'demo_songs.dart';
import 'song.dart';
import 'theme.dart';
import 'widgets.dart';

class ChatMsg {
  final String text;
  final bool isUser;
  final List<Song> songs;
  const ChatMsg(this.text, this.isUser, [this.songs = const []]);
}

// Simple LOCAL keyword logic. Replace with a Supabase Edge Function + real AI later.
ChatMsg botReply(String input) {
  final t = input.toLowerCase();
  if (RegExp(r'\b(hi|hello|hey)\b').hasMatch(t)) {
    return const ChatMsg("Hey! 👋 How's your day going?", false);
  }
  const moodWords = {
    'sad': 'Sad',
    'cry': 'Sad',
    'bad': 'Chill',
    'tired': 'Chill',
    'stress': 'Chill',
    'chill': 'Chill',
    'relax': 'Chill',
    'calm': 'Chill',
    'gym': 'Workout',
    'workout': 'Workout',
    'energ': 'Workout',
    'study': 'Focus',
    'focus': 'Focus',
    'party': 'Party',
    'dance': 'Party',
    'sleep': 'Sleep',
    'romantic': 'Romantic',
    'love': 'Romantic',
    'happy': 'Happy',
  };
  String? mood;
  for (final e in moodWords.entries) {
    if (t.contains(e.key)) {
      mood = e.value;
      break;
    }
  }
  String? era;
  for (final e in eras) {
    if (t.contains(e.toLowerCase())) era = e;
  }
  if (mood == null && era == null) {
    return const ChatMsg(
        "Tell me how you feel or what you're in the mood for, like 'chill music' or '90s songs'.",
        false);
  }
  final songs = demoSongs.where((s) => s.mood == mood || s.era == era).toList();
  if (songs.isEmpty) {
    return const ChatMsg(
        "I don't have tracks for that in the demo library yet. Want to try another mood?",
        false);
  }
  final sadDay = RegExp(r'(bad|tired|stress|heavy|sad)').hasMatch(t);
  return ChatMsg(
      sadDay
          ? "Sorry to hear that. Here's something to ease the day:"
          : 'Here is what I found for ${mood ?? era}:',
      false,
      songs);
}

class AiScreen extends ConsumerStatefulWidget {
  const AiScreen({super.key});

  @override
  ConsumerState<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends ConsumerState<AiScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final List<ChatMsg> _msgs = [
    const ChatMsg("Hey! 👋 What kind of music are you in the mood for?", false),
  ];
  static const _quick = [
    'Today was bad',
    'I want relaxing music',
    'Something for studying',
    'Party songs',
  ];

  void _send(String text) {
    final v = text.trim();
    if (v.isEmpty) return;
    setState(() => _msgs.add(ChatMsg(v, true)));
    _ctrl.clear();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() => _msgs.add(botReply(v)));
      _toBottom();
    });
    _toBottom();
  }

  void _toBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxW = MediaQuery.of(context).size.width * 0.8;
    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Vibe AI',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                  Text('Simple local mode. Cloud AI comes later.',
                      style: TextStyle(color: VC.muted, fontSize: 12)),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              itemCount: _msgs.length,
              itemBuilder: (_, i) {
                final m = _msgs[i];
                return Align(
                  alignment:
                      m.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: maxW),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: m.isUser ? VC.primary : VC.card,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(m.text),
                        for (final s in m.songs)
                          SongTile(song: s, queue: m.songs),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _quick.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => ActionChip(
                label: Text(_quick[i]),
                onPressed: () => _send(_quick[i]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: TextField(
              controller: _ctrl,
              onSubmitted: _send,
              textInputAction: TextInputAction.send,
              decoration: InputDecoration(
                hintText: 'Tell Vibe AI what you feel',
                filled: true,
                fillColor: VC.card,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send_rounded, color: VC.glow),
                  onPressed: () => _send(_ctrl.text),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
