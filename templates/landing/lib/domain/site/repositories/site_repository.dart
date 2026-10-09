import '../models/site_info.dart';

/// Where the site section's content comes from.
abstract interface class SiteRepository {
  /// The section's content.
  Future<SiteInfo> getSiteInfo();
}
