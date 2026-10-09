import 'package:equatable/equatable.dart';

import 'account.dart';

/// A signed-in session: who, and the token that proves it.
///
/// The template keeps this in memory only, for the life of the mounted
/// [AuthApp]. Persist the token in secure storage yourself (see the docs).
/// [accessToken] and [refreshToken] are left out of [props] and of [toString] so
/// they cannot leak
/// through a logged or equatable-printed state.
class Session extends Equatable {
  /// Creates a session.
  const Session({
    required this.account,
    required this.accessToken,
    this.refreshToken,
    this.expiresAt,
    this.remembered = false,
  });

  /// Who is signed in.
  final Account account;

  /// The bearer token for API calls. Treat it like a password.
  final String accessToken;

  /// The long-lived token that gets a new [accessToken], when the server issues
  /// one. This is the only value worth putting in secure storage.
  final String? refreshToken;

  /// When the token stops working, or `null` when the server did not say.
  final DateTime? expiresAt;

  /// Whether the person asked to stay signed in ("Remember me").
  final bool remembered;

  @override
  List<Object?> get props => <Object?>[account, expiresAt, remembered];

  @override
  String toString() => 'Session(${account.email}, token: <redacted>)';
}
