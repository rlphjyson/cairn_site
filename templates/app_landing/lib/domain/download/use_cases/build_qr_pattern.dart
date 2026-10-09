import '../models/qr_pattern.dart';

/// Builds the deterministic demo pattern for a [QrPattern].
///
/// The same seed always gives the same pattern, so the card does not flicker
/// between builds. The result is decorative: it will not scan.
class BuildQrPattern {
  /// Creates the use case.
  const BuildQrPattern();

  /// The smallest grid that still fits the finder squares.
  static const int minSize = 21;

  /// Builds a pattern of [size] modules from [seed].
  QrPattern call(String seed, {int size = 25}) {
    final int n = size < minSize ? minSize : size;
    final List<bool> m = List<bool>.filled(n * n, false);
    final List<bool> reserved = List<bool>.filled(n * n, false);

    void set(int x, int y, bool dark) {
      if (x < 0 || y < 0 || x >= n || y >= n) return;
      m[y * n + x] = dark;
      reserved[y * n + x] = true;
    }

    void finder(int ox, int oy) {
      // A 9x9 area: the 7x7 finder plus a light separator ring.
      for (int dy = -1; dy <= 7; dy++) {
        for (int dx = -1; dx <= 7; dx++) {
          final bool ring = dx == 0 || dx == 6 || dy == 0 || dy == 6;
          final bool core = dx >= 2 && dx <= 4 && dy >= 2 && dy <= 4;
          final bool inside = dx >= 0 && dx <= 6 && dy >= 0 && dy <= 6;
          set(ox + dx, oy + dy, inside && (ring || core));
        }
      }
    }

    finder(0, 0);
    finder(n - 7, 0);
    finder(0, n - 7);

    // Timing lines between the finders.
    for (int i = 8; i < n - 8; i++) {
      set(i, 6, i.isEven);
      set(6, i, i.isEven);
    }

    // An alignment mark near the fourth corner.
    final int a = n - 9;
    for (int dy = -2; dy <= 2; dy++) {
      for (int dx = -2; dx <= 2; dx++) {
        final bool edge = dx.abs() == 2 || dy.abs() == 2;
        set(a + dx, a + dy, edge || (dx == 0 && dy == 0));
      }
    }

    // The data area, from a seeded xorshift stream.
    int state = _fnv1a(seed);
    if (state == 0) state = 0x9e3779b9;
    bool next() {
      state ^= (state << 13) & 0xffffffff;
      state ^= state >> 17;
      state ^= (state << 5) & 0xffffffff;
      state &= 0xffffffff;
      return state & 1 == 1;
    }

    for (int i = 0; i < n * n; i++) {
      if (!reserved[i]) m[i] = next();
    }
    return QrPattern(n, List<bool>.unmodifiable(m));
  }

  static int _fnv1a(String text) {
    int hash = 0x811c9dc5;
    for (final int unit in text.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash;
  }
}
