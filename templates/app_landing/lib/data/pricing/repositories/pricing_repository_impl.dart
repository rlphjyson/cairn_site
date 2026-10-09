import '../../../common/constants/content_sections.dart';
import '../../../domain/pricing/mappers/pricing_mapper.dart';
import '../../../domain/pricing/models/pricing_content.dart';
import '../../../domain/pricing/repositories/pricing_repository.dart';
import '../../content/remote/app_content_data_source.dart';

/// Reads the pricing content from the content data source and maps it.
class PricingRepositoryImpl implements PricingRepository {
  /// Creates the repository.
  const PricingRepositoryImpl(this._content);

  final AppContentDataSource _content;

  @override
  Future<PricingContent> getPricing() async =>
      mapPricing(await _content.fetchSection(ContentSections.pricing));
}
