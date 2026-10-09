import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../domain/contacts/models/contact.dart';
import '../chat_text.dart';
import 'chat_avatar.dart';

/// Contacts in alphabetical sections: a letter, then the people under it.
///
/// Shared by the Contacts tab and the new chat screen. [trailing] draws
/// something at the end of each row (a check box when picking a group), and
/// [selected] highlights picked people.
class ContactSectionList extends StatelessWidget {
  /// Creates the list.
  const ContactSectionList({
    super.key,
    required this.sections,
    required this.onTap,
    this.trailing,
    this.selected = const <String>{},
    this.header,
  });

  /// The sections to show.
  final List<ContactSection> sections;

  /// Called with the tapped person.
  final ValueChanged<Contact> onTap;

  /// Builds the end of a row.
  final Widget Function(Contact contact)? trailing;

  /// Ids drawn as selected.
  final Set<String> selected;

  /// A widget above the first section.
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: <Widget>[
        ?header,
        for (final ContactSection section in sections) ...<Widget>[
          Semantics(
            header: true,
            child: Container(
              color: theme.muted.withValues(alpha: 0.5),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Text(
                section.letter,
                style: chatText(
                  theme,
                  theme.textStyle(CairnTypography.xs),
                  color: theme.mutedForeground,
                  weight: CairnTypography.semibold,
                ),
              ),
            ),
          ),
          CairnList(
            children: <Widget>[
              for (final Contact contact in section.contacts)
                CairnListItem(
                  selected: selected.contains(contact.id),
                  leading: ChatAvatar(
                    name: contact.name,
                    avatar: contact.avatar,
                    presence: contact.presence,
                  ),
                  title: Text(
                    contact.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    contact.about,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: trailing?.call(contact),
                  onTap: () => onTap(contact),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
