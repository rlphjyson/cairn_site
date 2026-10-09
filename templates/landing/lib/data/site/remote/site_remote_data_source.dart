import '../../../common/utils/json.dart';

/// Reads the brand and navbar as decoded JSON.
abstract interface class SiteRemoteDataSource {
  /// The brand and the navbar.
  Future<JsonMap> fetchSiteInfo();
}

/// The demo brand: change the product name, tagline and navbar links here.
///
/// A `#` href scrolls to the section with that id (see `SectionIds`); any
/// other href is passed to the `onLink` callback of `LandingApp`.
class InMemorySiteRemoteDataSource implements SiteRemoteDataSource {
  /// Creates the data source.
  const InMemorySiteRemoteDataSource();

  static const JsonMap _json = <String, Object?>{
    'brandName': 'Kestrel',
    'brandIcon': 'explore',
    'tagline': 'Plan, track and ship work your whole team can see.',
    'navLinks': <Object?>[
      <String, Object?>{'label': 'Features', 'href': '#features'},
      <String, Object?>{'label': 'How it works', 'href': '#how-it-works'},
      <String, Object?>{'label': 'Customers', 'href': '#testimonials'},
      <String, Object?>{'label': 'Pricing', 'href': '#pricing'},
      <String, Object?>{'label': 'FAQ', 'href': '#faq'},
    ],
    'signIn': <String, Object?>{'label': 'Sign in', 'href': '/sign-in'},
    'cta': <String, Object?>{'label': 'Get started', 'href': '#waitlist'},
  };

  @override
  Future<JsonMap> fetchSiteInfo() async => _json;
}
