import 'package:equatable/equatable.dart';

import '../../shared/models/link.dart';

/// The footer.
class FooterContent extends Equatable {
  /// Creates the content.
  const FooterContent({
    required this.description,
    required this.columns,
    required this.social,
    required this.copyright,
    required this.legal,
  });

  /// The blurb under the brand.
  final String description;

  /// The link columns.
  final List<FooterColumn> columns;

  /// The social icons.
  final List<SocialLink> social;

  /// The copyright line.
  final String copyright;

  /// The small legal links next to the copyright.
  final List<Link> legal;

  @override
  List<Object?> get props => <Object?>[
    description,
    columns,
    social,
    copyright,
    legal,
  ];
}

/// A titled column of links.
class FooterColumn extends Equatable {
  /// Creates a column.
  const FooterColumn({required this.title, required this.links});

  /// The column heading.
  final String title;

  /// The links.
  final List<Link> links;

  @override
  List<Object?> get props => <Object?>[title, links];
}

/// A social profile shown as an icon button.
class SocialLink extends Equatable {
  /// Creates a link.
  const SocialLink({
    required this.label,
    required this.icon,
    required this.href,
  });

  /// The network name, used as the accessible label.
  final String label;

  /// The icon name.
  final String icon;

  /// The profile address.
  final String href;

  @override
  List<Object?> get props => <Object?>[label, icon, href];
}
