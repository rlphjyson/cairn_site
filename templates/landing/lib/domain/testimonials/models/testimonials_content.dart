import 'package:equatable/equatable.dart';

/// The testimonials section.
class TestimonialsContent extends Equatable {
  /// Creates the content.
  const TestimonialsContent({
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

  /// The quotes.
  final List<Testimonial> items;

  @override
  List<Object?> get props => <Object?>[eyebrow, title, subtitle, items];
}

/// One customer quote.
class Testimonial extends Equatable {
  /// Creates a testimonial.
  const Testimonial({
    required this.quote,
    required this.name,
    required this.role,
    required this.company,
    required this.avatar,
    required this.rating,
  });

  /// What they said.
  final String quote;

  /// Who said it.
  final String name;

  /// Their job title.
  final String role;

  /// Their company.
  final String company;

  /// The avatar image asset.
  final String avatar;

  /// Stars out of five.
  final double rating;

  @override
  List<Object?> get props => <Object?>[
    quote,
    name,
    role,
    company,
    avatar,
    rating,
  ];
}
