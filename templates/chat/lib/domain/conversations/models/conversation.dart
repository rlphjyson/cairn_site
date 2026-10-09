import 'package:equatable/equatable.dart';

import '../../messages/models/message.dart';

/// A chat with one person or with a group.
enum ConversationKind {
  /// Two people.
  direct('direct'),

  /// Three or more.
  group('group');

  const ConversationKind(this.wire);

  /// The value used in JSON.
  final String wire;

  /// Reads the JSON value, treating anything unknown as [direct].
  static ConversationKind fromWire(Object? value) =>
      ConversationKind.values.firstWhere(
        (ConversationKind k) => k.wire == value,
        orElse: () => ConversationKind.direct,
      );
}

/// An entry of the conversation list.
class Conversation extends Equatable {
  /// Creates a conversation.
  const Conversation({
    required this.id,
    required this.kind,
    required this.title,
    required this.memberIds,
    required this.updatedAt,
    this.avatar,
    this.peerId,
    this.pinned = false,
    this.muted = false,
    this.archived = false,
    this.markedUnread = false,
    this.unread = 0,
    this.lastMessage,
  });

  /// A stable identifier.
  final String id;

  /// One person or a group.
  final ConversationKind kind;

  /// The other person's name, or the group's.
  final String title;

  /// The other person's avatar (an asset path or URL); `null` shows initials
  /// or, for a group, a group glyph.
  final String? avatar;

  /// The other person, for a direct conversation.
  final String? peerId;

  /// Everyone in the conversation, you included.
  final List<String> memberIds;

  /// When something last happened here; the list is ordered by it.
  final DateTime updatedAt;

  /// Kept at the top of the list.
  final bool pinned;

  /// No notifications, and the unread badge is quiet.
  final bool muted;

  /// Moved out of the main list.
  final bool archived;

  /// You flagged it to come back to, although everything is read.
  final bool markedUnread;

  /// Messages you have not read.
  final int unread;

  /// The newest message, for the preview.
  final Message? lastMessage;

  /// Whether this is a group.
  bool get isGroup => kind == ConversationKind.group;

  /// Whether to show an unread badge.
  bool get hasUnread => unread > 0 || markedUnread;

  /// A copy with some fields replaced.
  Conversation copyWith({
    String? title,
    bool? pinned,
    bool? muted,
    bool? archived,
    bool? markedUnread,
    int? unread,
    DateTime? updatedAt,
    Message? lastMessage,
  }) => Conversation(
    id: id,
    kind: kind,
    title: title ?? this.title,
    avatar: avatar,
    peerId: peerId,
    memberIds: memberIds,
    updatedAt: updatedAt ?? this.updatedAt,
    pinned: pinned ?? this.pinned,
    muted: muted ?? this.muted,
    archived: archived ?? this.archived,
    markedUnread: markedUnread ?? this.markedUnread,
    unread: unread ?? this.unread,
    lastMessage: lastMessage ?? this.lastMessage,
  );

  @override
  List<Object?> get props => <Object?>[
    id,
    kind,
    title,
    avatar,
    peerId,
    memberIds,
    updatedAt,
    pinned,
    muted,
    archived,
    markedUnread,
    unread,
    lastMessage,
  ];
}
