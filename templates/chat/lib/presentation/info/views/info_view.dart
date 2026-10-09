import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/infrastructure/chat_session.dart';
import '../../../core/presentation/chat_images.dart';
import '../../../core/presentation/chat_text.dart';
import '../../../core/presentation/navigation/chat_navigation_cubit.dart';
import '../../../core/presentation/view_model.dart';
import '../../../core/presentation/widgets/chat_avatar.dart';
import '../../../core/presentation/widgets/chat_empty.dart';
import '../../../core/presentation/widgets/chat_header.dart';
import '../../../core/presentation/widgets/confirm_dialog.dart';
import '../../../domain/contacts/models/contact.dart';
import '../../../domain/contacts/models/presence.dart';
import '../../../domain/conversations/models/conversation.dart';
import '../../../domain/conversations/use_cases/format_relative_time.dart';
import '../../../domain/messages/models/message.dart';
import '../../contacts/bloc/contacts_cubit.dart';
import '../bloc/info_cubit.dart';
import '../view_models/info_view_model.dart';

/// Contact or group details: avatar, status, shared photos, mute switch, the
/// members of a group, and leave or block.
class InfoView extends StatelessWidget {
  /// Creates the screen for [conversationId].
  const InfoView({super.key, required this.conversationId});

  /// The conversation to describe.
  final String conversationId;

  @override
  Widget build(BuildContext context) => ViewModelBuilder<InfoViewModel>(
    onCreate: (BuildContext context, InfoViewModel vm) =>
        vm.cubit.load(conversationId),
    builder: (BuildContext context, InfoViewModel vm) =>
        BlocProvider<InfoCubit>.value(
          value: vm.cubit,
          child: const _InfoBody(),
        ),
  );
}

class _InfoBody extends StatelessWidget {
  const _InfoBody();

  Future<void> _leave(BuildContext context, Conversation c) async {
    final InfoCubit cubit = context.read<InfoCubit>();
    final ChatNavigationCubit nav = context.read<ChatNavigationCubit>();
    final bool ok = await confirmAction(
      context,
      title: 'Leave ${c.title}?',
      description:
          'You will stop receiving messages from this group and it will '
          'disappear from your chats.',
      confirmLabel: 'Leave group',
    );
    if (!ok || !context.mounted) return;
    await cubit.leaveGroup();
    if (!context.mounted) return;
    CairnToast.show(
      context,
      CairnToast(title: 'You left the group', description: c.title),
    );
    nav.closeConversation(c.id);
  }

  Future<void> _block(
    BuildContext context,
    Conversation c,
    Contact peer,
  ) async {
    final InfoCubit cubit = context.read<InfoCubit>();
    final ChatNavigationCubit nav = context.read<ChatNavigationCubit>();
    final ContactsCubit contacts = context.read<ContactsCubit>();
    final bool ok = await confirmAction(
      context,
      title: 'Block ${peer.name}?',
      description:
          'They will be removed from your contacts and this conversation will '
          'be deleted.',
      confirmLabel: 'Block',
    );
    if (!ok || !context.mounted) return;
    await cubit.blockPeer();
    await contacts.load();
    if (!context.mounted) return;
    CairnToast.show(context, CairnToast(title: '${peer.name} is blocked'));
    nav.closeConversation(c.id);
  }

  @override
  Widget build(BuildContext context) {
    final ChatNavigationCubit nav = context.read<ChatNavigationCubit>();
    final ChatSession session = ChatSessionScope.of(context);
    final CairnTheme theme = CairnTheme.of(context);
    final ContactsState contactsState = context.watch<ContactsCubit>().state;

    return BlocBuilder<InfoCubit, InfoState>(
      builder: (BuildContext context, InfoState state) {
        final Conversation? c = state.conversation;
        final bool group = c?.isGroup ?? false;
        // A direct chat's presence may change while the screen is open.
        final Contact? peer = state.peer == null
            ? null
            : contactsState.byId(state.peer!.id) ?? state.peer;

        Widget body;
        if (!state.loaded) {
          body = const Center(child: CairnSpinner(size: 24));
        } else if (c == null) {
          body = const ChatEmpty(
            icon: Icons.chat_bubble_outline,
            title: 'Conversation not found',
            description: 'It may have been deleted.',
          );
        } else {
          body = ListView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            children: <Widget>[
              _Identity(
                conversation: c,
                peer: peer,
                state: state,
                session: session,
              ),
              const SizedBox(height: 24),
              CairnList(
                bordered: true,
                children: <Widget>[
                  CairnListItem(
                    leading: const Icon(Icons.notifications_off_outlined),
                    title: const Text('Mute notifications'),
                    trailing: CairnSwitch(
                      value: c.muted,
                      semanticLabel: 'Mute notifications',
                      onChanged: (bool v) =>
                          context.read<InfoCubit>().setMuted(muted: v),
                    ),
                    onTap: () =>
                        context.read<InfoCubit>().setMuted(muted: !c.muted),
                  ),
                  CairnListItem(
                    leading: const Icon(Icons.photo_library_outlined),
                    title: const Text('Media'),
                    trailing: Text(
                      state.media.isEmpty
                          ? 'None'
                          : '${state.media.length} '
                                '${state.media.length == 1 ? 'photo' : 'photos'}',
                    ),
                  ),
                ],
              ),
              if (state.media.isNotEmpty) ...<Widget>[
                const SizedBox(height: 12),
                _MediaGrid(media: state.media),
              ],
              if (group) ...<Widget>[
                const SizedBox(height: 24),
                _SectionLabel('Members (${c.memberIds.length})'),
                CairnList(
                  bordered: true,
                  children: <Widget>[
                    if (state.me != null)
                      _MemberRow(contact: state.me!, you: true),
                    for (final Contact m in state.members)
                      _MemberRow(
                        contact: contactsState.byId(m.id) ?? m,
                        you: false,
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              if (group)
                CairnButton(
                  expand: true,
                  variant: CairnButtonVariant.destructive,
                  leading: const Icon(Icons.logout),
                  onPressed: () => _leave(context, c),
                  child: const Text('Leave group'),
                )
              else if (peer != null)
                CairnButton(
                  expand: true,
                  variant: CairnButtonVariant.destructive,
                  leading: const Icon(Icons.block),
                  onPressed: () => _block(context, c, peer),
                  child: Text('Block ${peer.name.split(' ').first}'),
                ),
              if (!group && peer != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Blocked people cannot message you and are removed from '
                    'your contacts.',
                    textAlign: TextAlign.center,
                    style: chatText(
                      theme,
                      theme.textStyle(CairnTypography.xs),
                      color: theme.mutedForeground,
                    ),
                  ),
                ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ChatHeader(
              title: group ? 'Group info' : 'Contact info',
              backLabel: 'Back',
              onBack: nav.back,
            ),
            Expanded(child: body),
          ],
        );
      },
    );
  }
}

class _Identity extends StatelessWidget {
  const _Identity({
    required this.conversation,
    required this.peer,
    required this.state,
    required this.session,
  });

  final Conversation conversation;
  final Contact? peer;
  final InfoState state;
  final ChatSession session;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final Conversation c = conversation;
    final TextStyle muted = chatText(
      theme,
      theme.textStyle(CairnTypography.sm),
      color: theme.mutedForeground,
    );
    String status = '';
    if (c.isGroup) {
      status = 'Group - ${c.memberIds.length} members';
    } else if (peer != null) {
      status = peer!.presence != Presence.offline
          ? peer!.presence.label
          : (peer!.lastSeen == null
                ? 'Offline'
                : const FormatRelativeTime().lastSeen(
                    peer!.lastSeen!,
                    session.now(),
                  ));
    }
    return Column(
      children: <Widget>[
        Semantics(
          label: c.title,
          image: true,
          child: ExcludeSemantics(
            child: SizedBox.square(
              dimension: 88,
              child: FittedBox(
                child: ChatAvatar(
                  name: c.title,
                  avatar: c.avatar,
                  group: c.isGroup,
                  presence: peer?.presence,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Semantics(
          header: true,
          child: Text(
            c.title,
            textAlign: TextAlign.center,
            style: chatText(
              theme,
              theme.textStyle(CairnTypography.xl),
              weight: CairnTypography.semibold,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(status, style: muted, textAlign: TextAlign.center),
        if (!c.isGroup && (peer?.about.isNotEmpty ?? false)) ...<Widget>[
          const SizedBox(height: 8),
          Text(
            peer!.about,
            textAlign: TextAlign.center,
            style: chatText(theme, theme.textStyle(CairnTypography.sm)),
          ),
        ],
        if (c.isGroup && state.members.isNotEmpty) ...<Widget>[
          const SizedBox(height: 12),
          CairnAvatarGroup(
            size: CairnAvatarSize.lg,
            children: <Widget>[
              for (final Contact m in state.members.take(4))
                ChatAvatar(name: m.name, avatar: m.avatar),
            ],
          ),
        ],
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Semantics(
        header: true,
        child: Text(
          text,
          style: chatText(
            theme,
            theme.textStyle(CairnTypography.sm),
            weight: CairnTypography.semibold,
          ),
        ),
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.contact, required this.you});

  final Contact contact;
  final bool you;

  @override
  Widget build(BuildContext context) => CairnListItem(
    leading: ChatAvatar(
      name: contact.name,
      avatar: contact.avatar,
      presence: contact.presence,
    ),
    title: Text(
      you ? '${contact.name} (You)' : contact.name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
    subtitle: Text(contact.about, maxLines: 1, overflow: TextOverflow.ellipsis),
  );
}

class _MediaGrid extends StatelessWidget {
  const _MediaGrid({required this.media});

  final List<Message> media;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        const double gap = 6;
        final int columns = box.maxWidth >= 360 ? 4 : 3;
        final double cell = (box.maxWidth - gap * (columns - 1)) / columns;
        final List<Message> shown = media.take(columns * 2).toList();
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: <Widget>[
            for (final Message m in shown)
              ClipRRect(
                borderRadius: BorderRadius.circular(theme.radiusScale.md),
                child: SizedBox.square(
                  dimension: cell,
                  child: Image(
                    image: chatImage(
                      m.attachment?.asset ?? m.attachment?.url ?? '',
                    ),
                    fit: BoxFit.cover,
                    semanticLabel: 'Shared photo',
                    errorBuilder:
                        (BuildContext context, Object error, StackTrace? s) =>
                            ColoredBox(color: theme.muted),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
