import 'package:equatable/equatable.dart';

import '../../../core/presentation/load_status.dart';
import '../../../core/presentation/notice.dart';
import '../../../core/presentation/safe_cubit.dart';
import '../../../domain/security/models/device_session.dart';
import '../../../domain/security/use_cases/blocked_users.dart';

/// The blocked users list.
class BlockedUsersState extends Equatable {
  /// Creates a state.
  const BlockedUsersState({
    this.status = LoadStatus.loading,
    this.users = const <BlockedUser>[],
    this.busy = const <String>{},
    this.notice,
  });

  /// Whether the list has loaded.
  final LoadStatus status;

  /// The people blocked.
  final List<BlockedUser> users;

  /// Ids being unblocked.
  final Set<String> busy;

  /// A message to show as a toast.
  final Notice? notice;

  /// A copy with some fields changed.
  BlockedUsersState copyWith({
    LoadStatus? status,
    List<BlockedUser>? users,
    Set<String>? busy,
    Notice? notice,
  }) => BlockedUsersState(
    status: status ?? this.status,
    users: users ?? this.users,
    busy: busy ?? this.busy,
    notice: notice ?? this.notice,
  );

  @override
  List<Object?> get props => <Object?>[status, users, busy, notice];
}

/// The blocked users screen. Screen-scoped.
class BlockedUsersCubit extends SafeCubit<BlockedUsersState> {
  /// Creates the cubit.
  BlockedUsersCubit(this._get, this._unblock)
    : super(const BlockedUsersState());

  final GetBlockedUsers _get;
  final UnblockUser _unblock;

  /// Loads the list.
  Future<void> load() async {
    emit(const BlockedUsersState());
    try {
      emit(BlockedUsersState(status: LoadStatus.ready, users: await _get()));
    } on Object {
      emit(const BlockedUsersState(status: LoadStatus.failure));
    }
  }

  /// Unblocks [user].
  Future<void> unblock(BlockedUser user) async {
    if (state.busy.contains(user.id)) return;
    emit(state.copyWith(busy: <String>{...state.busy, user.id}));
    try {
      await _unblock(user.id);
      emit(
        state.copyWith(
          users: <BlockedUser>[
            for (final BlockedUser u in state.users)
              if (u.id != user.id) u,
          ],
          busy: <String>{...state.busy}..remove(user.id),
          notice: Notice('Unblocked ${user.name}'),
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          busy: <String>{...state.busy}..remove(user.id),
          notice: Notice('Could not unblock ${user.name}', isError: true),
        ),
      );
    }
  }
}
