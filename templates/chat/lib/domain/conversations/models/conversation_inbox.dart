import 'package:equatable/equatable.dart';

import 'conversation.dart';

/// All conversations, split into the main list and the archive, both already
/// in display order (pinned first, then newest activity first).
class ConversationInbox extends Equatable {
  /// Creates an inbox.
  const ConversationInbox({
    this.active = const <Conversation>[],
    this.archived = const <Conversation>[],
  });

  /// The main list.
  final List<Conversation> active;

  /// The archive.
  final List<Conversation> archived;

  /// The conversations that are pinned, in order.
  List<Conversation> get pinned =>
      active.where((Conversation c) => c.pinned).toList();

  /// The conversations that are not pinned, in order.
  List<Conversation> get others =>
      active.where((Conversation c) => !c.pinned).toList();

  /// Unread messages that should draw attention: from conversations that are
  /// neither muted nor archived. A conversation you marked unread counts as
  /// one.
  int get unreadTotal => active
      .where((Conversation c) => !c.muted)
      .fold<int>(
        0,
        (int sum, Conversation c) =>
            sum + (c.unread > 0 ? c.unread : (c.markedUnread ? 1 : 0)),
      );

  @override
  List<Object?> get props => <Object?>[active, archived];
}
