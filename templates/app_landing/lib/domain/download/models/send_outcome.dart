import 'package:equatable/equatable.dart';

/// What kind of address a visitor typed.
enum ContactKind {
  /// An email address.
  email,

  /// A phone number.
  phone,
}

/// A validated, normalised email address or phone number.
class Contact extends Equatable {
  /// Creates a contact.
  const Contact(this.kind, this.value);

  /// Whether [value] is an email or a phone number.
  final ContactKind kind;

  /// The address: trimmed, or for phones only digits and a leading `+`.
  final String value;

  @override
  List<Object?> get props => <Object?>[kind, value];
}

/// The result of checking what the visitor typed.
class ContactCheck extends Equatable {
  /// A valid [contact].
  const ContactCheck.valid(Contact this.contact) : message = null;

  /// An invalid entry, with [message] to show.
  const ContactCheck.invalid(String this.message) : contact = null;

  /// The contact when valid.
  final Contact? contact;

  /// What to tell the visitor when invalid.
  final String? message;

  /// Whether the entry passed.
  bool get isValid => contact != null;

  @override
  List<Object?> get props => <Object?>[contact, message];
}

/// Thrown by a [DownloadLinkService]-style data source when the link cannot
/// be sent; [message] is safe to show to the visitor.
class DownloadLinkException implements Exception {
  /// Creates the exception.
  const DownloadLinkException(this.message);

  /// What went wrong, in words for the visitor.
  final String message;

  @override
  String toString() => 'DownloadLinkException: $message';
}

/// How a send attempt ended.
enum SendStatus {
  /// What was typed did not pass validation; nothing was sent.
  invalid,

  /// The service accepted the request.
  sent,

  /// The request was made and the service failed.
  failed,
}

/// The result of sending the download link.
class SendOutcome extends Equatable {
  /// The entry failed validation with [message].
  const SendOutcome.invalid(String this.message)
    : status = SendStatus.invalid,
      contact = null;

  /// The link was sent to [contact].
  const SendOutcome.sent(Contact this.contact)
    : status = SendStatus.sent,
      message = null;

  /// The service failed with [message].
  const SendOutcome.failed(String this.message)
    : status = SendStatus.failed,
      contact = null;

  /// How the attempt ended.
  final SendStatus status;

  /// The message for [SendStatus.invalid] and [SendStatus.failed].
  final String? message;

  /// Where the link went, for [SendStatus.sent].
  final Contact? contact;

  @override
  List<Object?> get props => <Object?>[status, message, contact];
}
