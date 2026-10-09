/// The inputs the forms collect. Used to attach an issue to the right field.
enum AuthField {
  /// A person's display name.
  name,

  /// An email address.
  email,

  /// A password (new or current).
  password,

  /// The repeated new password.
  confirmation,

  /// The terms checkbox.
  terms,

  /// A one-time verification code.
  code,
}
