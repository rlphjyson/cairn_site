import '../models/onboarding_flow.dart';

/// Where the flow's content comes from.
abstract interface class FlowRepository {
  /// Loads the flow.
  Future<OnboardingFlow> getFlow();
}
