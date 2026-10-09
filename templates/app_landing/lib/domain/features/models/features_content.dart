import 'package:equatable/equatable.dart';

import '../../shared/models/app_screen.dart';

/// The feature showcase: a tab per feature and the phone screen beside it.
class FeaturesContent extends Equatable {
  /// Creates the content.
  const FeaturesContent({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.items,
  });

  /// The label above the title.
  final String eyebrow;

  /// The section title.
  final String title;

  /// The copy under the title.
  final String subtitle;

  /// The features, in tab order.
  final List<Feature> items;

  /// The feature with [id], or the first one.
  Feature byId(String id) =>
      items.firstWhere((Feature f) => f.id == id, orElse: () => items.first);

  @override
  List<Object?> get props => <Object?>[eyebrow, title, subtitle, items];
}

/// One feature: its copy and the screen that shows it off.
class Feature extends Equatable {
  /// Creates a feature.
  const Feature({
    required this.id,
    required this.tabLabel,
    required this.icon,
    required this.title,
    required this.body,
    required this.bullets,
    required this.screen,
  });

  /// A stable id.
  final String id;

  /// The short tab label.
  final String tabLabel;

  /// The glyph name.
  final String icon;

  /// The feature title.
  final String title;

  /// The paragraph.
  final String body;

  /// A short checklist.
  final List<String> bullets;

  /// The live phone screen.
  final AppScreen screen;

  @override
  List<Object?> get props => <Object?>[
    id,
    tabLabel,
    icon,
    title,
    body,
    bullets,
    screen,
  ];
}
