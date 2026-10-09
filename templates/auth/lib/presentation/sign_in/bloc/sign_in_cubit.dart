import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/constants/auth_policy.dart';
import '../../../common/utils/ticker.dart';
import '../../../core/presentation/form_status.dart';
import '../../../domain/auth/models/auth_failure.dart';
import '../../../domain/auth/models/session.dart';
import '../../../domain/auth/use_cases/sign_in.dart';
import '../../../domain/validation/models/auth_field.dart';
import '../../../domain/validation/models/validation_issue.dart';
import '../../../domain/validation/use_cases/validate_email.dart';

/// The sign-in form's state.
///
/// Holds no password, and no email either: the text lives in the view's
/// controllers and is handed to [SignInCubit.submit] when needed.
class SignInState extends Equatable {
  /// Creates a state.
  const SignInState({
    this.status = FormStatus.idle,
    this.issues = const <AuthField, ValidationIssue>{},
    this.failure,
    this.lockedSeconds = 0,
    this.session,
  });

  /// Where the form is.
  final FormStatus status;

  /// Inline problems, by field.
  final Map<AuthField, ValidationIssue> issues;

  /// Why the last request failed, when [status] is [FormStatus.failure].
  final AuthFailure? failure;

  /// Seconds until sign-in unlocks; zero when it is not locked.
  final int lockedSeconds;

  /// The session, when [status] is [FormStatus.success].
  final Session? session;

  /// Whether the rate limit is in force.
  bool get locked => lockedSeconds > 0;

  @override
  List<Object?> get props => <Object?>[
    status,
    issues,
    failure,
    lockedSeconds,
    session,
  ];
}

/// Drives the sign-in screen. A screen cubit, closed with its view model.
class SignInCubit extends Cubit<SignInState> {
  /// Creates the cubit. [ticker] counts the lockout down.
  SignInCubit(this._signIn, this._validateEmail, this._ticker)
    : super(const SignInState());

  final SignIn _signIn;
  final ValidateEmail _validateEmail;
  final TickerFactory _ticker;
  Timer? _timer;

  /// Validates one field as the person leaves or edits it. Only the email has
  /// a format to check; the password just has to be present on submit.
  void validate(AuthField field, String value) {
    if (field != AuthField.email) {
      if (state.issues.containsKey(field)) _clear(field);
      return;
    }
    final ValidationIssue? issue = _validateEmail(value);
    if (issue == null) {
      _clear(field);
    } else if (value.trim().isNotEmpty || state.issues.containsKey(field)) {
      emit(_withIssue(field, issue));
    }
  }

  /// Clears the error banner and any inline problem for [field] as the person
  /// starts typing again.
  void edited(AuthField field) {
    if (state.status == FormStatus.failure && !state.locked) {
      emit(SignInState(issues: state.issues));
    }
    if (state.issues.containsKey(field)) _clear(field);
  }

  /// Signs in. Ignored while a request is in flight or sign-in is locked.
  Future<void> submit({
    required String email,
    required String password,
    required bool remember,
  }) async {
    if (state.status == FormStatus.submitting || state.locked) return;

    final Map<AuthField, ValidationIssue> issues =
        <AuthField, ValidationIssue>{};
    final ValidationIssue? emailIssue = _validateEmail(email);
    if (emailIssue != null) issues[AuthField.email] = emailIssue;
    if (password.isEmpty) {
      issues[AuthField.password] = ValidationIssue.passwordRequired;
    }
    if (issues.isNotEmpty) {
      emit(SignInState(issues: issues));
      return;
    }

    emit(const SignInState(status: FormStatus.submitting));
    try {
      final Session session = await _signIn(
        email: email,
        password: password,
        remember: remember,
      );
      if (isClosed) return;
      emit(SignInState(status: FormStatus.success, session: session));
    } on Object catch (error) {
      if (isClosed) return;
      final AuthException e = AuthException.from(error);
      if (e.failure == AuthFailure.rateLimited) {
        _lock(e.retryAfter?.inSeconds ?? AuthPolicy.signInLockout.inSeconds);
      } else {
        emit(SignInState(status: FormStatus.failure, failure: e.failure));
      }
    }
  }

  void _lock(int seconds) {
    _timer?.cancel();
    int left = seconds;
    emit(
      SignInState(
        status: FormStatus.failure,
        failure: AuthFailure.rateLimited,
        lockedSeconds: left,
      ),
    );
    _timer = _ticker(const Duration(seconds: 1), (Timer timer) {
      left--;
      if (left <= 0) {
        timer.cancel();
        emit(const SignInState());
      } else {
        emit(
          SignInState(
            status: FormStatus.failure,
            failure: AuthFailure.rateLimited,
            lockedSeconds: left,
          ),
        );
      }
    });
  }

  SignInState _withIssue(AuthField field, ValidationIssue issue) => SignInState(
    status: state.status,
    failure: state.failure,
    lockedSeconds: state.lockedSeconds,
    issues: <AuthField, ValidationIssue>{...state.issues, field: issue},
  );

  void _clear(AuthField field) => emit(
    SignInState(
      status: state.status,
      failure: state.failure,
      lockedSeconds: state.lockedSeconds,
      issues: <AuthField, ValidationIssue>{...state.issues}..remove(field),
    ),
  );

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
