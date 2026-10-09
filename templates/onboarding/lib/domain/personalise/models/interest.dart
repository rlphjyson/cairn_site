import 'package:equatable/equatable.dart';

/// A topic the user can pick on the personalise step.
class Interest extends Equatable {
  /// Creates an interest.
  const Interest({required this.id, required this.label});

  /// Stable identifier, saved with the progress.
  final String id;

  /// What the chip says.
  final String label;

  @override
  List<Object?> get props => <Object?>[id, label];
}
