import '../repositories/message_repository.dart';

/// Removes a message from your own view ("delete for me").
class DeleteMessage {
  /// Creates the use case.
  const DeleteMessage(this._messages);

  final MessageRepository _messages;

  /// Deletes [messageId] from [conversationId] for you only.
  Future<void> call(String conversationId, String messageId) =>
      _messages.deleteForMe(conversationId, messageId);
}
