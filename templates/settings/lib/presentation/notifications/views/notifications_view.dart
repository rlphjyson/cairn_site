import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/widgets/load_gate.dart';
import '../../../core/presentation/widgets/page_frame.dart';
import '../../../core/presentation/widgets/setting_rows.dart';
import '../../../core/presentation/widgets/themed_overlays.dart';
import '../../../domain/settings/models/notification_permission.dart';
import '../../../domain/settings/models/setting_definition.dart';
import '../../../domain/settings/models/settings_section.dart';
import '../../../domain/settings/models/settings_snapshot.dart';
import '../../../domain/settings/registry/default_settings_registry.dart';
import '../../../domain/settings/registry/settings_registry.dart';
import '../../settings/bloc/settings_cubit.dart';
import '../../settings/bloc/settings_state.dart';
import '../../settings/widgets/section_blocks.dart';

/// Notifications: a master switch, what to be told about, how, and quiet hours.
///
/// When the master switch is off, everything under it is greyed out and cannot
/// be changed. When the operating system has refused permission, an alert says
/// so and offers to open the system settings.
class NotificationsView extends StatelessWidget {
  /// Creates the view.
  const NotificationsView({super.key, required this.onBack});

  /// Called by the back control. `null` hides it.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final SettingsState state = context.watch<SettingsCubit>().state;
    final SettingsCubit cubit = context.read<SettingsCubit>();
    final SettingsRegistry registry = context.read<SettingsRegistry>();
    final SettingsSnapshot? snapshot = state.snapshot;
    final bool denied =
        state.notificationPermission == NotificationPermission.denied;
    final bool masterOn =
        snapshot != null &&
        snapshot.flag(SettingIds.notificationsMaster) &&
        !denied;
    final bool quiet = snapshot?.flag(SettingIds.quietHours) ?? false;
    return PageFrame(
      title: SettingsSection.notifications.title,
      onBack: onBack,
      children: <Widget>[
        if (denied)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const CairnAlert(
                variant: CairnAlertVariant.destructive,
                icon: CairnIcon(CairnIconData.alert),
                title: Text('Notifications are blocked'),
                description: Text(
                  'You turned them off for this app in your phone settings. '
                  'Allow them there to get notifications again.',
                ),
              ),
              const SizedBox(height: 12),
              DialogButton(
                label: 'Open settings',
                variant: CairnButtonVariant.outline,
                onPressed: cubit.openSystemSettings,
              ),
            ],
          ),
        LoadGate(
          status: state.status,
          onRetry: cubit.load,
          rows: 4,
          child: snapshot == null
              ? const SizedBox.shrink()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    for (final (int i, Widget w) in SectionBlocks.build(
                      context,
                      registry: registry,
                      section: SettingsSection.notifications,
                      snapshot: snapshot,
                      onChanged: cubit.set,
                      enabled: (SettingDefinition d) {
                        if (d.id == SettingIds.notificationsMaster) {
                          return !denied;
                        }
                        if (d.id == SettingIds.quietStart ||
                            d.id == SettingIds.quietEnd) {
                          return masterOn && quiet;
                        }
                        return masterOn;
                      },
                      custom: <String, SettingRowBuilder>{
                        SettingIds.notificationsMaster:
                            (BuildContext c, SettingDefinition d) => ToggleRow(
                              title: d.title,
                              subtitle: d.description,
                              value: masterOn,
                              onChanged: denied
                                  ? null
                                  : cubit.setNotificationsEnabled,
                            ),
                      },
                    ).indexed) ...<Widget>[
                      if (i > 0) const SizedBox(height: 20),
                      w,
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}
