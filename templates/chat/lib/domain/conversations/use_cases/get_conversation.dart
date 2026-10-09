import '../models/conversation.dart';
import '../repositories/conversation_repository.dart';

/// One conversation by id.
class GetConversation {
  /// Creates the use case.
  const GetConversation(this._conversations);

  final ConversationRepository _conversations;

  /// The conversation, or `null` when it no longer exists.
  Future<Conversation?> call(String id) => _conversations.getConversation(id);
}
