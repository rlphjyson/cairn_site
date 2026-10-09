import '../models/trust_content.dart';

/// Where the trust content comes from.
abstract interface class TrustRepository {
  /// The section content.
  Future<TrustContent> getTrust();
}
