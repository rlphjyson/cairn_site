import 'package:get_it/get_it.dart';

import '../../../common/utils/clock.dart';
import '../../../common/utils/ticker.dart';
import '../../../data/auth/remote/auth_remote_data_source.dart';
import '../../../data/auth/remote/in_memory_auth_remote_data_source.dart';
import '../../../data/auth/repositories/auth_repository_impl.dart';
import '../../../domain/auth/models/reset_grant.dart';
import '../../../domain/auth/models/social_provider.dart';
import '../../../domain/auth/repositories/auth_repository.dart';
import '../../../domain/auth/use_cases/request_password_reset.dart';
import '../../../domain/auth/use_cases/reset_password.dart';
import '../../../domain/auth/use_cases/sign_in.dart';
import '../../../domain/auth/use_cases/sign_in_with_provider.dart';
import '../../../domain/auth/use_cases/sign_out.dart';
import '../../../domain/auth/use_cases/sign_up.dart';
import '../../../domain/auth/use_cases/verify_code.dart';
import '../../../domain/validation/use_cases/password_strength.dart';
import '../../../domain/validation/use_cases/validate_code.dart';
import '../../../domain/validation/use_cases/validate_email.dart';
import '../../../domain/validation/use_cases/validate_name.dart';
import '../../../domain/validation/use_cases/validate_password.dart';
import '../../../presentation/recovery/bloc/forgot_password_cubit.dart';
import '../../../presentation/recovery/bloc/reset_password_cubit.dart';
import '../../../presentation/recovery/bloc/verify_code_cubit.dart';
import '../../../presentation/recovery/view_models/forgot_password_view_model.dart';
import '../../../presentation/recovery/view_models/reset_password_view_model.dart';
import '../../../presentation/recovery/view_models/verify_code_view_model.dart';
import '../../../presentation/session/bloc/session_cubit.dart';
import '../../../presentation/sign_in/bloc/sign_in_cubit.dart';
import '../../../presentation/sign_in/view_models/sign_in_view_model.dart';
import '../../../presentation/sign_up/bloc/sign_up_cubit.dart';
import '../../../presentation/sign_up/view_models/sign_up_view_model.dart';
import '../../../presentation/welcome/bloc/welcome_cubit.dart';
import '../../../presentation/welcome/view_models/welcome_view_model.dart';
import '../../presentation/navigation/auth_navigation_cubit.dart';

/// The ID token the social buttons use until you supply a real one with
/// `AuthApp.onSocialSignIn`. The in-memory server accepts anything; a real
/// server would reject it.
Future<String?> placeholderSocialIdToken(SocialProvider provider) async =>
    'placeholder-${provider.id}';

/// Builds a fresh dependency container for one mount of the template.
///
/// Registration is explicit rather than generated, so the template needs no
/// `build_runner` step. The scopes follow one rule:
///
/// * the data source and repository: lazy singletons, one per mount;
/// * use cases and validators: factories (they are stateless and free to
///   build);
/// * **session cubits** (navigation, session): lazy singletons, provided to the
///   tree once and never closed by a view model;
/// * **screen cubits** (welcome, sign in, sign up, forgot password, verify
///   code, reset password): created and closed by their view model, which is a
///   factory taking the screen's `AuthDestination`.
///
/// [dataSource] is the one place to connect a real backend. [startOn] is the
/// first screen; [resetToken], when a reset link opened the app, starts on the
/// reset-password screen instead. [socialIdToken] runs a provider's own sign-in SDK; without it
/// the social buttons use a placeholder token the in-memory server accepts.
/// [ticker] and [clock] exist so tests control time.
GetIt createAuthLocator({
  AuthRemoteDataSource? dataSource,
  AuthScreen startOn = AuthScreen.welcome,
  String? resetToken,
  SocialIdTokenProvider? socialIdToken,
  TickerFactory ticker = periodicTicker,
  Clock clock = systemClock,
}) {
  final GetIt g = GetIt.asNewInstance();

  // Data source. Replace it with one that calls your backend.
  g.registerLazySingleton<AuthRemoteDataSource>(
    () => dataSource ?? InMemoryAuthRemoteDataSource(clock: clock),
  );

  // Repository.
  g.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(g(), clock: clock),
  );

  // Use cases and validators.
  g
    ..registerFactory<ValidateEmail>(ValidateEmail.new)
    ..registerFactory<ValidateName>(ValidateName.new)
    ..registerFactory<ValidateCode>(ValidateCode.new)
    ..registerFactory<PasswordStrength>(PasswordStrength.new)
    ..registerFactory<ValidatePassword>(() => ValidatePassword(g()))
    ..registerFactory<SignIn>(() => SignIn(g(), g()))
    ..registerFactory<SignUp>(() => SignUp(g(), g(), g(), g()))
    ..registerFactory<SignInWithProvider>(
      () => SignInWithProvider(g(), socialIdToken ?? placeholderSocialIdToken),
    )
    ..registerFactory<RequestPasswordReset>(
      () => RequestPasswordReset(g(), g()),
    )
    ..registerFactory<VerifyCode>(() => VerifyCode(g(), g()))
    ..registerFactory<ResetPassword>(() => ResetPassword(g(), g()))
    ..registerFactory<SignOut>(() => SignOut(g()));

  // Session cubits.
  g
    ..registerLazySingleton<AuthNavigationCubit>(
      () => AuthNavigationCubit(
        start: startOn,
        resetGrant: resetToken == null ? null : ResetGrant(resetToken),
      ),
      dispose: (AuthNavigationCubit c) => c.close(),
    )
    ..registerLazySingleton<SessionCubit>(
      () => SessionCubit(g()),
      dispose: (SessionCubit c) => c.close(),
    );

  // Screen view models; each creates and owns its own cubit. The parameter is
  // the destination the screen was opened with.
  g
    ..registerFactoryParam<WelcomeViewModel, AuthDestination, Object?>(
      (AuthDestination _, Object? _) => WelcomeViewModel(WelcomeCubit(g())),
    )
    ..registerFactoryParam<SignInViewModel, AuthDestination, Object?>(
      (AuthDestination _, Object? _) =>
          SignInViewModel(SignInCubit(g(), g(), ticker)),
    )
    ..registerFactoryParam<SignUpViewModel, AuthDestination, Object?>(
      (AuthDestination _, Object? _) =>
          SignUpViewModel(SignUpCubit(g(), g(), g(), g(), g())),
    )
    ..registerFactoryParam<ForgotPasswordViewModel, AuthDestination, Object?>(
      (AuthDestination _, Object? _) =>
          ForgotPasswordViewModel(ForgotPasswordCubit(g(), g())),
    )
    ..registerFactoryParam<VerifyCodeViewModel, AuthDestination, Object?>(
      (AuthDestination d, Object? _) =>
          VerifyCodeViewModel(VerifyCodeCubit(d.email ?? '', g(), g(), ticker)),
    )
    ..registerFactoryParam<ResetPasswordViewModel, AuthDestination, Object?>(
      (AuthDestination d, Object? _) =>
          ResetPasswordViewModel(ResetPasswordCubit(d.grant!, g(), g(), g())),
    );

  return g;
}
