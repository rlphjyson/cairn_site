import '../repositories/message_repository.dart';

/// Marks a conversation as read by you.
class MarkRead {
  /// Creates the use case.
  const MarkRead(this._messages);

  final MessageRepository _messages;

  /// Clears the unread count of [conversationId].
  Future<void> call(String conversationId) =>
      _messages.markRead(conversationId);
}
