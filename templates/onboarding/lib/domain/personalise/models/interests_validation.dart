import 'package:equatable/equatable.dart';

/// The outcome of checking the chosen interests.
class InterestsValidation extends Equatable {
  /// Creates a result.
  const InterestsValidation({required this.count, required this.min});

  /// How many valid interests are chosen.
  final int count;

  /// How many are needed.
  final int min;

  /// Whether enough are chosen.
  bool get isValid => count >= min;

  /// How many more are needed; zero when valid.
  int get missing => isValid ? 0 : min - count;

  /// A message for the user, or `null` when valid.
  String? get message {
    if (isValid) return null;
    return missing == 1
        ? 'Pick 1 more to continue.'
        : 'Pick $missing more to continue.';
  }

  @override
  List<Object?> get props => <Object?>[count, min];
}
