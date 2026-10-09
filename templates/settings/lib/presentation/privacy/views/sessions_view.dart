import 'dart:async';

import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/utils/relative_time.dart';
import '../../../core/presentation/load_status.dart';
import '../../../core/presentation/view_model.dart';
import '../../../core/presentation/widgets/action_row.dart';
import '../../../core/presentation/widgets/load_gate.dart';
import '../../../core/presentation/widgets/page_frame.dart';
import '../../../core/presentation/widgets/setting_rows.dart';
import '../../../core/presentation/widgets/themed_overlays.dart';
import '../../../core/presentation/widgets/touch_target.dart';
import '../../../domain/security/models/device_session.dart';
import '../bloc/sessions_cubit.dart';
import '../view_models/privacy_view_models.dart';

/// Active sessions: every signed-in device, with a Sign out button on each other
/// device and one to sign all of them out at once.
class SessionsView extends StatelessWidget {
  /// Creates the view.
  const SessionsView({super.key, required this.onBack});

  /// Called by the back control. `null` hides it.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) => ViewModelBuilder<SessionsViewModel>(
    onCreate: (BuildContext context, SessionsViewModel vm) =>
        unawaited(vm.cubit.load()),
    builder: (BuildContext context, SessionsViewModel vm) =>
        BlocProvider<SessionsCubit>.value(
          value: vm.cubit,
          child: NoticeListener<SessionsCubit, SessionsState>(
            pick: (SessionsState s) => s.notice,
            child: _Body(onBack: onBack),
          ),
        ),
  );
}

class _Body extends StatelessWidget {
  const _Body({required this.onBack});

  final VoidCallback? onBack;

  Future<void> _revokeOthers(BuildContext context) async {
    final SessionsCubit cubit = context.read<SessionsCubit>();
    final bool sure = await confirmSettingsAction(
      context,
      title: 'Sign out all other devices?',
      description: 'Every device except this one will need to sign in again.',
      confirmLabel: 'Sign out all',
      destructive: true,
    );
    if (sure) await cubit.revokeOthers();
  }

  @override
  Widget build(BuildContext context) {
    final SessionsState state = context.watch<SessionsCubit>().state;
    final SessionsCubit cubit = context.read<SessionsCubit>();
    final DateTime now = DateTime.now();
    return PageFrame(
      title: 'Active sessions',
      onBack: onBack,
      children: <Widget>[
        const HelpText(
          'These devices are signed in to your account. Sign out any you do '
          'not recognise.',
        ),
        LoadGate(
          status: state.status,
          onRetry: cubit.load,
          child: state.status == LoadStatus.ready
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SettingsGroup(
                      children: <Widget>[
                        for (final DeviceSession s in state.sessions)
                          _SessionRow(
                            session: s,
                            now: now,
                            busy: state.busy.contains(s.id),
                            onSignOut: () => unawaited(cubit.revoke(s)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DialogButton(
                      label: 'Sign out all other devices',
                      variant: CairnButtonVariant.outline,
                      busy: state.busy.contains(SessionsCubit.all),
                      onPressed:
                          state.others.isEmpty ||
                              state.busy.contains(SessionsCubit.all)
                          ? null
                          : () => unawaited(_revokeOthers(context)),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({
    required this.session,
    required this.now,
    required this.busy,
    required this.onSignOut,
  });

  final DeviceSession session;
  final DateTime now;
  final bool busy;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final String where =
        '${session.location}. ${session.isCurrent ? 'Active now' : describeActivity(session.lastActive, now)}';
    final bool laptop =
        session.device.contains('Mac') || session.device.contains('Windows');
    return Semantics(
      container: true,
      label:
          '${session.device}${session.isCurrent ? ', this device' : ''}. $where',
      child: ActionRow(
        leading: IconBadge(icon: laptop ? Icons.laptop_mac : Icons.smartphone),
        title: Text(session.device),
        badge: session.isCurrent
            ? const CairnBadge(
                variant: CairnBadgeVariant.secondary,
                label: Text('This device'),
              )
            : null,
        subtitle: Text(where),
        action: session.isCurrent
            ? null
            : TouchTarget(
                onTap: busy ? null : onSignOut,
                child: CairnButton(
                  variant: CairnButtonVariant.outline,
                  size: CairnButtonSize.sm,
                  semanticLabel: 'Sign out ${session.device}',
                  onPressed: busy ? null : onSignOut,
                  child: const Text('Sign out'),
                ),
              ),
      ),
    );
  }
}
