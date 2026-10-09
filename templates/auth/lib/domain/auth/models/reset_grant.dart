import 'package:equatable/equatable.dart';

/// Proof that a verification code was right, good for one password reset.
///
/// A short-lived, single-use token the server issues when the code checks out.
/// Redacted from [toString] like a session token.
class ResetGrant extends Equatable {
  /// Creates a grant.
  const ResetGrant(this.token);

  /// The opaque token to send with the new password.
  final String token;

  @override
  List<Object?> get props => <Object?>[token];

  @override
  String toString() => 'ResetGrant(<redacted>)';
}
