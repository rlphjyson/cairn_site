import 'dart:async';

import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart' show Icon, Icons;
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/load_status.dart';
import '../../../core/presentation/view_model.dart';
import '../../../core/presentation/widgets/action_row.dart';
import '../../../core/presentation/widgets/load_gate.dart';
import '../../../core/presentation/widgets/page_frame.dart';
import '../../../core/presentation/widgets/setting_rows.dart';
import '../../../core/presentation/widgets/themed_overlays.dart';
import '../../../core/presentation/widgets/touch_target.dart';
import '../../../domain/security/models/device_session.dart';
import '../bloc/blocked_users_cubit.dart';
import '../view_models/privacy_view_models.dart';

/// Blocked users: who is blocked, with an Unblock button on each, or an empty
/// state when nobody is.
class BlockedUsersView extends StatelessWidget {
  /// Creates the view.
  const BlockedUsersView({super.key, required this.onBack});

  /// Called by the back control. `null` hides it.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) => ViewModelBuilder<BlockedUsersViewModel>(
    onCreate: (BuildContext context, BlockedUsersViewModel vm) =>
        unawaited(vm.cubit.load()),
    builder: (BuildContext context, BlockedUsersViewModel vm) =>
        BlocProvider<BlockedUsersCubit>.value(
          value: vm.cubit,
          child: NoticeListener<BlockedUsersCubit, BlockedUsersState>(
            pick: (BlockedUsersState s) => s.notice,
            child: _Body(onBack: onBack),
          ),
        ),
  );
}

class _Body extends StatelessWidget {
  const _Body({required this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final BlockedUsersState state = context.watch<BlockedUsersCubit>().state;
    final BlockedUsersCubit cubit = context.read<BlockedUsersCubit>();
    return PageFrame(
      title: 'Blocked users',
      onBack: onBack,
      children: <Widget>[
        LoadGate(
          status: state.status,
          onRetry: cubit.load,
          child: state.status != LoadStatus.ready
              ? const SizedBox.shrink()
              : state.users.isEmpty
              ? Semantics(
                  liveRegion: true,
                  child: const CairnEmpty(
                    media: Icon(Icons.block, size: 32),
                    title: 'No blocked users',
                    description:
                        'People you block cannot message you or see your '
                        'profile. They will appear here.',
                  ),
                )
              : SettingsGroup(
                  children: <Widget>[
                    for (final BlockedUser u in state.users)
                      Semantics(
                        container: true,
                        label: '${u.name}, @${u.username}',
                        child: ActionRow(
                          leading: CairnAvatar(
                            size: CairnAvatarSize.lg,
                            fallback: Text(u.name.substring(0, 1)),
                          ),
                          title: Text(u.name),
                          subtitle: Text('@${u.username}'),
                          action: TouchTarget(
                            onTap: state.busy.contains(u.id)
                                ? null
                                : () => unawaited(cubit.unblock(u)),
                            child: CairnButton(
                              variant: CairnButtonVariant.outline,
                              size: CairnButtonSize.sm,
                              semanticLabel: 'Unblock ${u.name}',
                              onPressed: state.busy.contains(u.id)
                                  ? null
                                  : () => unawaited(cubit.unblock(u)),
                              child: const Text('Unblock'),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}
