import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/constants/chat_limits.dart';
import '../../../core/presentation/chat_text.dart';
import '../../../core/presentation/navigation/chat_navigation_cubit.dart';
import '../../../core/presentation/view_model.dart';
import '../../../core/presentation/widgets/chat_empty.dart';
import '../../../core/presentation/widgets/chat_header.dart';
import '../../../core/presentation/widgets/contact_sections.dart';
import '../../../core/presentation/widgets/search_field.dart';
import '../../../domain/contacts/models/contact.dart';
import '../../../domain/conversations/use_cases/create_group.dart';
import '../bloc/new_chat_cubit.dart';
import '../view_models/new_chat_view_model.dart';

/// Start a conversation: find a person and open a chat, or switch to group
/// mode, pick several people, name the group and create it.
class NewChatView extends StatelessWidget {
  /// Creates the screen; [group] starts in group mode.
  const NewChatView({super.key, this.group = false});

  /// Whether to start in group mode.
  final bool group;

  @override
  Widget build(BuildContext context) => ViewModelBuilder<NewChatViewModel>(
    onCreate: (BuildContext context, NewChatViewModel vm) =>
        vm.cubit.load(group: group),
    builder: (BuildContext context, NewChatViewModel vm) =>
        BlocProvider<NewChatCubit>.value(
          value: vm.cubit,
          child: const _NewChatBody(),
        ),
  );
}

class _NewChatBody extends StatelessWidget {
  const _NewChatBody();

  Future<void> _create(BuildContext context) async {
    final NewChatCubit cubit = context.read<NewChatCubit>();
    final ChatNavigationCubit nav = context.read<ChatNavigationCubit>();
    final String name = cubit.state.groupName.trim();
    final String? id = await cubit.createGroup();
    if (id == null || !context.mounted) return;
    CairnToast.show(
      context,
      CairnToast(
        title: 'Group created',
        description: name,
        variant: CairnToastVariant.success,
      ),
    );
    nav.openThread(id);
  }

  @override
  Widget build(BuildContext context) {
    final NewChatCubit cubit = context.read<NewChatCubit>();
    final ChatNavigationCubit nav = context.read<ChatNavigationCubit>();
    return BlocBuilder<NewChatCubit, NewChatState>(
      builder: (BuildContext context, NewChatState state) {
        final Set<String> picked = state.selected.toSet();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ChatHeader(
              title: state.group ? 'New group' : 'New chat',
              subtitle: state.group
                  ? Text(
                      picked.isEmpty
                          ? 'Choose at least two people'
                          : '${picked.length} selected',
                    )
                  : null,
              backLabel: 'Close',
              onBack: nav.back,
            ),
            if (state.group)
              _GroupDetails(
                state: state,
                onName: cubit.setGroupName,
                onRemove: cubit.toggle,
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: SearchField(
                placeholder: 'Search contacts',
                text: state.query,
                onChanged: cubit.search,
              ),
            ),
            Expanded(
              child: !state.loaded
                  ? const Center(child: CairnSpinner(size: 24))
                  : state.sections.isEmpty
                  ? ChatEmpty(
                      icon: Icons.person_search_outlined,
                      title: 'No contacts found',
                      description: state.query.trim().isEmpty
                          ? 'There is nobody to message yet.'
                          : 'Nothing matches "${state.query.trim()}".',
                    )
                  : ContactSectionList(
                      sections: state.sections,
                      selected: picked,
                      header: state.group || state.query.trim().isNotEmpty
                          ? null
                          : _NewGroupRow(
                              onTap: () => cubit.setGroupMode(group: true),
                            ),
                      trailing: state.group
                          ? (Contact c) => CairnCheckbox(
                              value: picked.contains(c.id),
                              semanticLabel: 'Select ${c.name}',
                              onChanged: (bool? _) => cubit.toggle(c),
                            )
                          : null,
                      onTap: (Contact c) async {
                        if (state.group) {
                          cubit.toggle(c);
                          return;
                        }
                        final String? id = await cubit.startDirect(c);
                        if (id != null) nav.openThread(id);
                      },
                    ),
            ),
            if (state.group)
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: CairnTheme.of(context).border),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: CairnButton(
                    expand: true,
                    onPressed: state.busy ? null : () => _create(context),
                    child: Text(
                      picked.isEmpty
                          ? 'Create group'
                          : 'Create group (${picked.length})',
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _NewGroupRow extends StatelessWidget {
  const _NewGroupRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return CairnList(
      children: <Widget>[
        CairnListItem(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.primary,
            ),
            child: Icon(
              Icons.group_add_outlined,
              color: theme.primaryForeground,
            ),
          ),
          title: const Text('New group'),
          subtitle: const Text('Pick two or more people'),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      ],
    );
  }
}

class _GroupDetails extends StatefulWidget {
  const _GroupDetails({
    required this.state,
    required this.onName,
    required this.onRemove,
  });

  final NewChatState state;
  final ValueChanged<String> onName;
  final ValueChanged<Contact> onRemove;

  @override
  State<_GroupDetails> createState() => _GroupDetailsState();
}

class _GroupDetailsState extends State<_GroupDetails> {
  final TextEditingController _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final NewChatState state = widget.state;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: <Widget>[
          CairnInput(
            controller: _name,
            placeholder: 'Group name',
            semanticLabel: 'Group name',
            maxLength: ChatLimits.groupNameMaxLength,
            hasError:
                state.problem == GroupProblem.nameRequired ||
                state.problem == GroupProblem.nameTooLong,
            leading: const Icon(Icons.group_outlined),
            onChanged: widget.onName,
          ),
          if (state.selectedContacts.isNotEmpty)
            Wrap(
              spacing: 6,
              children: <Widget>[
                for (final Contact c in state.selectedContacts)
                  GestureDetector(
                    onTap: () => widget.onRemove(c),
                    behavior: HitTestBehavior.opaque,
                    child: Semantics(
                      button: true,
                      label: 'Remove ${c.name}',
                      excludeSemantics: true,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: CairnBadge(
                          variant: CairnBadgeVariant.secondary,
                          label: Text(c.name.split(' ').first),
                          trailing: const Icon(Icons.close),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          if (state.problem != null)
            Semantics(
              liveRegion: true,
              child: Text(
                state.problem!.message,
                style: chatText(
                  theme,
                  theme.textStyle(CairnTypography.xs),
                  color: theme.destructive,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
