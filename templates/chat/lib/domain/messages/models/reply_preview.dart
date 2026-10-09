import 'package:equatable/equatable.dart';

/// The quoted part of a reply: enough to draw the quote without loading the
/// original message.
class ReplyPreview extends Equatable {
  /// Creates a preview.
  const ReplyPreview({
    required this.messageId,
    required this.senderId,
    required this.text,
  });

  /// The message being answered.
  final String messageId;

  /// Who wrote it.
  final String senderId;

  /// A one-line summary of it.
  final String text;

  @override
  List<Object?> get props => <Object?>[messageId, senderId, text];
}
