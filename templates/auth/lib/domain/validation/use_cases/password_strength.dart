import '../../../common/constants/auth_policy.dart';
import '../models/password_assessment.dart';

/// Scores a password for the strength meter and the rules checklist.
///
/// Length matters most, so the score is a handful of cheap signals rather than
/// a guess at entropy: mixed case, a digit, a symbol and extra length each earn
/// a point. Common passwords are capped at weak. For a stronger estimate, swap
/// this class for one backed by a dictionary-aware estimator such as zxcvbn;
/// the rest of the template only reads the returned [PasswordAssessment].
class PasswordStrength {
  /// Creates the use case.
  const PasswordStrength();

  static final RegExp _lower = RegExp('[a-z]');
  static final RegExp _upper = RegExp('[A-Z]');
  static final RegExp _digit = RegExp('[0-9]');
  static final RegExp _symbol = RegExp(r'[^A-Za-z0-9\s]');

  /// Scores [password].
  PasswordAssessment call(String password) {
    if (password.isEmpty) return PasswordAssessment.empty;

    final bool longEnough = password.length >= AuthPolicy.minPasswordLength;
    final bool mixedCase =
        _lower.hasMatch(password) && _upper.hasMatch(password);
    final bool number = _digit.hasMatch(password);
    final bool symbol = _symbol.hasMatch(password);
    final bool isCommon = AuthPolicy.commonPasswords.contains(
      password.toLowerCase(),
    );

    final Set<PasswordRule> met = <PasswordRule>{
      if (longEnough) PasswordRule.minLength,
      if (mixedCase) PasswordRule.mixedCase,
      if (number) PasswordRule.number,
      if (symbol) PasswordRule.symbol,
    };

    if (!longEnough) {
      final double fill = password.length / AuthPolicy.minPasswordLength;
      return PasswordAssessment(
        level: PasswordStrengthLevel.tooShort,
        score: 0.2 * fill,
        met: met,
        isCommon: isCommon,
      );
    }

    final int points =
        (mixedCase ? 1 : 0) +
        (number ? 1 : 0) +
        (symbol ? 1 : 0) +
        (password.length >= AuthPolicy.longPasswordLength ? 1 : 0);

    final PasswordStrengthLevel level = isCommon || points <= 1
        ? PasswordStrengthLevel.weak
        : points == 2
        ? PasswordStrengthLevel.fair
        : PasswordStrengthLevel.strong;

    return PasswordAssessment(
      level: level,
      score: switch (level) {
        PasswordStrengthLevel.tooShort => 0.2,
        PasswordStrengthLevel.weak => 0.4,
        PasswordStrengthLevel.fair => 0.7,
        PasswordStrengthLevel.strong => 1,
      },
      met: met,
      isCommon: isCommon,
    );
  }
}
