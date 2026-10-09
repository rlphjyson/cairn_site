import '../../../domain/messages/mappers/message_mapper.dart';
import '../../../domain/messages/models/chat_event.dart';
import '../../../domain/messages/models/message.dart';
import '../../../domain/messages/models/message_page.dart';
import '../../../domain/messages/models/outgoing_message.dart';
import '../../../domain/messages/repositories/message_repository.dart';
import '../../chat/remote/chat_event_stream.dart';
import '../../chat/remote/chat_remote_data_source.dart';

/// [MessageRepository] over a [ChatRemoteDataSource].
class MessageRepositoryImpl implements MessageRepository {
  /// Creates the repository.
  MessageRepositoryImpl(this._source);

  final ChatRemoteDataSource _source;

  @override
  Future<MessagePage> getMessages(
    String conversationId, {
    String? beforeId,
    int limit = 30,
  }) async => MessageMapper.pageFromJson(
    await _source.fetchMessages(
      conversationId,
      beforeId: beforeId,
      limit: limit,
    ),
  );

  @override
  Future<Message> sendMessage(OutgoingMessage message) async =>
      MessageMapper.fromJson(
        await _source.postMessage(MessageMapper.outgoingToJson(message)),
      );

  @override
  Future<void> markRead(String conversationId) =>
      _source.postRead(conversationId);

  @override
  Future<Message> toggleReaction(
    String conversationId,
    String messageId,
    String emoji,
  ) async => MessageMapper.fromJson(
    await _source.postReaction(conversationId, messageId, emoji),
  );

  @override
  Future<void> deleteForMe(String conversationId, String messageId) =>
      _source.deleteMessage(conversationId, messageId);

  @override
  Future<List<Message>> getMedia(String conversationId) async => <Message>[
    for (final Map<String, Object?> json in await _source.fetchMedia(
      conversationId,
    ))
      MessageMapper.fromJson(json),
  ];

  @override
  Stream<ChatEvent> watchConversation(
    String conversationId,
  ) => decodeChatEvents(_source.events()).where(
    (ChatEvent e) => switch (e) {
      MessageArrived(:final Message message) =>
        message.conversationId == conversationId,
      MessageUpdated(:final Message message) =>
        message.conversationId == conversationId,
      MessageRemoved(conversationId: final String id) => id == conversationId,
      TypingChanged(conversationId: final String id) => id == conversationId,
      PresenceChanged() || ConversationChanged() => false,
    },
  );
}
