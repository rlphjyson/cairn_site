import 'package:equatable/equatable.dart';

import '../../shared/models/app_screen.dart';
import '../../shared/models/link.dart';

/// Everything in the hero.
class HeroContent extends Equatable {
  /// Creates the hero content.
  const HeroContent({
    required this.badge,
    required this.headline,
    required this.subcopy,
    required this.secondaryCta,
    required this.rating,
    required this.ratingText,
    required this.ratingLabel,
    required this.avatars,
    required this.frontScreen,
    required this.backScreen,
  });

  /// The pill above the headline.
  final String badge;

  /// The headline.
  final String headline;

  /// The copy under the headline.
  final String subcopy;

  /// The quiet link next to the store buttons.
  final Link secondaryCta;

  /// The average rating out of five.
  final double rating;

  /// The text beside the stars, such as `4.8 · 120K ratings`.
  final String ratingText;

  /// The accessible description of the rating.
  final String ratingLabel;

  /// Avatar assets for the user stack.
  final List<String> avatars;

  /// The screen on the phone in front.
  final AppScreen frontScreen;

  /// The screen on the phone behind.
  final AppScreen backScreen;

  @override
  List<Object?> get props => <Object?>[
    badge,
    headline,
    subcopy,
    secondaryCta,
    rating,
    ratingText,
    ratingLabel,
    avatars,
    frontScreen,
    backScreen,
  ];
}
