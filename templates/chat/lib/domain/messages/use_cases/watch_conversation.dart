import '../models/chat_event.dart';
import '../repositories/message_repository.dart';

/// The live events of one conversation.
class WatchConversation {
  /// Creates the use case.
  const WatchConversation(this._messages);

  final MessageRepository _messages;

  /// Subscribes; cancel the subscription when the thread closes.
  Stream<ChatEvent> call(String conversationId) =>
      _messages.watchConversation(conversationId);
}
