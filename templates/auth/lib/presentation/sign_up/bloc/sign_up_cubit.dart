import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/form_status.dart';
import '../../../domain/auth/models/auth_failure.dart';
import '../../../domain/auth/models/session.dart';
import '../../../domain/auth/use_cases/sign_up.dart';
import '../../../domain/validation/models/auth_field.dart';
import '../../../domain/validation/models/password_assessment.dart';
import '../../../domain/validation/models/validation_issue.dart';
import '../../../domain/validation/use_cases/password_strength.dart';
import '../../../domain/validation/use_cases/validate_email.dart';
import '../../../domain/validation/use_cases/validate_name.dart';
import '../../../domain/validation/use_cases/validate_password.dart';

/// The sign-up form's state.
///
/// Holds the password's *assessment* (a score and which rules it meets) but
/// never the password.
class SignUpState extends Equatable {
  /// Creates a state.
  const SignUpState({
    this.status = FormStatus.idle,
    this.issues = const <AuthField, ValidationIssue>{},
    this.failure,
    this.assessment = PasswordAssessment.empty,
    this.session,
  });

  /// Where the form is.
  final FormStatus status;

  /// Inline problems, by field.
  final Map<AuthField, ValidationIssue> issues;

  /// Why the last request failed, when it was not a field problem.
  final AuthFailure? failure;

  /// How strong the current password is.
  final PasswordAssessment assessment;

  /// The session, when [status] is [FormStatus.success].
  final Session? session;

  /// Whether nothing has been typed in the password field.
  bool get passwordEmpty => assessment == PasswordAssessment.empty;

  SignUpState _copy({
    FormStatus? status,
    Map<AuthField, ValidationIssue>? issues,
    AuthFailure? failure,
    bool clearFailure = false,
    PasswordAssessment? assessment,
    Session? session,
  }) => SignUpState(
    status: status ?? this.status,
    issues: issues ?? this.issues,
    failure: clearFailure ? null : (failure ?? this.failure),
    assessment: assessment ?? this.assessment,
    session: session ?? this.session,
  );

  @override
  List<Object?> get props => <Object?>[
    status,
    issues,
    failure,
    assessment,
    session,
  ];
}

/// Drives the sign-up screen. A screen cubit, closed with its view model.
class SignUpCubit extends Cubit<SignUpState> {
  /// Creates the cubit.
  SignUpCubit(
    this._signUp,
    this._validateName,
    this._validateEmail,
    this._validatePassword,
    this._strength,
  ) : super(const SignUpState());

  final SignUp _signUp;
  final ValidateName _validateName;
  final ValidateEmail _validateEmail;
  final ValidatePassword _validatePassword;
  final PasswordStrength _strength;

  /// Scores the password as it is typed, for the meter and the checklist.
  void passwordChanged(String password) {
    emit(state._copy(assessment: _strength(password)));
  }

  /// Checks one field when the person leaves it. An untouched empty field is
  /// left alone; [password] is the current password, for the confirmation.
  void validate(AuthField field, String value, {String password = ''}) {
    final ValidationIssue? issue = _check(field, value, password);
    if (issue == null) {
      _set(field, null);
    } else if (value.isNotEmpty || state.issues.containsKey(field)) {
      _set(field, issue);
    }
  }

  /// Clears [field]'s problem, and the error banner, as the person edits.
  void edited(AuthField field) {
    if (state.issues.containsKey(field) ||
        (state.status == FormStatus.failure)) {
      emit(
        SignUpState(
          issues: <AuthField, ValidationIssue>{...state.issues}..remove(field),
          assessment: state.assessment,
        ),
      );
    }
  }

  /// Creates the account. Ignored while a request is in flight.
  Future<void> submit({
    required String name,
    required String email,
    required String password,
    required String confirmation,
    required bool acceptedTerms,
  }) async {
    if (state.status == FormStatus.submitting) return;

    final Map<AuthField, ValidationIssue> issues =
        <AuthField, ValidationIssue>{};
    void check(AuthField field, ValidationIssue? issue) {
      if (issue != null) issues[field] = issue;
    }

    check(AuthField.name, _validateName(name));
    check(AuthField.email, _validateEmail(email));
    check(AuthField.password, _validatePassword(password));
    check(
      AuthField.confirmation,
      _validatePassword.confirm(password, confirmation),
    );
    if (!acceptedTerms) issues[AuthField.terms] = ValidationIssue.termsRequired;
    if (issues.isNotEmpty) {
      emit(SignUpState(issues: issues, assessment: state.assessment));
      return;
    }

    emit(
      SignUpState(status: FormStatus.submitting, assessment: state.assessment),
    );
    try {
      final Session session = await _signUp(
        name: name,
        email: email,
        password: password,
        confirmation: confirmation,
        acceptedTerms: acceptedTerms,
      );
      if (isClosed) return;
      emit(
        SignUpState(
          status: FormStatus.success,
          assessment: state.assessment,
          session: session,
        ),
      );
    } on Object catch (error) {
      if (isClosed) return;
      final AuthException e = AuthException.from(error);
      if (e.failure == AuthFailure.emailTaken) {
        emit(
          SignUpState(
            issues: const <AuthField, ValidationIssue>{
              AuthField.email: ValidationIssue.emailTaken,
            },
            assessment: state.assessment,
          ),
        );
      } else {
        emit(
          SignUpState(
            status: FormStatus.failure,
            failure: e.failure,
            assessment: state.assessment,
          ),
        );
      }
    }
  }

  ValidationIssue? _check(AuthField field, String value, String password) =>
      switch (field) {
        AuthField.name => _validateName(value),
        AuthField.email => _validateEmail(value),
        AuthField.password => _validatePassword(value),
        AuthField.confirmation => _validatePassword.confirm(password, value),
        _ => null,
      };

  void _set(AuthField field, ValidationIssue? issue) {
    final Map<AuthField, ValidationIssue> issues = <AuthField, ValidationIssue>{
      ...state.issues,
    };
    if (issue == null) {
      issues.remove(field);
    } else {
      issues[field] = issue;
    }
    emit(state._copy(issues: issues));
  }
}
