import 'package:equatable/equatable.dart';

import '../../../common/utils/settings_failure.dart';
import '../../../core/presentation/safe_cubit.dart';
import '../../../domain/security/models/device_session.dart';
import '../../../domain/security/use_cases/two_factor_use_cases.dart';

/// The steps of the two-factor setup sheet.
enum TwoFactorStep {
  /// Showing the key to add to an authenticator app.
  key,

  /// Asking for the 6-digit code.
  code,

  /// Done.
  done,
}

/// The setup sheet's state.
class TwoFactorState extends Equatable {
  /// Creates a state.
  const TwoFactorState({
    this.step = TwoFactorStep.key,
    this.setup,
    this.loading = true,
    this.verifying = false,
    this.error,
  });

  /// The step showing.
  final TwoFactorStep step;

  /// The key to enrol. `null` while loading.
  final TwoFactorSetup? setup;

  /// Whether the key is being fetched.
  final bool loading;

  /// Whether the code is being checked.
  final bool verifying;

  /// A problem with the code, or with fetching the key.
  final String? error;

  /// A copy with some fields changed. [error] is replaced, not merged.
  TwoFactorState copyWith({
    TwoFactorStep? step,
    TwoFactorSetup? setup,
    bool? loading,
    bool? verifying,
    String? error,
  }) => TwoFactorState(
    step: step ?? this.step,
    setup: setup ?? this.setup,
    loading: loading ?? this.loading,
    verifying: verifying ?? this.verifying,
    error: error,
  );

  @override
  List<Object?> get props => <Object?>[step, setup, loading, verifying, error];
}

/// The two-factor setup flow, owned by the sheet. Screen-scoped.
class TwoFactorCubit extends SafeCubit<TwoFactorState> {
  /// Creates the cubit.
  TwoFactorCubit(this._begin, this._verify) : super(const TwoFactorState());

  final BeginTwoFactor _begin;
  final VerifyTwoFactor _verify;

  /// Fetches the key to enrol.
  Future<void> begin() async {
    try {
      final TwoFactorSetup setup = await _begin();
      emit(TwoFactorState(setup: setup, loading: false));
    } on Object {
      emit(
        const TwoFactorState(
          loading: false,
          error: 'Could not start setup. Try again.',
        ),
      );
    }
  }

  /// Moves to the code step.
  void next() =>
      emit(state.copyWith(step: TwoFactorStep.code, setup: state.setup));

  /// Moves back to the key step.
  void back() =>
      emit(state.copyWith(step: TwoFactorStep.key, setup: state.setup));

  /// Checks [code]. Returns whether it was right.
  Future<bool> verify(String code) async {
    if (state.verifying) return false;
    emit(state.copyWith(verifying: true, setup: state.setup));
    try {
      await _verify(code);
      emit(
        state.copyWith(
          step: TwoFactorStep.done,
          verifying: false,
          setup: state.setup,
        ),
      );
      return true;
    } on SettingsFailure catch (e) {
      emit(
        state.copyWith(verifying: false, error: e.message, setup: state.setup),
      );
    } on Object {
      emit(
        state.copyWith(
          verifying: false,
          error: 'Could not check the code. Try again.',
          setup: state.setup,
        ),
      );
    }
    return false;
  }
}
