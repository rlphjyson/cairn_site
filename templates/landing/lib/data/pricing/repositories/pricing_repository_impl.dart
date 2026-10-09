import '../../../domain/pricing/mappers/pricing_mapper.dart';
import '../../../domain/pricing/models/pricing_content.dart';
import '../../../domain/pricing/repositories/pricing_repository.dart';
import '../remote/pricing_remote_data_source.dart';

/// Reads pricing content from a remote data source and maps it.
class PricingRepositoryImpl implements PricingRepository {
  /// Creates the repository.
  const PricingRepositoryImpl(this._remote);

  final PricingRemoteDataSource _remote;

  @override
  Future<PricingContent> getPricing() async =>
      mapPricing(await _remote.fetchPricing());
}
