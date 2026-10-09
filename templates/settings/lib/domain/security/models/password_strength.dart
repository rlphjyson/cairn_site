/// How hard a password is to guess, on a short scale.
enum PasswordStrengthLevel {
  /// Nothing typed yet.
  empty('', 0),

  /// Too easy to guess.
  weak('Weak', 1),

  /// Getting there.
  fair('Fair', 2),

  /// Good enough.
  good('Good', 3),

  /// Hard to guess.
  strong('Strong', 4);

  const PasswordStrengthLevel(this.label, this.score);

  /// A word for the meter.
  final String label;

  /// 0 to 4.
  final int score;
}

/// A simple, explainable strength rule: one point each for length (8+), length
/// (12+), mixed case with a digit, and a symbol.
///
/// It is a guide for the person typing, not a security guarantee. If you need
/// more, swap this function for `zxcvbn`; nothing else changes.
abstract final class PasswordStrength {
  /// The fewest characters a new password may have.
  static const int minLength = 8;

  /// The level of [password].
  static PasswordStrengthLevel of(String password) {
    if (password.isEmpty) return PasswordStrengthLevel.empty;
    int points = 0;
    if (password.length >= minLength) points++;
    if (password.length >= 12) points++;
    final bool mixed =
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'\d').hasMatch(password);
    if (mixed) points++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) points++;
    if (password.length < minLength) points = points.clamp(0, 1);
    return switch (points) {
      <= 1 => PasswordStrengthLevel.weak,
      2 => PasswordStrengthLevel.fair,
      3 => PasswordStrengthLevel.good,
      _ => PasswordStrengthLevel.strong,
    };
  }
}
