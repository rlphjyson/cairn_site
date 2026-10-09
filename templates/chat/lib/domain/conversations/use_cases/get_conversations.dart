import '../models/conversation.dart';
import '../models/conversation_inbox.dart';
import '../repositories/conversation_repository.dart';

/// The conversation list, in display order.
class GetConversations {
  /// Creates the use case.
  const GetConversations(this._conversations);

  final ConversationRepository _conversations;

  /// Loads every conversation and sorts it: pinned first, then newest
  /// activity first; archived ones are kept apart.
  Future<ConversationInbox> call() async =>
      sort(await _conversations.getConversations());

  /// The ordering on its own.
  static ConversationInbox sort(List<Conversation> all) {
    int byDisplayOrder(Conversation a, Conversation b) {
      if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
      return b.updatedAt.compareTo(a.updatedAt);
    }

    return ConversationInbox(
      active: all.where((Conversation c) => !c.archived).toList()
        ..sort(byDisplayOrder),
      archived: all.where((Conversation c) => c.archived).toList()
        ..sort(byDisplayOrder),
    );
  }
}
