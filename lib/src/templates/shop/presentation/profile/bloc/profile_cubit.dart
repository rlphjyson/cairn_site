import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/profile/models/account.dart';
import '../../../domain/profile/models/preferences.dart';
import '../../../domain/profile/use_cases/get_account.dart';
import '../../../domain/profile/use_cases/get_preferences.dart';
import '../../../domain/profile/use_cases/save_preferences.dart';

/// The account and its settings.
class ProfileState extends Equatable {
  /// Creates a state.
  const ProfileState({this.account, this.preferences = const Preferences()});

  /// The account, once loaded.
  final Account? account;

  /// Notification preferences.
  final Preferences preferences;

  @override
  List<Object?> get props => <Object?>[account, preferences];
}

/// Session-scoped profile state. A lazy singleton.
class ProfileCubit extends Cubit<ProfileState> {
  /// Creates the cubit.
  ProfileCubit(this._getAccount, this._getPreferences, this._savePreferences)
    : super(const ProfileState());

  final GetAccount _getAccount;
  final GetPreferences _getPreferences;
  final SavePreferences _savePreferences;

  /// Loads the account and preferences.
  Future<void> load() async {
    final Account account = await _getAccount();
    final Preferences preferences = await _getPreferences();
    if (isClosed) return;
    emit(ProfileState(account: account, preferences: preferences));
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
    emit(ProfileState(account: state.account, preferences: saved));
  }
}
