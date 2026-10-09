import '../../../domain/conversations/mappers/conversation_mapper.dart';
import '../../../domain/conversations/models/conversation.dart';
import '../../../domain/conversations/repositories/conversation_repository.dart';
import '../../../domain/messages/models/chat_event.dart';
import '../../chat/remote/chat_event_stream.dart';
import '../../chat/remote/chat_remote_data_source.dart';

/// [ConversationRepository] over a [ChatRemoteDataSource].
class ConversationRepositoryImpl implements ConversationRepository {
  /// Creates the repository.
  ConversationRepositoryImpl(this._source);

  final ChatRemoteDataSource _source;

  @override
  Future<List<Conversation>> getConversations() async => <Conversation>[
    for (final Map<String, Object?> json in await _source.fetchConversations())
      ConversationMapper.fromJson(json),
  ];

  @override
  Future<Conversation?> getConversation(String id) async {
    final Map<String, Object?>? json = await _source.fetchConversation(id);
    return json == null ? null : ConversationMapper.fromJson(json);
  }

  @override
  Future<Conversation> openDirect(String contactId) async =>
      ConversationMapper.fromJson(
        await _source.openDirectConversation(contactId),
      );

  @override
  Future<Conversation> createGroup(String name, List<String> memberIds) async =>
      ConversationMapper.fromJson(
        await _source.createGroupConversation(name: name, memberIds: memberIds),
      );

  @override
  Future<Conversation> update(
    String id, {
    bool? pinned,
    bool? muted,
    bool? archived,
    bool? markedUnread,
  }) async => ConversationMapper.fromJson(
    await _source.patchConversation(id, <String, Object?>{
      'pinned': pinned,
      'muted': muted,
      'archived': archived,
      'markedUnread': markedUnread,
    }),
  );

  @override
  Future<void> delete(String id) => _source.deleteConversation(id);

  @override
  Future<void> leaveGroup(String id) => _source.leaveConversation(id);

  @override
  Stream<String> watchChanges() => decodeChatEvents(_source.events())
      .where((ChatEvent e) => e is ConversationChanged)
      .map((ChatEvent e) => (e as ConversationChanged).conversationId);
}
