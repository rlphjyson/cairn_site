import '../models/conversation.dart';
import '../repositories/conversation_repository.dart';

/// Opens the one-to-one conversation with a contact, creating it on first use.
class OpenDirectConversation {
  /// Creates the use case.
  const OpenDirectConversation(this._conversations);

  final ConversationRepository _conversations;

  /// The conversation with [contactId].
  Future<Conversation> call(String contactId) =>
      _conversations.openDirect(contactId);
}
