import 'package:equatable/equatable.dart';

import '../../../core/presentation/notice.dart';
import '../../../domain/profile/models/profile.dart';
import '../../../domain/profile/models/profile_validation.dart';

/// Where saving the profile is.
enum ProfileSaveStatus {
  /// Nothing happening.
  idle,

  /// Waiting for the data source.
  saving,

  /// Saved.
  saved,
}

/// The draft on the Edit profile form.
class ProfileEditState extends Equatable {
  /// Creates a state.
  const ProfileEditState({
    required this.draft,
    required this.saved,
    this.touched = const <ProfileField>{},
    this.submitted = false,
    this.usernameCheck = const UsernameCheck(UsernameStatus.unknown),
    this.checkingUsername = false,
    this.saveStatus = ProfileSaveStatus.idle,
    this.notice,
  });

  /// What the form shows now.
  final Profile draft;

  /// What is stored.
  final Profile saved;

  /// The fields the person has edited, whose errors are shown.
  final Set<ProfileField> touched;

  /// Whether Save was pressed, which reveals every error.
  final bool submitted;

  /// The latest answer about the username.
  final UsernameCheck usernameCheck;

  /// Whether a username lookup is running.
  final bool checkingUsername;

  /// Where saving is.
  final ProfileSaveStatus saveStatus;

  /// A message to show as a toast.
  final Notice? notice;

  /// Whether the draft differs from what is stored.
  bool get isDirty => draft != saved;

  /// Whether a save is running.
  bool get isSaving => saveStatus == ProfileSaveStatus.saving;

  /// A copy with some fields changed.
  ProfileEditState copyWith({
    Profile? draft,
    Profile? saved,
    Set<ProfileField>? touched,
    bool? submitted,
    UsernameCheck? usernameCheck,
    bool? checkingUsername,
    ProfileSaveStatus? saveStatus,
    Notice? notice,
  }) => ProfileEditState(
    draft: draft ?? this.draft,
    saved: saved ?? this.saved,
    touched: touched ?? this.touched,
    submitted: submitted ?? this.submitted,
    usernameCheck: usernameCheck ?? this.usernameCheck,
    checkingUsername: checkingUsername ?? this.checkingUsername,
    saveStatus: saveStatus ?? this.saveStatus,
    notice: notice ?? this.notice,
  );

  @override
  List<Object?> get props => <Object?>[
    draft,
    saved,
    touched,
    submitted,
    usernameCheck,
    checkingUsername,
    saveStatus,
    notice,
  ];
}
