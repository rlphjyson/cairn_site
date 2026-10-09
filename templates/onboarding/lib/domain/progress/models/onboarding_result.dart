import 'package:equatable/equatable.dart';

import '../../permissions/models/permission_kind.dart';
import '../../permissions/models/permission_status.dart';
import 'account_choice.dart';

/// What the host receives when the user presses Start.
class OnboardingResult extends Equatable {
  /// Creates a result.
  const OnboardingResult({
    required this.interests,
    required this.goalId,
    required this.reminderId,
    required this.permissions,
    required this.accountChoice,
  });

  /// The chosen interest ids, in the order the flow lists them.
  final List<String> interests;

  /// The chosen goal id, or `null` when the flow has no personalise step.
  final String? goalId;

  /// The chosen reminder option id, or `null` for none.
  final String? reminderId;

  /// The answer to every permission that was asked for.
  final Map<PermissionKind, PermissionStatus> permissions;

  /// What the user chose on the account step. [AccountChoice.guest] when the
  /// flow has no account step or it was skipped.
  final AccountChoice accountChoice;

  @override
  List<Object?> get props => <Object?>[
    interests,
    goalId,
    reminderId,
    permissions,
    accountChoice,
  ];
}
