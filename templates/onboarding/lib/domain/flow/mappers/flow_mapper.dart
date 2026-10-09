import '../../permissions/models/permission_kind.dart';
import '../../permissions/models/permission_request.dart';
import '../../personalise/models/goal.dart';
import '../../personalise/models/interest.dart';
import '../../personalise/models/reminder_option.dart';
import '../models/onboarding_flow.dart';
import '../models/onboarding_step.dart';
import '../models/value_page.dart';

/// Turns the decoded flow JSON into an [OnboardingFlow].
///
/// This is the one place that knows the wire format; `doc/index.html` lists
/// every key. The mapper is forgiving about *structure* so that content can be
/// edited freely:
///
/// * unknown or repeated step kinds are ignored;
/// * `done` is always present and always last;
/// * a `welcome` step with no pages, or a `permissions` step with no cards, is
///   dropped, since there would be nothing to show.
abstract final class FlowMapper {
  /// Maps [json] to a flow.
  static OnboardingFlow fromJson(Map<String, Object?> json) {
    final List<ValuePage> pages = _maps(
      json['pages'],
    ).map(pageFromJson).toList();
    final List<PermissionRequest> permissions = _maps(
      json['permissions'],
    ).map(permissionFromJson).whereType<PermissionRequest>().toList();
    final Map<String, Object?> personalise =
        (json['personalise'] as Map<String, Object?>?) ??
        const <String, Object?>{};

    final List<Interest> interests = _maps(personalise['interests'])
        .map(
          (Map<String, Object?> m) =>
              Interest(id: m['id']! as String, label: m['label']! as String),
        )
        .toList();
    final List<Goal> goals = _maps(personalise['goals'])
        .map(
          (Map<String, Object?> m) => Goal(
            id: m['id']! as String,
            label: m['label']! as String,
            hint: m['hint'] as String? ?? '',
          ),
        )
        .toList();
    final List<ReminderOption> reminders = _maps(personalise['reminders'])
        .map(
          (Map<String, Object?> m) => ReminderOption(
            id: m['id']! as String,
            label: m['label']! as String,
          ),
        )
        .toList();

    return OnboardingFlow(
      steps: _steps(
        json['steps'],
        hasPages: pages.isNotEmpty,
        hasPermissions: permissions.isNotEmpty,
      ),
      pages: pages,
      permissions: permissions,
      interests: interests,
      goals: goals,
      reminders: reminders,
      minInterests: (personalise['minInterests'] as num?)?.toInt() ?? 3,
      defaultReminderId: personalise['defaultReminder'] as String?,
    );
  }

  /// Maps one entry of `pages`.
  static ValuePage pageFromJson(Map<String, Object?> json) => ValuePage(
    id: json['id']! as String,
    title: json['title']! as String,
    body: json['body']! as String,
    asset: json['image']! as String,
    imageLabel: json['imageLabel'] as String? ?? '',
  );

  /// Maps one entry of `permissions`, or returns `null` for an unknown kind.
  static PermissionRequest? permissionFromJson(Map<String, Object?> json) {
    final PermissionKind? kind = PermissionKind.fromKey(
      json['kind'] as String?,
    );
    if (kind == null) return null;
    return PermissionRequest(
      kind: kind,
      title: json['title']! as String,
      benefit: json['benefit']! as String,
      deniedHelp:
          json['deniedHelp'] as String? ??
          'You can turn this on later in your device settings.',
      optional: json['optional'] as bool? ?? true,
    );
  }

  static List<OnboardingStep> _steps(
    Object? raw, {
    required bool hasPages,
    required bool hasPermissions,
  }) {
    final List<Map<String, Object?>> entries = _maps(raw);
    final List<OnboardingStep> steps = <OnboardingStep>[];
    final Set<OnboardingStepKind> seen = <OnboardingStepKind>{};

    void add(OnboardingStep step) {
      if (step.kind == OnboardingStepKind.welcome && !hasPages) return;
      if (step.kind == OnboardingStepKind.permissions && !hasPermissions) {
        return;
      }
      if (step.kind == OnboardingStepKind.done) return;
      if (seen.add(step.kind)) steps.add(step);
    }

    if (entries.isEmpty) {
      for (final OnboardingStepKind kind in OnboardingStepKind.values) {
        add(OnboardingStep(kind: kind));
      }
    }
    OnboardingStep doneStep = const OnboardingStep(
      kind: OnboardingStepKind.done,
    );
    for (final Map<String, Object?> e in entries) {
      final OnboardingStepKind? kind = OnboardingStepKind.fromKey(
        e['kind'] as String?,
      );
      if (kind == null) continue;
      final OnboardingStep step = OnboardingStep(
        kind: kind,
        title: e['title'] as String? ?? '',
        body: e['body'] as String? ?? '',
        skippable: e['skippable'] as bool? ?? true,
      );
      if (kind == OnboardingStepKind.done) {
        doneStep = step;
      } else {
        add(step);
      }
    }
    return <OnboardingStep>[...steps, doneStep];
  }

  static List<Map<String, Object?>> _maps(Object? raw) =>
      ((raw as List<Object?>?) ?? const <Object?>[])
          .cast<Map<String, Object?>>();
}
