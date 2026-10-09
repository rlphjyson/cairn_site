import 'package:equatable/equatable.dart';

/// A goal the user can choose on the personalise step.
class Goal extends Equatable {
  /// Creates a goal.
  const Goal({required this.id, required this.label, required this.hint});

  /// Stable identifier, saved with the progress.
  final String id;

  /// The headline.
  final String label;

  /// One line explaining it.
  final String hint;

  @override
  List<Object?> get props => <Object?>[id, label, hint];
}
