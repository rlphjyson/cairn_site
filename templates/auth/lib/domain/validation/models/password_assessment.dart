import 'package:equatable/equatable.dart';

/// One requirement or recommendation about a password.
enum PasswordRule {
  /// At least the policy's minimum length.
  minLength(required: true),

  /// Both upper and lower case letters.
  mixedCase(required: true),

  /// At least one digit.
  number(required: true),

  /// At least one symbol. Recommended, not required.
  symbol(required: false);

  const PasswordRule({required this.required});

  /// Whether a password must satisfy this rule to be accepted.
  final bool required;
}

/// How strong a password is, as shown by the meter.
enum PasswordStrengthLevel {
  /// Under the minimum length, or empty.
  tooShort,

  /// Long enough but easy to guess.
  weak,

  /// Acceptable.
  fair,

  /// Hard to guess.
  strong,
}

/// The result of scoring a password. Holds no part of the password itself, so
/// it is safe to keep in a cubit state.
class PasswordAssessment extends Equatable {
  /// Creates an assessment.
  const PasswordAssessment({
    required this.level,
    required this.score,
    required this.met,
    required this.isCommon,
  });

  /// What an empty password scores.
  static const PasswordAssessment empty = PasswordAssessment(
    level: PasswordStrengthLevel.tooShort,
    score: 0,
    met: <PasswordRule>{},
    isCommon: false,
  );

  /// The strength band.
  final PasswordStrengthLevel level;

  /// A value from 0 to 1 for a progress bar.
  final double score;

  /// The rules the password satisfies.
  final Set<PasswordRule> met;

  /// Whether the password is on the common-passwords list.
  final bool isCommon;

  /// Whether every required rule is met and the password is not common.
  bool get meetsPolicy =>
      !isCommon &&
      PasswordRule.values
          .where((PasswordRule r) => r.required)
          .every(met.contains);

  @override
  List<Object?> get props => <Object?>[level, score, met, isCommon];
}
