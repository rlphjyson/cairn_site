import '../../../domain/flow/mappers/flow_mapper.dart';
import '../../../domain/flow/models/onboarding_flow.dart';
import '../../../domain/flow/repositories/flow_repository.dart';
import '../remote/flow_remote_data_source.dart';

/// [FlowRepository] backed by a [FlowRemoteDataSource].
class FlowRepositoryImpl implements FlowRepository {
  /// Creates the repository.
  FlowRepositoryImpl(this._dataSource);

  final FlowRemoteDataSource _dataSource;
  OnboardingFlow? _cache;

  @override
  Future<OnboardingFlow> getFlow() async =>
      _cache ??= FlowMapper.fromJson(await _dataSource.fetchFlow());
}
