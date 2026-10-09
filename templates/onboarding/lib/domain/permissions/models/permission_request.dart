import 'package:equatable/equatable.dart';

import 'permission_kind.dart';

/// The copy for one permission card on the permissions step.
class PermissionRequest extends Equatable {
  /// Creates a request.
  const PermissionRequest({
    required this.kind,
    required this.title,
    required this.benefit,
    required this.deniedHelp,
    this.optional = true,
  });

  /// Which permission this asks for.
  final PermissionKind kind;

  /// The card title, such as "Notifications".
  final String title;

  /// Why the user would want to allow it.
  final String benefit;

  /// What to do to enable it later, shown when the user has declined.
  final String deniedHelp;

  /// Whether the user can carry on without it. Today every permission is
  /// optional; the flag is there for hosts that need one required.
  final bool optional;

  @override
  List<Object?> get props => <Object?>[
    kind,
    title,
    benefit,
    deniedHelp,
    optional,
  ];
}
