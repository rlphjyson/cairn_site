import '../../contacts/mappers/contact_mapper.dart';
import '../models/chat_event.dart';
import 'message_mapper.dart';

/// Decoded JSON frame -> [ChatEvent].
///
/// Every frame has a `type`:
///
/// ```json
/// { "type": "message", "message": { ...message... } }
/// { "type": "message.updated", "message": { ...message... } }
/// { "type": "message.removed", "conversationId": "c_mina", "messageId": "m_1" }
/// { "type": "typing", "conversationId": "c_mina", "userId": "u_mina", "typing": true }
/// { "type": "presence", "contact": { ...contact... } }
/// { "type": "conversation", "conversationId": "c_mina" }
/// ```
abstract final class ChatEventMapper {
  /// Reads a frame; returns `null` for types this app does not know, so a
  /// newer server never breaks an older client.
  static ChatEvent? fromJson(Map<String, Object?> json) {
    switch (json['type']) {
      case 'message':
        return MessageArrived(
          MessageMapper.fromJson(json['message']! as Map<String, Object?>),
        );
      case 'message.updated':
        return MessageUpdated(
          MessageMapper.fromJson(json['message']! as Map<String, Object?>),
        );
      case 'message.removed':
        return MessageRemoved(
          json['conversationId']! as String,
          json['messageId']! as String,
        );
      case 'typing':
        return TypingChanged(
          json['conversationId']! as String,
          json['userId']! as String,
          typing: (json['typing'] as bool?) ?? false,
        );
      case 'presence':
        return PresenceChanged(
          ContactMapper.fromJson(json['contact']! as Map<String, Object?>),
        );
      case 'conversation':
        return ConversationChanged(json['conversationId']! as String);
    }
    return null;
  }
}
