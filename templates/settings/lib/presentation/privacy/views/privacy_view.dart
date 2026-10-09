import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/navigation/settings_navigator.dart';
import '../../../core/presentation/navigation/settings_page.dart';
import '../../../core/presentation/view_model.dart';
import '../../../core/presentation/widgets/load_gate.dart';
import '../../../core/presentation/widgets/page_frame.dart';
import '../../../core/presentation/widgets/setting_rows.dart';
import '../../../core/presentation/widgets/themed_overlays.dart';
import '../../../domain/settings/models/setting_definition.dart';
import '../../../domain/settings/models/settings_section.dart';
import '../../../domain/settings/models/settings_snapshot.dart';
import '../../../domain/settings/registry/default_settings_registry.dart';
import '../../../domain/settings/registry/settings_registry.dart';
import '../../settings/bloc/settings_cubit.dart';
import '../../settings/bloc/settings_state.dart';
import '../../settings/widgets/section_blocks.dart';
import '../bloc/privacy_cubit.dart';
import '../view_models/privacy_view_models.dart';
import '../widgets/two_factor_sheet.dart';

/// Privacy and security: biometric lock, two-factor setup, password, sessions,
/// data export and blocked users.
class PrivacyView extends StatelessWidget {
  /// Creates the view.
  const PrivacyView({super.key, required this.onBack});

  /// Called by the back control. `null` hides it.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) => ViewModelBuilder<PrivacyViewModel>(
    builder: (BuildContext context, PrivacyViewModel vm) =>
        BlocProvider<PrivacyCubit>.value(
          value: vm.cubit,
          child: NoticeListener<PrivacyCubit, PrivacyState>(
            pick: (PrivacyState s) => s.notice,
            child: _Body(onBack: onBack),
          ),
        ),
  );
}

class _Body extends StatelessWidget {
  const _Body({required this.onBack});

  final VoidCallback? onBack;

  Future<void> _twoFactor(BuildContext context, bool on) async {
    final SettingsCubit settings = context.read<SettingsCubit>();
    final PrivacyCubit privacy = context.read<PrivacyCubit>();
    if (on) {
      final bool? enrolled = await showSettingsSheet<bool>(
        context,
        (BuildContext _) => const TwoFactorSheet(),
      );
      if (enrolled ?? false) await settings.set(SettingIds.twoFactor, true);
      return;
    }
    if (!context.mounted) return;
    final bool sure = await confirmSettingsAction(
      context,
      title: 'Turn off two-factor authentication?',
      description: 'Your account will be protected by your password alone.',
      confirmLabel: 'Turn off',
      destructive: true,
    );
    if (sure && await privacy.disableTwoFactor()) {
      await settings.set(SettingIds.twoFactor, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final SettingsState state = context.watch<SettingsCubit>().state;
    final PrivacyState privacy = context.watch<PrivacyCubit>().state;
    final SettingsCubit cubit = context.read<SettingsCubit>();
    final SettingsNavigator navigator = context.read<SettingsNavigator>();
    final SettingsRegistry registry = context.read<SettingsRegistry>();
    final SettingsSnapshot? snapshot = state.snapshot;
    final bool exporting = privacy.exportStatus == ExportStatus.requesting;
    final bool exported = privacy.exportStatus == ExportStatus.requested;
    return PageFrame(
      title: SettingsSection.privacy.title,
      onBack: onBack,
      children: <Widget>[
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
                      section: SettingsSection.privacy,
                      snapshot: snapshot,
                      onChanged: cubit.set,
                      subtitles: <String, String>{
                        if (exporting) SettingIds.exportData: 'Requesting...',
                        if (exported)
                          SettingIds.exportData:
                              'Requested. We will email you a download link.',
                      },
                      actions: <String, VoidCallback>{
                        SettingIds.changePassword: () =>
                            navigator.open(SettingsPage.changePassword),
                        SettingIds.sessions: () =>
                            navigator.open(SettingsPage.sessions),
                        SettingIds.blockedUsers: () =>
                            navigator.open(SettingsPage.blockedUsers),
                        if (!exporting && !exported)
                          SettingIds.exportData: () => unawaited(
                            context.read<PrivacyCubit>().requestExport(),
                          ),
                      },
                      custom: <String, SettingRowBuilder>{
                        SettingIds.twoFactor:
                            (BuildContext c, SettingDefinition d) => ToggleRow(
                              title: d.title,
                              subtitle: d.description,
                              value: snapshot.flag(d.id),
                              onChanged: (bool v) =>
                                  unawaited(_twoFactor(c, v)),
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
