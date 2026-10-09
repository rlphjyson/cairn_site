bool _isJoiner(int rune) => rune == 0x200D;

bool _isModifier(int rune) =>
    (rune >= 0xFE00 && rune <= 0xFE0F) ||
    (rune >= 0x1F3FB && rune <= 0x1F3FF) ||
    rune == 0x20E3;

bool _isEmojiRune(int rune) =>
    (rune >= 0x1F300 && rune <= 0x1FAFF) ||
    (rune >= 0x2600 && rune <= 0x27BF) ||
    (rune >= 0x1F1E6 && rune <= 0x1F1FF) ||
    rune == 0x2B50 ||
    rune == 0x2B55 ||
    rune == 0x203C ||
    rune == 0x2049 ||
    rune == 0x00A9 ||
    rune == 0x00AE;

/// Whether [text] is nothing but one to three emoji (and spaces).
///
/// Such messages are shown larger, without the chrome of a sentence. Joined
/// sequences (a family, a skin tone, a flag) count as one emoji.
bool isEmojiOnly(String text) {
  final String trimmed = text.trim();
  if (trimmed.isEmpty) return false;
  int emoji = 0;
  bool afterJoiner = false;
  bool openFlag = false;
  for (final int rune in trimmed.runes) {
    if (rune == 0x20) continue;
    if (_isJoiner(rune)) {
      afterJoiner = true;
      continue;
    }
    if (_isModifier(rune)) continue;
    if (!_isEmojiRune(rune)) return false;
    final bool regional = rune >= 0x1F1E6 && rune <= 0x1F1FF;
    if (regional && openFlag) {
      // The second half of a flag.
      openFlag = false;
    } else {
      if (!afterJoiner) emoji++;
      openFlag = regional;
    }
    afterJoiner = false;
  }
  return emoji >= 1 && emoji <= 3;
}
