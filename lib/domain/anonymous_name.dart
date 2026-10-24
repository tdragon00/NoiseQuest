import 'dart:math';

/// Stable themed anonymous names (SPEC §9.3). Used as a client-side fallback
/// when the server omits `display_name`.
const _adjectives = [
  'Silent', 'Neon', 'Crimson', 'Quiet', 'Lucky',
  'Wild', 'Cosmic', 'Digital', 'Feral', 'Midnight',
];

const _nouns = [
  'Runner', 'Ranger', 'Drifter', 'Walker', 'Seeker',
  'Nomad', 'Strider', 'Blade', 'Pioneer', 'Wanderer',
];

String anonymousDisplayName({String seed = '', int? suffix}) {
  final random = seed.isEmpty ? Random() : Random(seed.hashCode);
  final adjective = _adjectives[random.nextInt(_adjectives.length)];
  final noun = _nouns[random.nextInt(_nouns.length)];
  final number = suffix ?? (random.nextBool() ? random.nextInt(90) + 10 : null);
  return number == null ? '$adjective $noun' : '$adjective $noun $number';
}
