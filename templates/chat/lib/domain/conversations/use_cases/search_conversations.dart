import '../models/conversation.dart';

/// Filters conversations by name or by what the last message says.
class SearchConversations {
  /// Creates the use case.
  const SearchConversations();

  /// The conversations that match [query], keeping their order. A blank query
  /// matches everything.
  List<Conversation> call(List<Conversation> conversations, String query) {
    final String q = query.trim().toLowerCase();
    if (q.isEmpty) return conversations;
    return conversations
        .where(
          (Conversation c) =>
              c.title.toLowerCase().contains(q) ||
              (c.lastMessage?.preview.toLowerCase().contains(q) ?? false),
        )
        .toList();
  }
}
