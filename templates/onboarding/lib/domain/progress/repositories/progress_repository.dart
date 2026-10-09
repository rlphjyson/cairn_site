import '../models/onboarding_progress.dart';

/// Keeps the user's progress between launches.
abstract interface class ProgressRepository {
  /// The saved progress, or `null` when there is none (or it is unreadable).
  Future<OnboardingProgress?> read();

  /// Saves [progress].
  Future<void> write(OnboardingProgress progress);

  /// Forgets everything.
  Future<void> clear();
}
