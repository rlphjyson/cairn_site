import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/navigation/chat_navigation_cubit.dart';
import '../../../core/presentation/widgets/chat_empty.dart';
import '../../../core/presentation/widgets/contact_sections.dart';
import '../../../core/presentation/widgets/icon_action.dart';
import '../../../core/presentation/widgets/screen_title.dart';
import '../../../core/presentation/widgets/search_field.dart';
import '../../../domain/contacts/models/contact.dart';
import '../bloc/contacts_cubit.dart';

/// The Contacts tab: everyone you can message, in alphabetical sections.
/// Tapping a person opens (or starts) your conversation with them.
class ContactsView extends StatelessWidget {
  /// Creates the view.
  const ContactsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ContactsCubit cubit = context.read<ContactsCubit>();
    final ChatNavigationCubit nav = context.read<ChatNavigationCubit>();
    return BlocBuilder<ContactsCubit, ContactsState>(
      builder: (BuildContext context, ContactsState state) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ScreenTitle(
            'Contacts',
            actions: <Widget>[
              IconAction(
                icon: Icons.group_add_outlined,
                label: 'New group',
                onPressed: () => nav.openNewChat(group: true),
              ),
            ],
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
                    title: state.query.trim().isEmpty
                        ? 'No contacts yet'
                        : 'No contacts found',
                    description: state.query.trim().isEmpty
                        ? 'People you can message will appear here.'
                        : 'Nothing matches "${state.query.trim()}".',
                  )
                : ContactSectionList(
                    sections: state.sections,
                    onTap: (Contact c) async {
                      final String? id = await cubit.openChat(c);
                      if (id != null) nav.openThread(id);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
