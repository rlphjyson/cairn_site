import '../repositories/conversation_repository.dart';

/// Deletes a conversation for you.
class DeleteConversation {
  /// Creates the use case.
  const DeleteConversation(this._conversations);

  final ConversationRepository _conversations;

  /// Deletes [id] and its history.
  Future<void> call(String id) => _conversations.delete(id);
}
