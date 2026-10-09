import '../models/conversation.dart';

/// The conversation list and what you can do to its entries.
abstract interface class ConversationRepository {
  /// Every conversation, archived ones included, in any order.
  Future<List<Conversation>> getConversations();

  /// One conversation, or `null` when it no longer exists.
  Future<Conversation?> getConversation(String id);

  /// The conversation with [contactId], created when it does not exist yet.
  Future<Conversation> openDirect(String contactId);

  /// Creates a group with you and [memberIds].
  Future<Conversation> createGroup(String name, List<String> memberIds);

  /// Changes list flags; arguments left `null` stay as they are.
  Future<Conversation> update(
    String id, {
    bool? pinned,
    bool? muted,
    bool? archived,
    bool? markedUnread,
  });

  /// Deletes a conversation (for you) with its history.
  Future<void> delete(String id);

  /// Leaves a group; it disappears from your list.
  Future<void> leaveGroup(String id);

  /// Ids of conversations whose list entry changed (a new last message, an
  /// unread count, a flag), as they change. The list reloads when one arrives.
  ///
  /// Like `MessageRepository.watchConversation`, the demo backs this with a
  /// stream controller and a real app with its push channel.
  Stream<String> watchChanges();
}
