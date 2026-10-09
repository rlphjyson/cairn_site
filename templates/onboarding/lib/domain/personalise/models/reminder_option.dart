import 'package:equatable/equatable.dart';

/// A reminder time or frequency the user can choose.
class ReminderOption extends Equatable {
  /// Creates an option.
  const ReminderOption({required this.id, required this.label});

  /// Stable identifier, saved with the progress.
  final String id;

  /// What the select shows, such as "Every morning, 8:00".
  final String label;

  @override
  List<Object?> get props => <Object?>[id, label];
}
