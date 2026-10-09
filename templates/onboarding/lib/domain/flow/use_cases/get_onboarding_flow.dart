import '../models/onboarding_flow.dart';
import '../repositories/flow_repository.dart';

/// Loads the flow's content.
class GetOnboardingFlow {
  /// Creates the use case.
  const GetOnboardingFlow(this._repository);

  final FlowRepository _repository;

  /// Runs it.
  Future<OnboardingFlow> call() => _repository.getFlow();
}
