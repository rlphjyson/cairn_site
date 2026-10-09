import '../../../common/constants/personalise_sections.dart';
import '../../flow/models/onboarding_flow.dart';
import '../../permissions/models/permission_kind.dart';
import '../../permissions/models/permission_request.dart';
import '../../permissions/models/permission_status.dart';
import '../models/onboarding_progress.dart';
import '../repositories/progress_repository.dart';

/// Reads the saved progress and makes it fit the current flow.
///
/// Content changes between releases, so what was saved may not match what is
/// on offer now. The result is always safe to show:
///
/// * a saved step that the flow no longer has becomes the flow's first step;
/// * the page index is clamped to the pages that exist;
/// * interests, goal, reminder and permissions the flow no longer offers are
///   dropped.
class ResumeProgress {
  /// Creates the use case.
  const ResumeProgress(this._repository);

  final ProgressRepository _repository;

  /// Runs it.
  Future<OnboardingProgress> call(OnboardingFlow flow) async {
    OnboardingProgress? saved;
    try {
      saved = await _repository.read();
    } on Object {
      saved = null;
    }
    if (saved == null) {
      return OnboardingProgress(
        step: flow.first.kind,
        reminderId: flow.reminder(flow.defaultReminderId)?.id,
      );
    }
    final Set<PermissionKind> offered = flow.permissions
        .map((PermissionRequest r) => r.kind)
        .toSet();
    final int lastPage = flow.pages.isEmpty ? 0 : flow.pages.length - 1;
    return OnboardingProgress(
      step: flow.contains(saved.step) ? saved.step : flow.first.kind,
      pageIndex: saved.pageIndex.clamp(0, lastPage),
      section: saved.section.clamp(0, PersonaliseSection.values.length - 1),
      permissions: <PermissionKind, PermissionStatus>{
        for (final MapEntry<PermissionKind, PermissionStatus> e
            in saved.permissions.entries)
          if (offered.contains(e.key)) e.key: e.value,
      },
      interests: saved.interests
          .where((String id) => flow.interest(id) != null)
          .toSet(),
      goalId: flow.goal(saved.goalId)?.id,
      reminderId:
          flow.reminder(saved.reminderId)?.id ??
          flow.reminder(flow.defaultReminderId)?.id,
      accountChoice: saved.accountChoice,
      completed: saved.completed,
    );
  }
}
