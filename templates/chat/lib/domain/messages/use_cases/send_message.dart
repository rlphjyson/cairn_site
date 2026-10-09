import '../models/attachment.dart';
import '../models/message.dart';
import '../models/outgoing_message.dart';
import '../models/reply_preview.dart';
import '../repositories/message_repository.dart';

/// Sends a message.
class SendMessage {
  /// Creates the use case.
  ///
  /// [onSent] is called with every message the server accepted, which is where
  /// a host app hooks analytics or its own side effects (see
  /// `ChatApp.onMessageSent`).
  const SendMessage(this._messages, {this.onSent});

  final MessageRepository _messages;

  /// Called after each successful send.
  final void Function(Message message)? onSent;

  /// Whether a draft can be sent: it has text, or an attachment.
  static bool canSend(String text, {Attachment? attachment}) =>
      text.trim().isNotEmpty || attachment != null;

  /// Sends [text] (trimmed) to [conversationId], optionally as a reply and
  /// optionally with an [attachment].
  ///
  /// Throws an [ArgumentError] when there is nothing to send.
  Future<Message> call(
    String conversationId, {
    String text = '',
    ReplyPreview? replyTo,
    Attachment? attachment,
  }) async {
    if (!canSend(text, attachment: attachment)) {
      throw ArgumentError('A message needs text or an attachment.');
    }
    final Message sent = await _messages.sendMessage(
      OutgoingMessage(
        conversationId: conversationId,
        text: text.trim(),
        replyTo: replyTo,
        attachment: attachment,
      ),
    );
    onSent?.call(sent);
    return sent;
  }
}
