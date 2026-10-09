import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/form_status.dart';
import '../../../domain/auth/models/auth_failure.dart';
import '../../../domain/auth/use_cases/request_password_reset.dart';
import '../../../domain/validation/models/validation_issue.dart';
import '../../../domain/validation/use_cases/validate_email.dart';

/// The forgot-password form's state.
class ForgotPasswordState extends Equatable {
  /// Creates a state.
  const ForgotPasswordState({
    this.status = FormStatus.idle,
    this.issue,
    this.failure,
    this.sentTo,
  });

  /// Where the form is.
  final FormStatus status;

  /// A problem with the email.
  final ValidationIssue? issue;

  /// Why the request failed (offline, ...).
  final AuthFailure? failure;

  /// The address the code was requested for, once [status] is
  /// [FormStatus.success]. The screen words this as "if an account exists",
  /// whatever the server knows.
  final String? sentTo;

  @override
  List<Object?> get props => <Object?>[status, issue, failure, sentTo];
}

/// Drives the forgot-password screen.
///
/// Success always looks the same: this cubit has no way to learn whether the
/// account exists, and must not grow one.
class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  /// Creates the cubit.
  ForgotPasswordCubit(this._request, this._validateEmail)
    : super(const ForgotPasswordState());

  final RequestPasswordReset _request;
  final ValidateEmail _validateEmail;

  /// Checks the email when the person leaves the field.
  void validate(String email) {
    if (state.status != FormStatus.idle) return;
    final ValidationIssue? issue = _validateEmail(email);
    if (issue == null) {
      if (state.issue != null) emit(const ForgotPasswordState());
    } else if (email.trim().isNotEmpty || state.issue != null) {
      emit(ForgotPasswordState(issue: issue));
    }
  }

  /// Clears the problem while the person edits.
  void edited() {
    if (state.issue != null || state.failure != null) {
      emit(const ForgotPasswordState());
    }
  }

  /// Returns to the form after the confirmation ("use a different email").
  void reset() => emit(const ForgotPasswordState());

  /// Requests the code. Ignored while a request is in flight.
  Future<void> submit(String email) async {
    if (state.status == FormStatus.submitting) return;
    final ValidationIssue? issue = _validateEmail(email);
    if (issue != null) {
      emit(ForgotPasswordState(issue: issue));
      return;
    }
    emit(const ForgotPasswordState(status: FormStatus.submitting));
    try {
      await _request(email);
      if (isClosed) return;
      emit(
        ForgotPasswordState(status: FormStatus.success, sentTo: email.trim()),
      );
    } on Object catch (error) {
      if (isClosed) return;
      emit(
        ForgotPasswordState(
          status: FormStatus.failure,
          failure: AuthException.from(error).failure,
        ),
      );
    }
  }
}
