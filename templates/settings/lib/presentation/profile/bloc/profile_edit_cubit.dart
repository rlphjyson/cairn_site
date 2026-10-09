import '../../../common/utils/settings_failure.dart';
import '../../../core/presentation/notice.dart';
import '../../../core/presentation/safe_cubit.dart';
import '../../../domain/profile/models/profile.dart';
import '../../../domain/profile/models/profile_validation.dart';
import '../../../domain/profile/use_cases/check_username.dart';
import '../../../domain/profile/use_cases/save_profile.dart';
import '../../../domain/profile/use_cases/validate_profile.dart';
import 'profile_cubit.dart';
import 'profile_edit_state.dart';

/// The draft behind the Edit profile form.
///
/// Screen-scoped: created by `ProfileEditViewModel` when the screen opens,
/// seeded from the saved profile, and closed with it.
class ProfileEditCubit extends SafeCubit<ProfileEditState> {
  /// Creates the cubit.
  ProfileEditCubit({
    required ProfileCubit profile,
    required this._validate,
    required this._checkUsername,
    required this._saveProfile,
  }) : _profile = profile,
       super(
         ProfileEditState(
           draft:
               profile.state.profile ??
               const Profile(name: '', username: '', email: ''),
           saved:
               profile.state.profile ??
               const Profile(name: '', username: '', email: ''),
         ),
       );

  final ProfileCubit _profile;
  final ValidateProfile _validate;
  final CheckUsername _checkUsername;
  final SaveProfile _saveProfile;
  int _lookup = 0;

  /// Every problem with the draft, for the fields whose errors are visible.
  ProfileValidation get visibleErrors {
    final ProfileValidation all = _validate(state.draft);
    if (state.submitted) return all;
    return ProfileValidation(<ProfileField, String>{
      for (final MapEntry<ProfileField, String> e in all.errors.entries)
        if (state.touched.contains(e.key)) e.key: e.value,
    });
  }

  /// Sets the name.
  void setName(String value) =>
      _edit(state.draft.copyWith(name: value), ProfileField.name);

  /// Sets the email.
  void setEmail(String value) =>
      _edit(state.draft.copyWith(email: value), ProfileField.email);

  /// Sets the bio.
  void setBio(String value) =>
      _edit(state.draft.copyWith(bio: value), ProfileField.bio);

  /// Picks an avatar preset.
  void setAvatar(String id) =>
      emit(state.copyWith(draft: state.draft.copyWith(avatarId: id)));

  /// Sets the username and checks that it is free. Every call starts a lookup;
  /// an answer is dropped if the text has changed since.
  Future<void> setUsername(String value) async {
    _edit(state.draft.copyWith(username: value), ProfileField.username);
    final int mine = ++_lookup;
    final String text = value;
    final bool needsLookup =
        ValidateProfile.usernameProblem(text) == null &&
        text.trim() != state.saved.username;
    if (needsLookup) emit(state.copyWith(checkingUsername: true));
    final UsernameCheck check = await _checkUsername(
      text,
      current: state.saved.username,
    );
    if (mine != _lookup || isClosed) return;
    emit(state.copyWith(usernameCheck: check, checkingUsername: false));
  }

  void _edit(Profile draft, ProfileField field) => emit(
    state.copyWith(
      draft: draft,
      touched: <ProfileField>{...state.touched, field},
      saveStatus: ProfileSaveStatus.idle,
    ),
  );

  /// Puts the form back to what is stored.
  void discard() =>
      emit(ProfileEditState(draft: state.saved, saved: state.saved));

  /// Validates and saves. Returns whether it was saved.
  Future<bool> save() async {
    if (state.isSaving) return false;
    emit(state.copyWith(submitted: true));
    if (!_validate(state.draft).isValid) {
      return false;
    }
    if (state.usernameCheck.status == UsernameStatus.taken) return false;
    emit(state.copyWith(saveStatus: ProfileSaveStatus.saving));
    try {
      final Profile stored = await _saveProfile(
        state.draft,
        savedUsername: state.saved.username,
      );
      _profile.replace(stored);
      if (isClosed) return true;
      emit(
        ProfileEditState(
          draft: stored,
          saved: stored,
          saveStatus: ProfileSaveStatus.saved,
          notice: Notice('Profile saved'),
        ),
      );
      return true;
    } on SettingsFailure catch (e) {
      emit(
        state.copyWith(
          saveStatus: ProfileSaveStatus.idle,
          notice: Notice(e.message, isError: true),
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          saveStatus: ProfileSaveStatus.idle,
          notice: Notice('Could not save your profile', isError: true),
        ),
      );
    }
    return false;
  }
}
