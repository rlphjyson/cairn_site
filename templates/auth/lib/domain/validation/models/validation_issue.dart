/// Why a field's value is not acceptable.
///
/// Issues are plain enum values: the domain says *what* is wrong and the
/// presentation layer decides the words (see `AuthCopy.issue`), which is also
/// where translations plug in.
enum ValidationIssue {
  /// The name is empty.
  nameRequired,

  /// The name is too short.
  nameTooShort,

  /// The email is empty.
  emailRequired,

  /// The email does not look like an address.
  emailInvalid,

  /// The email already belongs to an account (a server verdict).
  emailTaken,

  /// The password is empty.
  passwordRequired,

  /// The password is shorter than the policy allows.
  passwordTooShort,

  /// The password lacks required character kinds.
  passwordTooWeak,

  /// The password is on the list of common passwords.
  passwordTooCommon,

  /// The confirmation is empty.
  confirmationRequired,

  /// The confirmation differs from the password.
  confirmationMismatch,

  /// The terms were not accepted.
  termsRequired,

  /// The code is not a full set of digits.
  codeIncomplete,
}
