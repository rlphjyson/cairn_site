import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/constants/auth_policy.dart';
import '../../../common/utils/ticker.dart';
import '../../../core/presentation/form_status.dart';
import '../../../domain/auth/models/auth_failure.dart';
import '../../../domain/auth/models/reset_grant.dart';
import '../../../domain/auth/use_cases/request_password_reset.dart';
import '../../../domain/auth/use_cases/verify_code.dart';

/// The verification screen's state.
class VerifyCodeState extends Equatable {
  /// Creates a state.
  const VerifyCodeState({
    this.status = FormStatus.idle,
    this.failure,
    this.attemptsRemaining,
    this.resendSeconds = 0,
    this.resending = false,
    this.resent = false,
    this.grant,
  });

  /// Where the check is.
  final FormStatus status;

  /// Why the last check failed.
  final AuthFailure? failure;

  /// Wrong guesses left, when the server said.
  final int? attemptsRemaining;

  /// Seconds until a new code may be requested; zero when it may.
  final int resendSeconds;

  /// Whether a new code is being requested.
  final bool resending;

  /// Whether a new code was just sent.
  final bool resent;

  /// The grant, when [status] is [FormStatus.success].
  final ResetGrant? grant;

  /// Whether the code is locked until a new one is requested.
  bool get locked =>
      failure == AuthFailure.tooManyAttempts ||
      failure == AuthFailure.codeExpired;

  VerifyCodeState _copy({
    FormStatus? status,
    AuthFailure? failure,
    int? attemptsRemaining,
    bool clearFailure = false,
    int? resendSeconds,
    bool? resending,
    bool? resent,
    ResetGrant? grant,
  }) => VerifyCodeState(
    status: status ?? this.status,
    failure: clearFailure ? null : (failure ?? this.failure),
    attemptsRemaining: clearFailure
        ? null
        : (attemptsRemaining ?? this.attemptsRemaining),
    resendSeconds: resendSeconds ?? this.resendSeconds,
    resending: resending ?? this.resending,
    resent: resent ?? this.resent,
    grant: grant ?? this.grant,
  );

  @override
  List<Object?> get props => <Object?>[
    status,
    failure,
    attemptsRemaining,
    resendSeconds,
    resending,
    resent,
    grant,
  ];
}

/// Drives the verification screen. A screen cubit, closed with its view model.
///
/// The resend cooldown ticks on a [Timer] this cubit owns and cancels in
/// [close]. The timer is made by the injected [TickerFactory], so tests fire
/// ticks by hand instead of waiting.
class VerifyCodeCubit extends Cubit<VerifyCodeState> {
  /// Creates the cubit for a code that was just sent to [email], so the
  /// cooldown starts running immediately.
  VerifyCodeCubit(this.email, this._verify, this._request, this._ticker)
    : super(
        VerifyCodeState(resendSeconds: AuthPolicy.resendCooldown.inSeconds),
      ) {
    _startCooldown();
  }

  /// The address the code went to.
  final String email;

  final VerifyCode _verify;
  final RequestPasswordReset _request;
  final TickerFactory _ticker;
  Timer? _timer;

  /// Clears the error while the person types a new code. An emptied field
  /// (cleared after a wrong code) keeps the message on screen.
  void edited(String code) {
    if (code.isEmpty || state.locked) return;
    if (state.failure != null || state.resent) {
      emit(state._copy(clearFailure: true, resent: false));
    }
  }

  /// Checks [code]. Ignored while a check is in flight or the code is locked.
  Future<void> submit(String code) async {
    if (state.status == FormStatus.submitting || state.locked) return;
    emit(state._copy(status: FormStatus.submitting, clearFailure: true));
    try {
      final ResetGrant grant = await _verify(email: email, code: code);
      if (isClosed) return;
      emit(state._copy(status: FormStatus.success, grant: grant));
    } on Object catch (error) {
      if (isClosed) return;
      final AuthException e = AuthException.from(error);
      emit(
        state._copy(
          status: FormStatus.failure,
          failure: e.failure,
          attemptsRemaining: e.attemptsRemaining,
          resent: false,
        ),
      );
    }
  }

  /// Asks for a new code. Ignored during the cooldown.
  Future<void> resend() async {
    if (state.resendSeconds > 0 || state.resending) return;
    emit(state._copy(resending: true, resent: false));
    try {
      await _request(email);
      if (isClosed) return;
      emit(
        state._copy(
          status: FormStatus.idle,
          clearFailure: true,
          resending: false,
          resent: true,
          resendSeconds: AuthPolicy.resendCooldown.inSeconds,
        ),
      );
      _startCooldown();
    } on Object catch (error) {
      if (isClosed) return;
      emit(
        state._copy(
          status: FormStatus.failure,
          failure: AuthException.from(error).failure,
          resending: false,
        ),
      );
    }
  }

  void _startCooldown() {
    _timer?.cancel();
    _timer = _ticker(const Duration(seconds: 1), (Timer timer) {
      final int left = state.resendSeconds - 1;
      if (left <= 0) timer.cancel();
      emit(state._copy(resendSeconds: left < 0 ? 0 : left));
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
