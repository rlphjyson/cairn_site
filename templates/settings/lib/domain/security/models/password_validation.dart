import 'package:equatable/equatable.dart';

/// A field on the change password form.
enum PasswordField {
  /// The password in use now.
  current,

  /// The new password.
  next,

  /// The new password again.
  confirm,
}

/// What is wrong with a password change, field by field.
class PasswordValidation extends Equatable {
  /// Creates a result.
  const PasswordValidation([this.errors = const <PasswordField, String>{}]);

  /// The message for each invalid field.
  final Map<PasswordField, String> errors;

  /// Whether the form can be sent.
  bool get isValid => errors.isEmpty;

  /// The message for [field], or `null`.
  String? operator [](PasswordField field) => errors[field];

  @override
  List<Object?> get props => <Object?>[errors];
}
