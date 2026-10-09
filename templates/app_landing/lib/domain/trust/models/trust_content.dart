import 'package:equatable/equatable.dart';

/// How a press wordmark is set in type.
enum WordmarkStyle {
  /// Heavy and tight.
  bold,

  /// Thin and wide.
  light,

  /// Italic.
  italic,

  /// Small and widely letter-spaced.
  spaced,
}

/// The press and awards strip.
class TrustContent extends Equatable {
  /// Creates the content.
  const TrustContent({
    required this.heading,
    required this.press,
    required this.awards,
  });

  /// The line above the wordmarks.
  final String heading;

  /// The press mentions.
  final List<PressMention> press;

  /// The award badges.
  final List<Award> awards;

  @override
  List<Object?> get props => <Object?>[heading, press, awards];
}

/// A publication that wrote about the app, drawn as a text wordmark.
class PressMention extends Equatable {
  /// Creates a mention.
  const PressMention({
    required this.name,
    required this.style,
    required this.quote,
  });

  /// The invented publication name.
  final String name;

  /// How the wordmark is set.
  final WordmarkStyle style;

  /// A short quote, used as the accessible description.
  final String quote;

  @override
  List<Object?> get props => <Object?>[name, style, quote];
}

/// An award badge.
class Award extends Equatable {
  /// Creates an award.
  const Award({required this.title, required this.issuer, required this.icon});

  /// The award, such as `App of the Day`.
  final String title;

  /// Who gave it and when.
  final String issuer;

  /// The glyph name.
  final String icon;

  @override
  List<Object?> get props => <Object?>[title, issuer, icon];
}
