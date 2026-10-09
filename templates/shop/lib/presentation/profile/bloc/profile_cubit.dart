import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/profile/models/account.dart';
import '../../../domain/profile/models/preferences.dart';
import '../../../domain/profile/use_cases/get_account.dart';
import '../../../domain/profile/use_cases/get_preferences.dart';
import '../../../domain/profile/use_cases/save_preferences.dart';
import '../../../domain/profile/use_cases/sign_in.dart';
import '../../../domain/profile/use_cases/sign_out.dart';

/// The account and its settings.
class ProfileState extends Equatable {
  /// Creates a state.
  const ProfileState({
    this.loaded = false,
    this.account,
    this.preferences = const Preferences(),
  });

  /// Whether the first load has finished.
  final bool loaded;

  /// The account, or `null` before loading or when signed out.
  final Account? account;

  /// Notification preferences.
  final Preferences preferences;

  /// Whether a shopper is signed in.
  bool get signedIn => account != null;

  @override
  List<Object?> get props => <Object?>[loaded, account, preferences];
}

/// Session-scoped profile state. A lazy singleton.
class ProfileCubit extends Cubit<ProfileState> {
  /// Creates the cubit.
  ProfileCubit(
    this._getAccount,
    this._getPreferences,
    this._savePreferences,
    this._signIn,
    this._signOut,
  ) : super(const ProfileState());

  final GetAccount _getAccount;
  final GetPreferences _getPreferences;
  final SavePreferences _savePreferences;
  final SignIn _signIn;
  final SignOut _signOut;

  /// Loads the account and preferences.
  Future<void> load() async {
    final Account? account = await _getAccount();
    final Preferences preferences = await _getPreferences();
    if (isClosed) return;
    emit(
      ProfileState(loaded: true, account: account, preferences: preferences),
    );
  }

  /// Signs in.
  Future<void> signIn() async {
    final Account account = await _signIn();
    if (isClosed) return;
    emit(
      ProfileState(
        loaded: true,
        account: account,
        preferences: state.preferences,
      ),
    );
  }

  /// Signs out, keeping the preferences.
  Future<void> signOut() async {
    await _signOut();
    if (isClosed) return;
    emit(ProfileState(loaded: true, preferences: state.preferences));
  }

  /// Turns order-update alerts on or off.
  Future<void> setOrderUpdates(bool value) =>
      _save(state.preferences.copyWith(orderUpdates: value));

  /// Turns offer alerts on or off.
  Future<void> setOffers(bool value) =>
      _save(state.preferences.copyWith(offers: value));

  Future<void> _save(Preferences preferences) async {
    final Preferences saved = await _savePreferences(preferences);
    if (isClosed) return;
    emit(
      ProfileState(loaded: true, account: state.account, preferences: saved),
    );
  }
}
