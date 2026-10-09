import 'package:equatable/equatable.dart';

/// How a wordmark is set.
enum WordmarkStyle {
  /// Heavy sans.
  bold,

  /// Light, widely tracked sans.
  light,

  /// Bold italic.
  italic,

  /// Medium weight with wide letter spacing.
  spaced,
}

/// The trusted-by strip.
class LogoCloud extends Equatable {
  /// Creates the strip.
  const LogoCloud({required this.heading, required this.logos});

  /// The line above the logos.
  final String heading;

  /// The companies.
  final List<CompanyLogo> logos;

  @override
  List<Object?> get props => <Object?>[heading, logos];
}

/// A fictional company drawn as a glyph and a wordmark.
class CompanyLogo extends Equatable {
  /// Creates a logo.
  const CompanyLogo({
    required this.name,
    required this.icon,
    required this.style,
  });

  /// The company name.
  final String name;

  /// The icon name.
  final String icon;

  /// How the wordmark is set.
  final WordmarkStyle style;

  @override
  List<Object?> get props => <Object?>[name, icon, style];
}
