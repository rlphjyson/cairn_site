import '../../../domain/messages/mappers/chat_event_mapper.dart';
import '../../../domain/messages/models/chat_event.dart';

/// Decodes the data source's JSON frames into [ChatEvent]s, dropping frame
/// types this version does not know.
///
/// Stays a broadcast stream when [frames] is one, so several repositories can
/// each listen to the same connection.
Stream<ChatEvent> decodeChatEvents(Stream<Map<String, Object?>> frames) =>
    frames
        .map(ChatEventMapper.fromJson)
        .where((ChatEvent? event) => event != null)
        .cast<ChatEvent>();
