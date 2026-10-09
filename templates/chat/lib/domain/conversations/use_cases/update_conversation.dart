import '../models/conversation.dart';
import '../repositories/conversation_repository.dart';

/// Pins, mutes, archives or flags a conversation.
class UpdateConversation {
  /// Creates the use case.
  const UpdateConversation(this._conversations);

  final ConversationRepository _conversations;

  /// Applies the flags that are not `null`.
  Future<Conversation> call(
    String id, {
    bool? pinned,
    bool? muted,
    bool? archived,
    bool? markedUnread,
  }) => _conversations.update(
    id,
    pinned: pinned,
    muted: muted,
    archived: archived,
    markedUnread: markedUnread,
  );
}
