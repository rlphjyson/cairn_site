import 'package:equatable/equatable.dart';

/// A signup the service accepted.
class WaitlistReceipt extends Equatable {
  /// Creates a receipt.
  const WaitlistReceipt({required this.position});

  /// The visitor's place in the queue.
  final int position;

  @override
  List<Object?> get props => <Object?>[position];
}

/// Thrown by a data source when the service refuses or cannot be reached.
class WaitlistException implements Exception {
  /// Creates the exception with a message safe to show to the visitor.
  const WaitlistException(this.message);

  /// What went wrong, in words for the visitor.
  final String message;

  @override
  String toString() => 'WaitlistException: $message';
}

/// How a signup attempt ended.
enum JoinStatus {
  /// The email did not pass validation; nothing was sent.
  invalid,

  /// The service accepted the email.
  joined,

  /// The email was sent but the service failed.
  failed,
}

/// The result of [JoinStatus]-reporting signup.
class JoinOutcome extends Equatable {
  /// The email failed validation with [message].
  const JoinOutcome.invalid(String this.message)
    : status = JoinStatus.invalid,
      receipt = null;

  /// The service accepted the email.
  const JoinOutcome.joined(WaitlistReceipt this.receipt)
    : status = JoinStatus.joined,
      message = null;

  /// The service failed with [message].
  const JoinOutcome.failed(String this.message)
    : status = JoinStatus.failed,
      receipt = null;

  /// How the attempt ended.
  final JoinStatus status;

  /// The message to show for [JoinStatus.invalid] and [JoinStatus.failed].
  final String? message;

  /// The receipt for [JoinStatus.joined].
  final WaitlistReceipt? receipt;

  @override
  List<Object?> get props => <Object?>[status, message, receipt];
}
