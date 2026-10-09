import '../../../core/presentation/view_model.dart';
import '../bloc/blocked_users_cubit.dart';
import '../bloc/change_password_cubit.dart';
import '../bloc/privacy_cubit.dart';
import '../bloc/sessions_cubit.dart';
import '../bloc/two_factor_cubit.dart';

/// Owns the Privacy and security screen's [PrivacyCubit].
class PrivacyViewModel implements ViewModel {
  /// Creates the view model.
  PrivacyViewModel(this.cubit);

  /// The screen's cubit.
  final PrivacyCubit cubit;

  @override
  void dispose() => cubit.close();
}

/// Owns the change password form's [ChangePasswordCubit].
class ChangePasswordViewModel implements ViewModel {
  /// Creates the view model.
  ChangePasswordViewModel(this.cubit);

  /// The form's cubit.
  final ChangePasswordCubit cubit;

  @override
  void dispose() => cubit.close();
}

/// Owns the active sessions screen's [SessionsCubit].
class SessionsViewModel implements ViewModel {
  /// Creates the view model.
  SessionsViewModel(this.cubit);

  /// The screen's cubit.
  final SessionsCubit cubit;

  @override
  void dispose() => cubit.close();
}

/// Owns the blocked users screen's [BlockedUsersCubit].
class BlockedUsersViewModel implements ViewModel {
  /// Creates the view model.
  BlockedUsersViewModel(this.cubit);

  /// The screen's cubit.
  final BlockedUsersCubit cubit;

  @override
  void dispose() => cubit.close();
}

/// Owns the two-factor sheet's [TwoFactorCubit].
class TwoFactorViewModel implements ViewModel {
  /// Creates the view model.
  TwoFactorViewModel(this.cubit);

  /// The sheet's cubit.
  final TwoFactorCubit cubit;

  @override
  void dispose() => cubit.close();
}
