import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/navigation/chat_navigation_cubit.dart';
import '../../../core/presentation/widgets/confirm_dialog.dart';
import '../../../domain/conversations/models/conversation.dart';
import '../bloc/conversations_cubit.dart';

/// Deletes a conversation after asking, closes anything showing it and
/// confirms with a toast.
Future<void> deleteConversationWithConfirm(
  BuildContext context,
  Conversation conversation,
) async {
  final ConversationsCubit cubit = context.read<ConversationsCubit>();
  final ChatNavigationCubit nav = context.read<ChatNavigationCubit>();
  final bool confirmed = await confirmAction(
    context,
    title: 'Delete this chat?',
    description:
        'The conversation with ${conversation.title} and all its messages '
        'will be removed from this device. This cannot be undone.',
    confirmLabel: 'Delete',
  );
  if (!confirmed) return;
  await cubit.delete(conversation);
  // Toast before closing the screen: the toast needs this context alive.
  if (context.mounted) {
    CairnToast.show(
      context,
      CairnToast(
        title: 'Chat deleted',
        description: conversation.title,
        variant: CairnToastVariant.success,
      ),
    );
  }
  nav.closeConversation(conversation.id);
}

/// Runs [action] once the menu that triggered it has finished closing.
///
/// A menu closes itself a frame after an item is pressed. An action such as
/// pin or archive moves or removes the row that owns the menu, so running it
/// first would dispose the menu while it is still closing.
void _afterMenuCloses(VoidCallback action) {
  final SchedulerBinding binding = SchedulerBinding.instance;
  binding.addPostFrameCallback((_) {
    binding.addPostFrameCallback((_) => action());
    binding.ensureVisualUpdate();
  });
  binding.ensureVisualUpdate();
}

/// The actions every conversation offers, as menu items: pin, mute, mark
/// read or unread, archive and delete (which asks first).
///
/// Used by the list's long-press and overflow menus and by the thread header.
List<Widget> conversationMenuItems(
  BuildContext context,
  Conversation conversation,
) {
  final ConversationsCubit cubit = context.read<ConversationsCubit>();
  final Conversation c = conversation;
  return <Widget>[
    CairnMenuItem(
      leading: Icon(c.pinned ? Icons.push_pin : Icons.push_pin_outlined),
      onPressed: () =>
          _afterMenuCloses(() => cubit.setPinned(c, pinned: !c.pinned)),
      child: Text(c.pinned ? 'Unpin' : 'Pin'),
    ),
    CairnMenuItem(
      leading: Icon(
        c.muted
            ? Icons.notifications_outlined
            : Icons.notifications_off_outlined,
      ),
      onPressed: () =>
          _afterMenuCloses(() => cubit.setMuted(c, muted: !c.muted)),
      child: Text(c.muted ? 'Unmute' : 'Mute'),
    ),
    CairnMenuItem(
      leading: Icon(
        c.hasUnread
            ? Icons.mark_chat_read_outlined
            : Icons.mark_chat_unread_outlined,
      ),
      onPressed: () => _afterMenuCloses(
        () => cubit.setMarkedUnread(c, unread: !c.hasUnread),
      ),
      child: Text(c.hasUnread ? 'Mark as read' : 'Mark as unread'),
    ),
    CairnMenuItem(
      leading: Icon(
        c.archived ? Icons.unarchive_outlined : Icons.archive_outlined,
      ),
      onPressed: () =>
          _afterMenuCloses(() => cubit.setArchived(c, archived: !c.archived)),
      child: Text(c.archived ? 'Unarchive' : 'Archive'),
    ),
    const CairnMenuSeparator(),
    CairnMenuItem(
      variant: CairnMenuItemVariant.destructive,
      leading: const Icon(Icons.delete_outline),
      onPressed: () =>
          _afterMenuCloses(() => deleteConversationWithConfirm(context, c)),
      child: const Text('Delete'),
    ),
  ];
}
