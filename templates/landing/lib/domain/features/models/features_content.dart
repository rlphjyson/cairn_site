import 'package:equatable/equatable.dart';

import '../../shared/models/link.dart';

/// The features section: a grid of cards and image-led spotlights.
class FeaturesContent extends Equatable {
  /// Creates the content.
  const FeaturesContent({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.items,
    required this.spotlights,
  });

  /// The label above the title.
  final String eyebrow;

  /// The section title.
  final String title;

  /// The copy under the title.
  final String subtitle;

  /// The grid cards.
  final List<FeatureItem> items;

  /// The alternating image rows.
  final List<Spotlight> spotlights;

  @override
  List<Object?> get props => <Object?>[
    eyebrow,
    title,
    subtitle,
    items,
    spotlights,
  ];
}

/// One card in the feature grid.
class FeatureItem extends Equatable {
  /// Creates an item.
  const FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    this.tag,
  });

  /// The icon name.
  final String icon;

  /// The feature name.
  final String title;

  /// A sentence or two about it.
  final String description;

  /// An optional badge such as "New".
  final String? tag;

  @override
  List<Object?> get props => <Object?>[icon, title, description, tag];
}

/// One image-and-copy row.
class Spotlight extends Equatable {
  /// Creates a spotlight.
  const Spotlight({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.bullets,
    required this.image,
    required this.imageAlt,
    this.cta,
  });

  /// The label above the title.
  final String eyebrow;

  /// The title.
  final String title;

  /// The paragraph.
  final String description;

  /// A short checklist.
  final List<String> bullets;

  /// The image asset.
  final String image;

  /// What the image shows, for screen readers.
  final String imageAlt;

  /// An optional link under the copy.
  final Link? cta;

  @override
  List<Object?> get props => <Object?>[
    eyebrow,
    title,
    description,
    bullets,
    image,
    imageAlt,
    cta,
  ];
}
