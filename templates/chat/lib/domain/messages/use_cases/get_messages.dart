import '../../../common/constants/chat_limits.dart';
import '../models/message.dart';
import '../models/message_page.dart';
import '../repositories/message_repository.dart';

/// One page of a conversation's history.
class GetMessages {
  /// Creates the use case.
  const GetMessages(this._messages);

  final MessageRepository _messages;

  /// The newest page, or the page before [beforeId].
  ///
  /// Whatever order the backend answers in, the page comes back oldest first
  /// with no duplicates.
  Future<MessagePage> call(
    String conversationId, {
    String? beforeId,
    int limit = ChatLimits.pageSize,
  }) async {
    final MessagePage page = await _messages.getMessages(
      conversationId,
      beforeId: beforeId,
      limit: limit,
    );
    final Set<String> seen = <String>{};
    final List<Message> sorted =
        page.messages.where((Message m) => seen.add(m.id)).toList()
          ..sort((Message a, Message b) => a.sentAt.compareTo(b.sentAt));
    return MessagePage(messages: sorted, hasMore: page.hasMore);
  }
}
