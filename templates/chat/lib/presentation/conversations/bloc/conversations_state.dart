import 'package:equatable/equatable.dart';

import '../../../domain/conversations/models/conversation.dart';
import '../../../domain/conversations/models/conversation_inbox.dart';

/// Where loading the conversation list stands.
enum ConversationsStatus {
  /// Waiting for the first answer; skeletons show.
  loading,

  /// Loaded.
  ready,

  /// The first load failed.
  failed,
}

/// State of the conversation list.
class ConversationsState extends Equatable {
  /// Creates a state.
  const ConversationsState({
    this.status = ConversationsStatus.loading,
    this.inbox = const ConversationInbox(),
    this.query = '',
    this.showArchived = false,
    this.visiblePinned = const <Conversation>[],
    this.visibleOthers = const <Conversation>[],
  });

  /// Loading, ready or failed.
  final ConversationsStatus status;

  /// Everything, in display order.
  final ConversationInbox inbox;

  /// The search text.
  final String query;

  /// Whether the archive is showing instead of the main list.
  final bool showArchived;

  /// Pinned conversations that match the search (empty while viewing the
  /// archive).
  final List<Conversation> visiblePinned;

  /// The rest that match the search (or the archive's matches).
  final List<Conversation> visibleOthers;

  /// Whether the search matched nothing although there is something to match.
  bool get noResults =>
      query.trim().isNotEmpty && visiblePinned.isEmpty && visibleOthers.isEmpty;

  /// Whether the list being shown has no conversations at all.
  bool get isEmpty =>
      query.trim().isEmpty && visiblePinned.isEmpty && visibleOthers.isEmpty;

  /// The conversation with [id], archived or not.
  Conversation? find(String id) {
    for (final Conversation c in <Conversation>[
      ...inbox.active,
      ...inbox.archived,
    ]) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// A copy with some fields replaced.
  ConversationsState copyWith({
    ConversationsStatus? status,
    ConversationInbox? inbox,
    String? query,
    bool? showArchived,
    List<Conversation>? visiblePinned,
    List<Conversation>? visibleOthers,
  }) => ConversationsState(
    status: status ?? this.status,
    inbox: inbox ?? this.inbox,
    query: query ?? this.query,
    showArchived: showArchived ?? this.showArchived,
    visiblePinned: visiblePinned ?? this.visiblePinned,
    visibleOthers: visibleOthers ?? this.visibleOthers,
  );

  @override
  List<Object?> get props => <Object?>[
    status,
    inbox,
    query,
    showArchived,
    visiblePinned,
    visibleOthers,
  ];
}
