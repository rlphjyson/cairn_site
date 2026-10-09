import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/form_status.dart';
import '../../../domain/auth/models/auth_failure.dart';
import '../../../domain/auth/models/reset_grant.dart';
import '../../../domain/auth/use_cases/reset_password.dart';
import '../../../domain/validation/models/auth_field.dart';
import '../../../domain/validation/models/password_assessment.dart';
import '../../../domain/validation/models/validation_issue.dart';
import '../../../domain/validation/use_cases/password_strength.dart';
import '../../../domain/validation/use_cases/validate_password.dart';

/// The reset-password form's state.
///
/// Holds the password's assessment, never the password.
class ResetPasswordState extends Equatable {
  /// Creates a state.
  const ResetPasswordState({
    this.status = FormStatus.idle,
    this.issues = const <AuthField, ValidationIssue>{},
    this.failure,
    this.assessment = PasswordAssessment.empty,
  });

  /// Where the form is. [FormStatus.success] shows the confirmation.
  final FormStatus status;

  /// Inline problems, by field.
  final Map<AuthField, ValidationIssue> issues;

  /// Why the request failed.
  final AuthFailure? failure;

  /// How strong the current password is.
  final PasswordAssessment assessment;

  /// Whether nothing has been typed in the password field.
  bool get passwordEmpty => assessment == PasswordAssessment.empty;

  @override
  List<Object?> get props => <Object?>[status, issues, failure, assessment];
}

/// Drives the reset-password screen. A screen cubit, closed with its view
/// model.
class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  /// Creates the cubit for a verified [grant].
  ResetPasswordCubit(
    this._grant,
    this._reset,
    this._validatePassword,
    this._strength,
  ) : super(const ResetPasswordState());

  final ResetGrant _grant;
  final ResetPassword _reset;
  final ValidatePassword _validatePassword;
  final PasswordStrength _strength;

  /// Scores the password as it is typed.
  void passwordChanged(String password) => emit(
    ResetPasswordState(
      issues: <AuthField, ValidationIssue>{...state.issues}
        ..remove(AuthField.password),
      assessment: _strength(password),
    ),
  );

  /// Checks one field when the person leaves it.
  void validate(AuthField field, String value, {String password = ''}) {
    final ValidationIssue? issue = switch (field) {
      AuthField.password => _validatePassword(value),
      AuthField.confirmation => _validatePassword.confirm(password, value),
      _ => null,
    };
    final Map<AuthField, ValidationIssue> issues = <AuthField, ValidationIssue>{
      ...state.issues,
    };
    if (issue == null) {
      issues.remove(field);
    } else if (value.isNotEmpty || issues.containsKey(field)) {
      issues[field] = issue;
    }
    emit(
      ResetPasswordState(
        status: state.status,
        issues: issues,
        failure: state.failure,
        assessment: state.assessment,
      ),
    );
  }

  /// Clears [field]'s problem, and the error banner, as the person edits.
  void edited(AuthField field) {
    if (state.issues.containsKey(field) || state.failure != null) {
      emit(
        ResetPasswordState(
          issues: <AuthField, ValidationIssue>{...state.issues}..remove(field),
          assessment: state.assessment,
        ),
      );
    }
  }

  /// Sets the new password. Ignored while a request is in flight.
  Future<void> submit({
    required String password,
    required String confirmation,
  }) async {
    if (state.status == FormStatus.submitting) return;
    final Map<AuthField, ValidationIssue> issues =
        <AuthField, ValidationIssue>{};
    final ValidationIssue? passwordIssue = _validatePassword(password);
    if (passwordIssue != null) issues[AuthField.password] = passwordIssue;
    final ValidationIssue? confirmIssue = _validatePassword.confirm(
      password,
      confirmation,
    );
    if (confirmIssue != null) issues[AuthField.confirmation] = confirmIssue;
    if (issues.isNotEmpty) {
      emit(ResetPasswordState(issues: issues, assessment: state.assessment));
      return;
    }

    emit(
      ResetPasswordState(
        status: FormStatus.submitting,
        assessment: state.assessment,
      ),
    );
    try {
      await _reset(
        grant: _grant,
        password: password,
        confirmation: confirmation,
      );
      if (isClosed) return;
      emit(
        ResetPasswordState(
          status: FormStatus.success,
          assessment: state.assessment,
        ),
      );
    } on Object catch (error) {
      if (isClosed) return;
      emit(
        ResetPasswordState(
          status: FormStatus.failure,
          failure: AuthException.from(error).failure,
          assessment: state.assessment,
        ),
      );
    }
  }
}
