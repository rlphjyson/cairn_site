import 'package:equatable/equatable.dart';

/// A field on the Edit profile form.
enum ProfileField {
  /// The display name.
  name,

  /// The username.
  username,

  /// The email address.
  email,

  /// The bio.
  bio,
}

/// What is wrong with a profile, field by field. Empty when it is valid.
class ProfileValidation extends Equatable {
  /// Creates a validation result.
  const ProfileValidation([this.errors = const <ProfileField, String>{}]);

  /// The message for each invalid field.
  final Map<ProfileField, String> errors;

  /// Whether every field is valid.
  bool get isValid => errors.isEmpty;

  /// The message for [field], or `null`.
  String? operator [](ProfileField field) => errors[field];

  @override
  List<Object?> get props => <Object?>[errors];
}

/// The outcome of checking whether a username can be taken.
enum UsernameStatus {
  /// Not checked, or the field is empty.
  unknown,

  /// The format is wrong, so it was not looked up.
  invalid,

  /// Free to use.
  available,

  /// Someone else has it.
  taken,
}

/// A username check, with a message to show next to the field.
class UsernameCheck extends Equatable {
  /// Creates a check.
  const UsernameCheck(this.status, [this.message]);

  /// What was found.
  final UsernameStatus status;

  /// A message to show, when there is one.
  final String? message;

  @override
  List<Object?> get props => <Object?>[status, message];
}
