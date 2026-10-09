import '../models/site_info.dart';

/// Where the site content comes from.
abstract interface class SiteRepository {
  /// The section content.
  Future<SiteInfo> getSiteInfo();
}
