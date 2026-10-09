import '../models/logo_cloud.dart';

/// Where the logos section's content comes from.
abstract interface class LogosRepository {
  /// The section's content.
  Future<LogoCloud> getLogoCloud();
}
