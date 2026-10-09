/// Everything that says "Northgate Goods" lives in this file.
///
/// To rebrand the store, edit the values below, replace `web/favicon.svg`,
/// `web/icons/*` and `web/images/og-cover.jpg`, and set `SITE_URL`. Nothing
/// else in the codebase hard-codes the shop's name, copy or contact details.
library;

abstract final class Brand {
  static const String name = 'Northgate Goods';
  static const String legalName = 'Northgate Goods Ltd.';
  static const String shortName = 'Northgate';
  static const String tagline = 'Considered everyday objects';
  static const String description =
      'Northgate Goods is a small shop for well-made everyday objects: sneakers, headphones, watches, '
      'bags and desk essentials. Free shipping over \$75.';

  static const String supportEmail = 'hello@northgate.example';
  static const String phone = '+1-555-0142';
  static const String twitterHandle = '@northgategoods';
  static const String locale = 'en_US';
  static const String language = 'en';
  static const String currency = 'USD';

  /// Brand colour reported to browsers (address bar tint).
  static const String themeColorLight = '#ffffff';
  static const String themeColorDark = '#0a0a0a';

  static const String ogImagePath = '/images/og-cover.jpg';
  static const int ogImageWidth = 1200;
  static const int ogImageHeight = 630;
  static const String ogImageAlt = 'A tidy desk with a notebook, a mug and a plant';

  /// Social profiles for the Organization `sameAs` property.
  static const List<String> sameAs = [
    'https://www.instagram.com/northgategoods',
    'https://twitter.com/northgategoods',
  ];

  static const String address1 = '12 Harbour Row';
  static const String addressCity = 'Portland';
  static const String addressRegion = 'ME';
  static const String addressPostal = '04101';
  static const String addressCountry = 'US';
}
