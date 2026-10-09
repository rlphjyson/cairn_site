import 'package:equatable/equatable.dart';

import '../../../core/presentation/load_status.dart';
import '../../../core/presentation/safe_cubit.dart';
import '../../../domain/profile/models/profile.dart';
import '../../../domain/profile/use_cases/get_profile.dart';

/// The signed-in person's saved profile, for the whole session.
class ProfileState extends Equatable {
  /// Creates a state.
  const ProfileState({this.status = LoadStatus.loading, this.profile});

  /// Whether the profile has loaded.
  final LoadStatus status;

  /// The saved profile. `null` until loaded.
  final Profile? profile;

  @override
  List<Object?> get props => <Object?>[status, profile];
}

/// Holds the saved profile: the home card shows it, the edit screen replaces it
/// after a save.
///
/// A session cubit. When the host passes a `profile` to `SettingsApp` it is used
/// as it is and nothing is loaded.
class ProfileCubit extends SafeCubit<ProfileState> {
  /// Creates the cubit. [initial] skips loading.
  ProfileCubit(this._getProfile, {Profile? initial})
    : super(
        initial == null
            ? const ProfileState()
            : ProfileState(status: LoadStatus.ready, profile: initial),
      );

  final GetProfile _getProfile;

  /// Loads the profile unless one was provided.
  Future<void> load() async {
    if (state.profile != null) return;
    emit(const ProfileState());
    try {
      emit(
        ProfileState(status: LoadStatus.ready, profile: await _getProfile()),
      );
    } on Object {
      emit(const ProfileState(status: LoadStatus.failure));
    }
  }

  /// Replaces the saved profile with [profile].
  void replace(Profile profile) =>
      emit(ProfileState(status: LoadStatus.ready, profile: profile));
}
