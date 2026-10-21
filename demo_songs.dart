import 'song.dart';

const moods = [
  'Happy',
  'Sad',
  'Chill',
  'Focus',
  'Workout',
  'Romantic',
  'Party',
  'Sleep'
];
const eras = [
  '50s',
  '60s',
  '70s',
  '80s',
  '90s',
  '2000s',
  'Early 2000s',
  'Modern'
];

// DEMO DATA: royalty-free SoundHelix tracks used only for testing playback.
// Mood/era tags are placeholders. Replace with the Supabase songs table in Phase 2.
const _base = 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-';
const _tagMood = [
  'Chill',
  'Happy',
  'Focus',
  'Workout',
  'Romantic',
  'Party',
  'Sleep',
  'Sad'
];
const _tagEra = [
  'Modern',
  '2000s',
  '90s',
  '80s',
  'Modern',
  '2000s',
  '70s',
  '60s'
];

final List<Song> demoSongs = List.generate(
  8,
  (i) => Song(
    id: 'demo-${i + 1}',
    title: 'Demo Track ${i + 1}',
    artist: 'SoundHelix',
    era: _tagEra[i],
    mood: _tagMood[i],
    audioUrl: '$_base${i + 1}.mp3',
  ),
);
