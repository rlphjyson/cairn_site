import 'package:equatable/equatable.dart';

import '../../../common/utils/settings_failure.dart';
import '../../../core/presentation/notice.dart';
import '../../../core/presentation/safe_cubit.dart';
import '../../../domain/security/models/password_strength.dart';
import '../../../domain/security/models/password_validation.dart';
import '../../../domain/security/use_cases/change_password.dart';

/// The change password form's state.
class ChangePasswordState extends Equatable {
  /// Creates a state.
  const ChangePasswordState({
    this.strength = PasswordStrengthLevel.empty,
    this.errors = const PasswordValidation(),
    this.saving = false,
    this.done = false,
    this.notice,
  });

  /// How strong the new password is.
  final PasswordStrengthLevel strength;

  /// Errors to show. Empty until the form is submitted.
  final PasswordValidation errors;

  /// Whether the request is running.
  final bool saving;

  /// Whether the password was changed.
  final bool done;

  /// A message to show as a toast.
  final Notice? notice;

  @override
  List<Object?> get props => <Object?>[strength, errors, saving, done, notice];
}

/// The change password form. Screen-scoped.
class ChangePasswordCubit extends SafeCubit<ChangePasswordState> {
  /// Creates the cubit.
  ChangePasswordCubit(this._changePassword)
    : super(const ChangePasswordState());

  final ChangePassword _changePassword;

  /// Updates the strength meter as the new password is typed.
  void newPasswordChanged(String value) => emit(
    ChangePasswordState(
      strength: PasswordStrength.of(value),
      errors: state.errors,
      done: state.done,
    ),
  );

  /// Validates and sends. Returns whether the password was changed.
  Future<bool> submit({
    required String current,
    required String next,
    required String confirm,
  }) async {
    if (state.saving) return false;
    final PasswordValidation errors = _changePassword.validate(
      current: current,
      next: next,
      confirm: confirm,
    );
    if (!errors.isValid) {
      emit(ChangePasswordState(strength: state.strength, errors: errors));
      return false;
    }
    emit(ChangePasswordState(strength: state.strength, saving: true));
    try {
      await _changePassword(current: current, next: next, confirm: confirm);
      emit(
        ChangePasswordState(
          strength: state.strength,
          done: true,
          notice: Notice('Password changed'),
        ),
      );
      return true;
    } on SettingsFailure catch (e) {
      emit(
        ChangePasswordState(
          strength: state.strength,
          errors: PasswordValidation(<PasswordField, String>{
            PasswordField.current: e.message,
          }),
          notice: Notice(e.message, isError: true),
        ),
      );
    } on Object {
      emit(
        ChangePasswordState(
          strength: state.strength,
          notice: Notice('Could not change the password', isError: true),
        ),
      );
    }
    return false;
  }
}
