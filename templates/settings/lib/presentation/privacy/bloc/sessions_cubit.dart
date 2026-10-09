import 'package:equatable/equatable.dart';

import '../../../common/utils/settings_failure.dart';
import '../../../core/presentation/load_status.dart';
import '../../../core/presentation/notice.dart';
import '../../../core/presentation/safe_cubit.dart';
import '../../../domain/security/models/device_session.dart';
import '../../../domain/security/use_cases/get_sessions.dart';
import '../../../domain/security/use_cases/revoke_session.dart';

/// The signed-in devices.
class SessionsState extends Equatable {
  /// Creates a state.
  const SessionsState({
    this.status = LoadStatus.loading,
    this.sessions = const <DeviceSession>[],
    this.busy = const <String>{},
    this.notice,
  });

  /// Whether the list has loaded.
  final LoadStatus status;

  /// The devices, this one first.
  final List<DeviceSession> sessions;

  /// Ids being signed out. `all` stands for "all other devices".
  final Set<String> busy;

  /// A message to show as a toast.
  final Notice? notice;

  /// Devices other than this one.
  List<DeviceSession> get others =>
      sessions.where((DeviceSession s) => !s.isCurrent).toList();

  /// A copy with some fields changed.
  SessionsState copyWith({
    LoadStatus? status,
    List<DeviceSession>? sessions,
    Set<String>? busy,
    Notice? notice,
  }) => SessionsState(
    status: status ?? this.status,
    sessions: sessions ?? this.sessions,
    busy: busy ?? this.busy,
    notice: notice ?? this.notice,
  );

  @override
  List<Object?> get props => <Object?>[status, sessions, busy, notice];
}

/// The active sessions screen. Screen-scoped.
class SessionsCubit extends SafeCubit<SessionsState> {
  /// Creates the cubit.
  SessionsCubit(this._getSessions, this._revoke) : super(const SessionsState());

  final GetSessions _getSessions;
  final RevokeSession _revoke;

  /// The id used in [SessionsState.busy] while all other devices sign out.
  static const String all = 'all';

  /// Loads the devices.
  Future<void> load() async {
    emit(const SessionsState());
    try {
      emit(
        SessionsState(status: LoadStatus.ready, sessions: await _getSessions()),
      );
    } on Object {
      emit(const SessionsState(status: LoadStatus.failure));
    }
  }

  /// Signs [session] out.
  Future<void> revoke(DeviceSession session) async {
    if (state.busy.contains(session.id)) return;
    emit(state.copyWith(busy: <String>{...state.busy, session.id}));
    try {
      await _revoke(session);
      emit(
        state.copyWith(
          sessions: <DeviceSession>[
            for (final DeviceSession s in state.sessions)
              if (s.id != session.id) s,
          ],
          busy: <String>{...state.busy}..remove(session.id),
          notice: Notice('Signed out ${session.device}'),
        ),
      );
    } on Object catch (e) {
      emit(
        state.copyWith(
          busy: <String>{...state.busy}..remove(session.id),
          notice: Notice(
            e is SettingsFailure ? e.message : 'Could not sign out',
            isError: true,
          ),
        ),
      );
    }
  }

  /// Signs every other device out.
  Future<void> revokeOthers() async {
    if (state.busy.contains(all)) return;
    emit(state.copyWith(busy: <String>{...state.busy, all}));
    try {
      await _revoke.others();
      emit(
        state.copyWith(
          sessions: state.sessions
              .where((DeviceSession s) => s.isCurrent)
              .toList(),
          busy: <String>{...state.busy}..remove(all),
          notice: Notice('Signed out all other devices'),
        ),
      );
    } on Object catch (e) {
      emit(
        state.copyWith(
          busy: <String>{...state.busy}..remove(all),
          notice: Notice(
            e is SettingsFailure ? e.message : 'Could not sign out',
            isError: true,
          ),
        ),
      );
    }
  }
}
