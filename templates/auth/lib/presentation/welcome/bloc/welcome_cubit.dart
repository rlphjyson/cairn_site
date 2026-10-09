import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/form_status.dart';
import '../../../domain/auth/models/auth_failure.dart';
import '../../../domain/auth/models/session.dart';
import '../../../domain/auth/models/social_provider.dart';
import '../../../domain/auth/use_cases/sign_in_with_provider.dart';

/// The welcome screen's state: only the social buttons do any work.
class WelcomeState extends Equatable {
  /// Creates a state.
  const WelcomeState({
    this.status = FormStatus.idle,
    this.provider,
    this.failure,
    this.session,
  });

  /// Where the social sign-in is.
  final FormStatus status;

  /// The provider being used, while submitting.
  final SocialProvider? provider;

  /// Why the last attempt failed.
  final AuthFailure? failure;

  /// The session, when [status] is [FormStatus.success].
  final Session? session;

  @override
  List<Object?> get props => <Object?>[status, provider, failure, session];
}

/// Drives the welcome screen's social buttons. A screen cubit.
class WelcomeCubit extends Cubit<WelcomeState> {
  /// Creates the cubit.
  WelcomeCubit(this._signInWithProvider) : super(const WelcomeState());

  final SignInWithProvider _signInWithProvider;

  /// Signs in with [provider]. A cancelled provider sheet returns to idle
  /// without an error.
  Future<void> continueWith(SocialProvider provider) async {
    if (state.status == FormStatus.submitting) return;
    emit(WelcomeState(status: FormStatus.submitting, provider: provider));
    try {
      final Session? session = await _signInWithProvider(provider);
      if (isClosed) return;
      emit(
        session == null
            ? const WelcomeState()
            : WelcomeState(status: FormStatus.success, session: session),
      );
    } on Object catch (error) {
      if (isClosed) return;
      emit(
        WelcomeState(
          status: FormStatus.failure,
          failure: AuthException.from(error).failure,
        ),
      );
    }
  }

  /// Dismisses the error banner.
  void dismissError() {
    if (state.status == FormStatus.failure) emit(const WelcomeState());
  }
}
