import 'dart:async';

import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/view_model.dart';
import '../../../core/presentation/widgets/page_frame.dart';
import '../../../core/presentation/widgets/themed_overlays.dart';
import '../../../domain/settings/models/settings_section.dart';
import '../../../domain/settings/registry/default_settings_registry.dart';
import '../../../domain/settings/registry/settings_registry.dart';
import '../../settings/bloc/settings_cubit.dart';
import '../../settings/bloc/settings_state.dart';
import '../../settings/widgets/section_blocks.dart';
import '../bloc/account_cubit.dart';
import '../view_models/account_view_model.dart';
import '../widgets/typed_confirm_dialog.dart';

/// Danger zone: sign out of this device, deactivate, or delete the account
/// after typing `DELETE` and confirming a second time.
class DangerView extends StatelessWidget {
  /// Creates the view.
  const DangerView({super.key, required this.onBack});

  /// Called by the back control. `null` hides it.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) => ViewModelBuilder<AccountViewModel>(
    builder: (BuildContext context, AccountViewModel vm) =>
        BlocProvider<AccountCubit>.value(
          value: vm.cubit,
          child: NoticeListener<AccountCubit, AccountState>(
            pick: (AccountState s) => s.notice,
            child: _Body(onBack: onBack),
          ),
        ),
  );
}

class _Body extends StatelessWidget {
  const _Body({required this.onBack});

  final VoidCallback? onBack;

  Future<void> _signOut(BuildContext context) async {
    final AccountCubit cubit = context.read<AccountCubit>();
    final bool sure = await confirmSettingsAction(
      context,
      title: 'Sign out?',
      description: 'You will be signed out of this device only.',
      confirmLabel: 'Sign out',
    );
    if (sure) cubit.signOut();
  }

  Future<void> _deactivate(BuildContext context) async {
    final AccountCubit cubit = context.read<AccountCubit>();
    final bool sure = await confirmSettingsAction(
      context,
      title: 'Deactivate your account?',
      description:
          'Your profile is hidden until you sign in again. Nothing is '
          'deleted.',
      confirmLabel: 'Deactivate',
      destructive: true,
    );
    if (sure) await cubit.deactivate();
  }

  Future<void> _delete(BuildContext context) async {
    final AccountCubit cubit = context.read<AccountCubit>();
    final String? typed = await showSettingsAlert<String>(
      context,
      (BuildContext _) => const TypedConfirmDialog(),
    );
    if (typed == null || !context.mounted) return;
    final bool sure =
        await showSettingsAlert<bool>(
          context,
          (BuildContext _) => const FinalDeleteDialog(),
        ) ??
        false;
    if (sure) await cubit.delete(typed);
  }

  @override
  Widget build(BuildContext context) {
    final SettingsState state = context.watch<SettingsCubit>().state;
    final AccountState account = context.watch<AccountCubit>().state;
    final SettingsRegistry registry = context.read<SettingsRegistry>();
    final bool busy = account.busy != AccountBusy.none;
    return PageFrame(
      title: SettingsSection.danger.title,
      onBack: onBack,
      children: <Widget>[
        const CairnAlert(
          variant: CairnAlertVariant.destructive,
          icon: CairnIcon(CairnIconData.alert),
          title: Text('Be careful here'),
          description: Text(
            'Signing out only affects this device. Deactivating hides your '
            'account. Deleting is permanent.',
          ),
        ),
        if (state.snapshot != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (final (int i, Widget w) in SectionBlocks.build(
                context,
                registry: registry,
                section: SettingsSection.danger,
                snapshot: state.snapshot!,
                onChanged: context.read<SettingsCubit>().set,
                subtitles: <String, String>{
                  if (account.busy == AccountBusy.deactivating)
                    SettingIds.deactivate: 'Deactivating...',
                  if (account.busy == AccountBusy.deleting)
                    SettingIds.deleteAccount: 'Deleting...',
                },
                actions: busy
                    ? const <String, VoidCallback>{}
                    : <String, VoidCallback>{
                        SettingIds.signOut: () => unawaited(_signOut(context)),
                        SettingIds.deactivate: () =>
                            unawaited(_deactivate(context)),
                        SettingIds.deleteAccount: () =>
                            unawaited(_delete(context)),
                      },
              ).indexed) ...<Widget>[if (i > 0) const SizedBox(height: 20), w],
            ],
          ),
      ],
    );
  }
}
