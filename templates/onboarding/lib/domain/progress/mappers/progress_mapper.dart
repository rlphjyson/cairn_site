import '../../flow/models/onboarding_step.dart';
import '../../permissions/models/permission_kind.dart';
import '../../permissions/models/permission_status.dart';
import '../models/account_choice.dart';
import '../models/onboarding_progress.dart';

/// Converts [OnboardingProgress] to and from the JSON a `ProgressStore` keeps.
abstract final class ProgressMapper {
  /// Bumped when the saved shape changes incompatibly; older data is ignored.
  static const int version = 1;

  /// Writes [progress] as JSON.
  static Map<String, Object?> toJson(OnboardingProgress progress) =>
      <String, Object?>{
        'version': version,
        'step': progress.step.name,
        'pageIndex': progress.pageIndex,
        'section': progress.section,
        'permissions': <String, Object?>{
          for (final MapEntry<PermissionKind, PermissionStatus> e
              in progress.permissions.entries)
            e.key.key: e.value.name,
        },
        'interests': progress.interests.toList(),
        'goalId': progress.goalId,
        'reminderId': progress.reminderId,
        'accountChoice': progress.accountChoice?.name,
        'completed': progress.completed,
      };

  /// Reads progress from [json]. Returns `null` for data that is not valid
  /// progress (an older version, or a corrupt file), so the flow starts over
  /// rather than crashing.
  static OnboardingProgress? fromJson(Map<String, Object?> json) {
    try {
      if (json['version'] != version) return null;
      final OnboardingStepKind? step = OnboardingStepKind.fromKey(
        json['step'] as String?,
      );
      if (step == null) return null;
      final Map<String, Object?> rawPermissions =
          (json['permissions'] as Map<String, Object?>?) ??
          const <String, Object?>{};
      final Map<PermissionKind, PermissionStatus> permissions =
          <PermissionKind, PermissionStatus>{};
      for (final MapEntry<String, Object?> e in rawPermissions.entries) {
        final PermissionKind? kind = PermissionKind.fromKey(e.key);
        if (kind != null) {
          permissions[kind] = PermissionStatus.fromKey(e.value as String?);
        }
      }
      return OnboardingProgress(
        step: step,
        pageIndex: (json['pageIndex'] as num?)?.toInt() ?? 0,
        section: (json['section'] as num?)?.toInt() ?? 0,
        permissions: permissions,
        interests: ((json['interests'] as List<Object?>?) ?? const <Object?>[])
            .cast<String>()
            .toSet(),
        goalId: json['goalId'] as String?,
        reminderId: json['reminderId'] as String?,
        accountChoice: AccountChoice.fromKey(json['accountChoice'] as String?),
        completed: json['completed'] as bool? ?? false,
      );
    } on Object {
      return null;
    }
  }
}
