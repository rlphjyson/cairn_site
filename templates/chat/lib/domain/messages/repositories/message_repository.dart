import '../models/chat_event.dart';
import '../models/message.dart';
import '../models/message_page.dart';
import '../models/outgoing_message.dart';

/// The messages inside conversations.
abstract interface class MessageRepository {
  /// One page of history, oldest first.
  ///
  /// Without [beforeId] it is the newest page; with it, the page of messages
  /// sent before that message. [MessagePage.hasMore] says whether to ask again.
  Future<MessagePage> getMessages(
    String conversationId, {
    String? beforeId,
    int limit = 30,
  });

  /// Sends a message and returns it as the server stored it.
  Future<Message> sendMessage(OutgoingMessage message);

  /// Marks everything in the conversation as read by you.
  Future<void> markRead(String conversationId);

  /// Adds your [emoji] to a message, or removes it when already there.
  Future<Message> toggleReaction(
    String conversationId,
    String messageId,
    String emoji,
  );

  /// Removes a message from your view only.
  Future<void> deleteForMe(String conversationId, String messageId);

  /// Every message with a photo, newest last.
  Future<List<Message>> getMedia(String conversationId);

  /// Live events for one conversation: messages that arrive, messages that
  /// change, typing, and removals.
  ///
  /// **This is the extension point for real time.** The history methods above
  /// are request/response; everything that happens *to* an open thread without
  /// you asking arrives here. The demo backs it with a stream controller; a
  /// real app backs it with a WebSocket or server-sent events (see
  /// `doc/index.html`). The stream must be broadcast, and a thread subscribes
  /// when it opens and cancels when it closes.
  Stream<ChatEvent> watchConversation(String conversationId);
}
