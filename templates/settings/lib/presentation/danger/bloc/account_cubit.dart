import 'package:equatable/equatable.dart';

import '../../../common/utils/settings_failure.dart';
import '../../../core/infrastructure/settings_hooks.dart';
import '../../../core/presentation/notice.dart';
import '../../../core/presentation/safe_cubit.dart';
import '../../../domain/security/use_cases/delete_account.dart';

/// What the danger zone is doing.
enum AccountBusy {
  /// Nothing.
  none,

  /// Deactivating.
  deactivating,

  /// Deleting.
  deleting,
}

/// The danger zone's state.
class AccountState extends Equatable {
  /// Creates a state.
  const AccountState({this.busy = AccountBusy.none, this.notice});

  /// What is running.
  final AccountBusy busy;

  /// A message to show as a toast.
  final Notice? notice;

  @override
  List<Object?> get props => <Object?>[busy, notice];
}

/// Sign out, deactivate and delete. Screen-scoped.
///
/// Signing out and the end of a deactivation or deletion are the host's to
/// handle: this cubit calls the matching hook and raises a notice, and the host
/// takes the person to its sign-in screen.
class AccountCubit extends SafeCubit<AccountState> {
  /// Creates the cubit.
  AccountCubit(this._deactivate, this._delete, this._hooks)
    : super(const AccountState());

  final DeactivateAccount _deactivate;
  final DeleteAccount _delete;
  final SettingsHooks _hooks;

  /// Signs out of this device.
  void signOut() {
    final void Function()? hook = _hooks.onSignOut;
    hook?.call();
    emit(
      AccountState(
        notice: Notice(
          'Signed out',
          description: hook == null
              ? 'Pass onSignOut to SettingsApp to handle this.'
              : null,
        ),
      ),
    );
  }

  /// Deactivates the account.
  Future<bool> deactivate() async {
    if (state.busy != AccountBusy.none) return false;
    emit(const AccountState(busy: AccountBusy.deactivating));
    try {
      await _deactivate();
      _hooks.onDeactivateAccount?.call();
      emit(AccountState(notice: Notice('Account deactivated')));
      return true;
    } on SettingsFailure catch (e) {
      emit(AccountState(notice: Notice(e.message, isError: true)));
    } on Object {
      emit(AccountState(notice: Notice('Could not deactivate', isError: true)));
    }
    return false;
  }

  /// Deletes the account. [typed] must be the confirmation word.
  Future<bool> delete(String typed) async {
    if (state.busy != AccountBusy.none) return false;
    emit(const AccountState(busy: AccountBusy.deleting));
    try {
      await _delete(typed);
      _hooks.onDeleteAccount?.call();
      emit(AccountState(notice: Notice('Account deleted')));
      return true;
    } on SettingsFailure catch (e) {
      emit(AccountState(notice: Notice(e.message, isError: true)));
    } on Object {
      emit(AccountState(notice: Notice('Could not delete', isError: true)));
    }
    return false;
  }
}
