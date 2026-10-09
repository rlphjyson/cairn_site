import 'package:equatable/equatable.dart';

/// A device signed in to the account.
class DeviceSession extends Equatable {
  /// Creates a session.
  const DeviceSession({
    required this.id,
    required this.device,
    required this.location,
    required this.lastActive,
    this.isCurrent = false,
  });

  /// A unique id.
  final String id;

  /// What the device is, such as `Pixel 9 (Android)`.
  final String device;

  /// Roughly where it signed in from.
  final String location;

  /// When it last used the account.
  final DateTime lastActive;

  /// Whether this is the device the person is holding. It cannot be revoked
  /// from here; use Sign out.
  final bool isCurrent;

  @override
  List<Object?> get props => <Object?>[
    id,
    device,
    location,
    lastActive,
    isCurrent,
  ];
}

/// Someone the person has blocked.
class BlockedUser extends Equatable {
  /// Creates a blocked user.
  const BlockedUser({
    required this.id,
    required this.name,
    required this.username,
  });

  /// A unique id.
  final String id;

  /// Their display name.
  final String name;

  /// Their username, without the `@`.
  final String username;

  @override
  List<Object?> get props => <Object?>[id, name, username];
}

/// What the person scans or types into an authenticator app.
class TwoFactorSetup extends Equatable {
  /// Creates a setup.
  const TwoFactorSetup({required this.secret});

  /// The shared secret, in groups of four for reading aloud.
  final String secret;

  @override
  List<Object?> get props => <Object?>[secret];
}

/// A request for a copy of the person's data.
class DataExportRequest extends Equatable {
  /// Creates a request.
  const DataExportRequest({required this.id, required this.requestedAt});

  /// A reference the person can quote.
  final String id;

  /// When it was made.
  final DateTime requestedAt;

  @override
  List<Object?> get props => <Object?>[id, requestedAt];
}
