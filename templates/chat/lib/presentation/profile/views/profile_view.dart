import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/chat_text.dart';
import '../../../core/presentation/widgets/chat_avatar.dart';
import '../../../core/presentation/widgets/presence_dot.dart';
import '../../../core/presentation/widgets/screen_title.dart';
import '../../../domain/contacts/models/contact.dart';
import '../../../domain/contacts/models/presence.dart';
import '../bloc/profile_cubit.dart';
import '../widgets/editable_field.dart';

/// The Profile tab: your avatar, name and status line (both editable), an
/// availability selector and a few settings.
class ProfileView extends StatelessWidget {
  /// Creates the view.
  const ProfileView({super.key});

  static const List<Presence> _choices = <Presence>[
    Presence.online,
    Presence.away,
    Presence.doNotDisturb,
  ];

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final ProfileCubit cubit = context.read<ProfileCubit>();
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (BuildContext context, ProfileState state) {
        final Contact? me = state.me;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const ScreenTitle('Profile'),
            Expanded(
              child: me == null
                  ? const Center(child: CairnSpinner(size: 24))
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      children: <Widget>[
                        Center(
                          child: ExcludeSemantics(
                            child: SizedBox.square(
                              dimension: 80,
                              child: FittedBox(
                                child: ChatAvatar(
                                  name: me.name,
                                  avatar: me.avatar,
                                  presence: me.presence,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            me.name,
                            style: chatText(
                              theme,
                              theme.textStyle(CairnTypography.xl),
                              weight: CairnTypography.semibold,
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            me.presence.label,
                            style: chatText(
                              theme,
                              theme.textStyle(CairnTypography.sm),
                              color: theme.mutedForeground,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const _Label('Your details'),
                        EditableField(
                          label: 'Name',
                          value: me.name,
                          onSave: cubit.saveName,
                        ),
                        const SizedBox(height: 12),
                        EditableField(
                          label: 'About',
                          value: me.about,
                          onSave: cubit.saveAbout,
                        ),
                        const SizedBox(height: 24),
                        const _Label('Availability'),
                        CairnList(
                          bordered: true,
                          children: <Widget>[
                            for (final Presence p in _choices)
                              CairnListItem(
                                selected: me.presence == p,
                                leading: SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: Center(
                                    child: PresenceDot(p, size: 12),
                                  ),
                                ),
                                title: Text(p.label),
                                trailing: me.presence == p
                                    ? const Icon(Icons.check)
                                    : null,
                                onTap: () => cubit.setPresence(p),
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const _Label('Settings'),
                        CairnList(
                          bordered: true,
                          children: <Widget>[
                            _SwitchRow(
                              icon: Icons.notifications_outlined,
                              title: 'Notifications',
                              value: state.notifications,
                              onChanged: (bool v) =>
                                  cubit.setNotifications(value: v),
                            ),
                            _SwitchRow(
                              icon: Icons.visibility_outlined,
                              title: 'Message previews',
                              value: state.previews,
                              onChanged: (bool v) =>
                                  cubit.setPreviews(value: v),
                            ),
                            _SwitchRow(
                              icon: Icons.done_all,
                              title: 'Read receipts',
                              value: state.readReceipts,
                              onChanged: (bool v) =>
                                  cubit.setReadReceipts(value: v),
                            ),
                            _SwitchRow(
                              icon: Icons.keyboard_return,
                              title: 'Enter key sends',
                              value: state.enterToSend,
                              onChanged: (bool v) =>
                                  cubit.setEnterToSend(value: v),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

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

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => CairnListItem(
    leading: Icon(icon),
    title: Text(title),
    trailing: CairnSwitch(
      value: value,
      semanticLabel: title,
      onChanged: onChanged,
    ),
    onTap: () => onChanged(!value),
  );
}
