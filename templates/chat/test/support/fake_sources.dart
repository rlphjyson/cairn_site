import 'dart:async';

import 'package:cairn_template_chat/cairn_template_chat.dart';

/// A data source that wraps the in-memory one and adds what tests need: events
/// pushed by hand (as a WebSocket would deliver them), a gate that holds the
/// conversation list back, and a switch that makes sending fail.
///
/// It is also the smallest possible example of plugging your own
/// [ChatRemoteDataSource] into [ChatApp].
class WrappedSource implements ChatRemoteDataSource {
  WrappedSource(this.inner) {
    _innerEvents = inner.events().listen(_events.add);
  }

  final InMemoryChatDataSource inner;

  /// While set, [fetchConversations] waits for it.
  Completer<void>? conversationsGate;

  /// Makes [postMessage] throw.
  bool failSending = false;

  final StreamController<Map<String, Object?>> _events =
      StreamController<Map<String, Object?>>.broadcast();
  late final StreamSubscription<Map<String, Object?>> _innerEvents;

  /// Delivers a frame as if the server had pushed it.
  void push(Map<String, Object?> frame) => _events.add(frame);

  /// Adds a message to the wrapped store and pushes it to the clients.
  Map<String, Object?> pushIncoming({
    required String conversationId,
    required String senderId,
    required String text,
    String id = 'pushed-1',
  }) {
    final Map<String, Object?> message = <String, Object?>{
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'text': text,
      'sentAt': DateTime(2026, 10, 9, 12).toIso8601String(),
      'status': 'sent',
      'replyTo': null,
      'attachment': null,
      'reactions': <Object?>[],
    };
    push(<String, Object?>{'type': 'message', 'message': message});
    return message;
  }

  @override
  Future<Map<String, Object?>> fetchCurrentUser() => inner.fetchCurrentUser();

  @override
  Future<List<Map<String, Object?>>> fetchContacts() => inner.fetchContacts();

  @override
  Future<Map<String, Object?>> patchProfile(Map<String, Object?> changes) =>
      inner.patchProfile(changes);

  @override
  Future<void> blockContact(String contactId) => inner.blockContact(contactId);

  @override
  Future<List<Map<String, Object?>>> fetchConversations() async {
    await conversationsGate?.future;
    return inner.fetchConversations();
  }

  @override
  Future<Map<String, Object?>?> fetchConversation(String id) =>
      inner.fetchConversation(id);

  @override
  Future<Map<String, Object?>> openDirectConversation(String contactId) =>
      inner.openDirectConversation(contactId);

  @override
  Future<Map<String, Object?>> createGroupConversation({
    required String name,
    required List<String> memberIds,
  }) => inner.createGroupConversation(name: name, memberIds: memberIds);

  @override
  Future<Map<String, Object?>> patchConversation(
    String id,
    Map<String, Object?> changes,
  ) => inner.patchConversation(id, changes);

  @override
  Future<void> deleteConversation(String id) => inner.deleteConversation(id);

  @override
  Future<void> leaveConversation(String id) => inner.leaveConversation(id);

  @override
  Future<Map<String, Object?>> fetchMessages(
    String conversationId, {
    String? beforeId,
    required int limit,
  }) => inner.fetchMessages(conversationId, beforeId: beforeId, limit: limit);

  @override
  Future<Map<String, Object?>> postMessage(Map<String, Object?> body) async {
    if (failSending) throw StateError('offline');
    return inner.postMessage(body);
  }

  @override
  Future<void> postRead(String conversationId) =>
      inner.postRead(conversationId);

  @override
  Future<Map<String, Object?>> postReaction(
    String conversationId,
    String messageId,
    String emoji,
  ) => inner.postReaction(conversationId, messageId, emoji);

  @override
  Future<void> deleteMessage(String conversationId, String messageId) =>
      inner.deleteMessage(conversationId, messageId);

  @override
  Future<List<Map<String, Object?>>> fetchMedia(String conversationId) =>
      inner.fetchMedia(conversationId);

  @override
  Stream<Map<String, Object?>> events() => _events.stream;

  @override
  void dispose() {
    unawaited(_innerEvents.cancel());
    inner.dispose();
    unawaited(_events.close());
  }
}

/// An in-memory source with the clock fixed and no reply delay.
InMemoryChatDataSource demoSource({
  Duration replyLatency = Duration.zero,
  DateTime? now,
}) => InMemoryChatDataSource(
  replyLatency: replyLatency,
  now: () => now ?? DateTime(2026, 10, 9, 12),
);
