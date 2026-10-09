import 'package:equatable/equatable.dart';

import '../../shared/models/link.dart';

/// The brand and the navbar.
class SiteInfo extends Equatable {
  /// Creates the site info.
  const SiteInfo({
    required this.brandName,
    required this.brandIcon,
    required this.tagline,
    required this.navLinks,
    required this.signIn,
    required this.cta,
  });

  /// The product name.
  final String brandName;

  /// The icon name for the logo mark (see `LandingIcons`).
  final String brandIcon;

  /// A one-line description of the product.
  final String tagline;

  /// The navbar links; `#` hrefs scroll to a section.
  final List<Link> navLinks;

  /// The quiet navbar action.
  final Link signIn;

  /// The primary navbar button.
  final Link cta;

  @override
  List<Object?> get props => <Object?>[
    brandName,
    brandIcon,
    tagline,
    navLinks,
    signIn,
    cta,
  ];
}
