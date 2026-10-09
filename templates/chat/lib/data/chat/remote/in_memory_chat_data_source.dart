import 'dart:async';

import 'chat_remote_data_source.dart';
import 'chat_seed.dart';
import 'demo_bot.dart';

/// A chat backend that lives in memory, with a scripted "demo bot" on the
/// other end of every conversation.
///
/// It answers with the same JSON a REST service would, keeps everything you do
/// (sent messages, reactions, pins...) for the life of the app, and pushes
/// events through a stream exactly as a WebSocket would. When you send a
/// message the bot reacts like a person: after [replyLatency] it marks the
/// message read, starts typing, then answers.
///
/// Replace it with a class that calls your service and nothing else in the
/// template changes.
class InMemoryChatDataSource implements ChatRemoteDataSource {
  /// Creates the data source.
  ///
  /// * [currentUserId] is who is signed in; it must match the id passed to
  ///   `ChatApp`.
  /// * [replyLatency] is how long the bot takes to answer. Zero answers on the
  ///   next event-loop turn (tests use this); the default feels like a person.
  /// * [now] is the clock, so a test can fix it.
  /// * [seed] replaces the built-in people and history.
  InMemoryChatDataSource({
    this.currentUserId = 'me',
    this.replyLatency = const Duration(milliseconds: 900),
    DateTime Function()? now,
    ChatSeed? seed,
  }) : _now = now ?? DateTime.now {
    final ChatSeed data =
        seed ?? ChatSeed.build(now: _now(), currentUserId: currentUserId);
    for (final Map<String, Object?> c in data.contacts) {
      _contacts[c['id']! as String] = Map<String, Object?>.of(c);
    }
    for (final Map<String, Object?> c in data.conversations) {
      _conversations[c['id']! as String] = Map<String, Object?>.of(c);
    }
    data.messages.forEach((String id, List<Map<String, Object?>> list) {
      _messages[id] = <Map<String, Object?>>[
        for (final Map<String, Object?> m in list) Map<String, Object?>.of(m),
      ];
    });
  }

  /// Who is signed in.
  final String currentUserId;

  /// How long the bot takes to answer.
  final Duration replyLatency;

  final DateTime Function() _now;

  final Map<String, Map<String, Object?>> _contacts =
      <String, Map<String, Object?>>{};
  final Map<String, Map<String, Object?>> _conversations =
      <String, Map<String, Object?>>{};
  final Map<String, List<Map<String, Object?>>> _messages =
      <String, List<Map<String, Object?>>>{};

  final StreamController<Map<String, Object?>> _events =
      StreamController<Map<String, Object?>>.broadcast();
  final Set<Timer> _timers = <Timer>{};
  int _sequence = 0;
  int _botTurn = 0;
  bool _disposed = false;

  // Profile and contacts ----------------------------------------------------

  @override
  Future<Map<String, Object?>> fetchCurrentUser() async =>
      Map<String, Object?>.of(_contacts[currentUserId]!);

  @override
  Future<List<Map<String, Object?>>> fetchContacts() async =>
      <Map<String, Object?>>[
        for (final Map<String, Object?> c in _contacts.values)
          Map<String, Object?>.of(c),
      ];

  @override
  Future<Map<String, Object?>> patchProfile(
    Map<String, Object?> changes,
  ) async {
    final Map<String, Object?> me = _contacts[currentUserId]!;
    for (final String key in <String>['name', 'about', 'presence']) {
      if (changes[key] != null) me[key] = changes[key];
    }
    _emit(<String, Object?>{
      'type': 'presence',
      'contact': Map<String, Object?>.of(me),
    });
    return Map<String, Object?>.of(me);
  }

  @override
  Future<void> blockContact(String contactId) async {
    _contacts[contactId]?['blocked'] = true;
    final List<String> doomed = <String>[
      for (final Map<String, Object?> c in _conversations.values)
        if (c['peerId'] == contactId) c['id']! as String,
    ];
    for (final String id in doomed) {
      _remove(id);
    }
  }

  // Conversations -----------------------------------------------------------

  @override
  Future<List<Map<String, Object?>>> fetchConversations() async =>
      <Map<String, Object?>>[
        for (final Map<String, Object?> c in _conversations.values)
          // A one-to-one chat appears once something has been said.
          if (c['type'] == 'group' || (_messages[c['id']]?.isNotEmpty ?? false))
            _conversationJson(c),
      ];

  @override
  Future<Map<String, Object?>?> fetchConversation(String id) async {
    final Map<String, Object?>? c = _conversations[id];
    return c == null ? null : _conversationJson(c);
  }

  @override
  Future<Map<String, Object?>> openDirectConversation(String contactId) async {
    for (final Map<String, Object?> c in _conversations.values) {
      if (c['type'] == 'direct' && c['peerId'] == contactId) {
        return _conversationJson(c);
      }
    }
    final String id = 'c_${contactId}_${_sequence++}';
    final Map<String, Object?> created = <String, Object?>{
      'id': id,
      'type': 'direct',
      'title': _contacts[contactId]?['name'] ?? 'Unknown',
      'avatar': null,
      'peerId': contactId,
      'memberIds': <String>[currentUserId, contactId],
      'pinned': false,
      'muted': false,
      'archived': false,
      'markedUnread': false,
      'unread': 0,
      'createdAt': _now().toIso8601String(),
    };
    _conversations[id] = created;
    _messages[id] = <Map<String, Object?>>[];
    return _conversationJson(created);
  }

  @override
  Future<Map<String, Object?>> createGroupConversation({
    required String name,
    required List<String> memberIds,
  }) async {
    final String id = 'c_group_${_sequence++}';
    final Map<String, Object?> created = <String, Object?>{
      'id': id,
      'type': 'group',
      'title': name,
      'avatar': null,
      'peerId': null,
      'memberIds': <String>[currentUserId, ...memberIds],
      'pinned': false,
      'muted': false,
      'archived': false,
      'markedUnread': false,
      'unread': 0,
      'createdAt': _now().toIso8601String(),
    };
    _conversations[id] = created;
    _messages[id] = <Map<String, Object?>>[];
    _emitConversation(id);
    return _conversationJson(created);
  }

  @override
  Future<Map<String, Object?>> patchConversation(
    String id,
    Map<String, Object?> changes,
  ) async {
    final Map<String, Object?> c = _conversations[id]!;
    for (final String key in <String>[
      'pinned',
      'muted',
      'archived',
      'markedUnread',
    ]) {
      if (changes[key] != null) c[key] = changes[key];
    }
    // "Mark as read" clears the unread count as well as the flag.
    if (changes['markedUnread'] == false) c['unread'] = 0;
    _emitConversation(id);
    return _conversationJson(c);
  }

  @override
  Future<void> deleteConversation(String id) async => _remove(id);

  @override
  Future<void> leaveConversation(String id) async => _remove(id);

  void _remove(String id) {
    _conversations.remove(id);
    _messages.remove(id);
    _emitConversation(id);
  }

  Map<String, Object?> _conversationJson(Map<String, Object?> stored) {
    final List<Map<String, Object?>> list =
        _messages[stored['id']] ?? const <Map<String, Object?>>[];
    final Map<String, Object?>? last = list.isEmpty ? null : list.last;
    final Map<String, Object?> json = Map<String, Object?>.of(stored);
    if (stored['type'] == 'direct') {
      final Map<String, Object?>? peer = _contacts[stored['peerId']];
      if (peer != null) {
        json['title'] = peer['name'];
        json['avatar'] = peer['avatar'];
      }
    }
    json['lastMessage'] = last == null ? null : Map<String, Object?>.of(last);
    json['updatedAt'] = last?['sentAt'] ?? stored['createdAt'];
    return json;
  }

  // Messages ----------------------------------------------------------------

  @override
  Future<Map<String, Object?>> fetchMessages(
    String conversationId, {
    String? beforeId,
    required int limit,
  }) async {
    final List<Map<String, Object?>> list =
        _messages[conversationId] ?? const <Map<String, Object?>>[];
    int end = list.length;
    if (beforeId != null) {
      final int at = list.indexWhere(
        (Map<String, Object?> m) => m['id'] == beforeId,
      );
      if (at >= 0) end = at;
    }
    final int start = end - limit < 0 ? 0 : end - limit;
    return <String, Object?>{
      'messages': <Map<String, Object?>>[
        for (final Map<String, Object?> m in list.sublist(start, end))
          Map<String, Object?>.of(m),
      ],
      'hasMore': start > 0,
    };
  }

  @override
  Future<Map<String, Object?>> postMessage(Map<String, Object?> body) async {
    final String conversationId = body['conversationId']! as String;
    final Map<String, Object?> message = <String, Object?>{
      'id': 'm_${_sequence++}',
      'conversationId': conversationId,
      'senderId': currentUserId,
      'text': body['text'] ?? '',
      'sentAt': _now().toIso8601String(),
      'status': 'sent',
      'replyTo': body['replyTo'],
      'attachment': body['attachment'],
      'reactions': <Map<String, Object?>>[],
    };
    (_messages[conversationId] ??= <Map<String, Object?>>[]).add(message);
    _conversations[conversationId]?['archived'] = false;
    _emitConversation(conversationId);
    _scheduleReply(message);
    return Map<String, Object?>.of(message);
  }

  @override
  Future<void> postRead(String conversationId) async {
    final Map<String, Object?>? c = _conversations[conversationId];
    if (c == null) return;
    if ((c['unread'] as int? ?? 0) == 0 && c['markedUnread'] != true) return;
    c['unread'] = 0;
    c['markedUnread'] = false;
    _emitConversation(conversationId);
  }

  @override
  Future<Map<String, Object?>> postReaction(
    String conversationId,
    String messageId,
    String emoji,
  ) async {
    final Map<String, Object?> message = _find(conversationId, messageId)!;
    final List<Map<String, Object?>> next = <Map<String, Object?>>[];
    bool found = false;
    for (final Object? r in message['reactions']! as List<Object?>) {
      final Map<String, Object?> reaction = r! as Map<String, Object?>;
      if (reaction['emoji'] != emoji) {
        next.add(reaction);
        continue;
      }
      found = true;
      final List<String> users = <String>[
        for (final Object? u in reaction['userIds']! as List<Object?>)
          u! as String,
      ];
      if (users.contains(currentUserId)) {
        users.remove(currentUserId);
      } else {
        users.add(currentUserId);
      }
      if (users.isNotEmpty) {
        next.add(<String, Object?>{'emoji': emoji, 'userIds': users});
      }
    }
    if (!found) {
      next.add(<String, Object?>{
        'emoji': emoji,
        'userIds': <String>[currentUserId],
      });
    }
    message['reactions'] = next;
    return Map<String, Object?>.of(message);
  }

  @override
  Future<void> deleteMessage(String conversationId, String messageId) async {
    _messages[conversationId]?.removeWhere(
      (Map<String, Object?> m) => m['id'] == messageId,
    );
    _emitConversation(conversationId);
  }

  @override
  Future<List<Map<String, Object?>>> fetchMedia(String conversationId) async =>
      <Map<String, Object?>>[
        for (final Map<String, Object?> m
            in _messages[conversationId] ?? const <Map<String, Object?>>[])
          if (m['attachment'] != null) Map<String, Object?>.of(m),
      ];

  Map<String, Object?>? _find(String conversationId, String messageId) {
    for (final Map<String, Object?> m
        in _messages[conversationId] ?? const <Map<String, Object?>>[]) {
      if (m['id'] == messageId) return m;
    }
    return null;
  }

  // Real time ---------------------------------------------------------------

  @override
  Stream<Map<String, Object?>> events() => _events.stream;

  void _emit(Map<String, Object?> frame) {
    if (!_disposed) _events.add(frame);
  }

  void _emitConversation(String id) =>
      _emit(<String, Object?>{'type': 'conversation', 'conversationId': id});

  void _later(Duration delay, void Function() action) {
    if (_disposed) return;
    late final Timer timer;
    timer = Timer(delay, () {
      _timers.remove(timer);
      if (!_disposed) action();
    });
    _timers.add(timer);
  }

  // The bot -----------------------------------------------------------------

  /// After [replyLatency]: read receipt, typing, then the reply.
  void _scheduleReply(Map<String, Object?> sent) {
    final String conversationId = sent['conversationId']! as String;
    final Map<String, Object?>? conversation = _conversations[conversationId];
    if (conversation == null) return;
    final List<String> others = <String>[
      for (final Object? id in conversation['memberIds']! as List<Object?>)
        if (id != currentUserId) id! as String,
    ];
    if (others.isEmpty) return;
    final int turn = _botTurn++;
    final String replier = others[turn % others.length];
    final BotReply reply = DemoBot.replyTo(
      (sent['text'] as String?) ?? '',
      turn: turn,
    );

    final Duration readAfter = replyLatency * 0.25;
    final Duration typeAfter = replyLatency * 0.15;
    final Duration answerAfter = replyLatency * 0.6;

    _later(readAfter, () {
      sent['status'] = 'read';
      _emit(<String, Object?>{
        'type': 'message.updated',
        'message': Map<String, Object?>.of(sent),
      });
      _later(typeAfter, () {
        _setReplierOnline(replier);
        _emit(<String, Object?>{
          'type': 'typing',
          'conversationId': conversationId,
          'userId': replier,
          'typing': true,
        });
        _later(answerAfter, () => _deliver(conversationId, replier, reply));
      });
    });
  }

  void _setReplierOnline(String userId) {
    final Map<String, Object?>? contact = _contacts[userId];
    if (contact == null || contact['presence'] == 'online') return;
    contact['presence'] = 'online';
    _emit(<String, Object?>{
      'type': 'presence',
      'contact': Map<String, Object?>.of(contact),
    });
  }

  void _deliver(String conversationId, String sender, BotReply reply) {
    final Map<String, Object?>? conversation = _conversations[conversationId];
    if (conversation == null) return;
    _emit(<String, Object?>{
      'type': 'typing',
      'conversationId': conversationId,
      'userId': sender,
      'typing': false,
    });
    final Map<String, Object?> message = <String, Object?>{
      'id': 'm_${_sequence++}',
      'conversationId': conversationId,
      'senderId': sender,
      'text': reply.text,
      'sentAt': _now().toIso8601String(),
      'status': 'sent',
      'replyTo': null,
      'attachment': reply.photo == null
          ? null
          : <String, Object?>{
              'type': 'image',
              'asset': reply.photo,
              'url': null,
              'name': null,
              'size': null,
              'aspectRatio': 4 / 3,
            },
      'reactions': <Map<String, Object?>>[],
    };
    (_messages[conversationId] ??= <Map<String, Object?>>[]).add(message);
    conversation['unread'] = ((conversation['unread'] as int?) ?? 0) + 1;
    _emit(<String, Object?>{
      'type': 'message',
      'message': Map<String, Object?>.of(message),
    });
    _emitConversation(conversationId);
  }

  @override
  void dispose() {
    _disposed = true;
    for (final Timer t in _timers) {
      t.cancel();
    }
    _timers.clear();
    unawaited(_events.close());
  }
}
