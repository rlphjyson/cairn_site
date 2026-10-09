import 'package:equatable/equatable.dart';

/// The answer to a request that changes something: it worked, or it did not and
/// here is why.
class ActionResult extends Equatable {
  /// Creates a result.
  const ActionResult({required this.ok, this.message});

  /// A success.
  const ActionResult.success([this.message]) : ok = true;

  /// A failure with a [message] fit to show.
  const ActionResult.failure(String this.message) : ok = false;

  /// Whether it worked.
  final bool ok;

  /// A message for the person, when there is one.
  final String? message;

  @override
  List<Object?> get props => <Object?>[ok, message];
}
