import 'package:equatable/equatable.dart';

/// A short message a cubit wants the screen to show as a toast.
///
/// Every notice is distinct, even with the same text, so a state that carries
/// one always differs from the one before and listeners fire again.
class Notice extends Equatable {
  /// Creates a notice.
  Notice(this.title, {this.description, this.isError = false}) : id = _next++;

  static int _next = 0;

  /// What happened, briefly.
  final String title;

  /// More detail.
  final String? description;

  /// Whether it is an error rather than a confirmation.
  final bool isError;

  /// A unique id.
  final int id;

  @override
  List<Object?> get props => <Object?>[id, title, description, isError];
}
