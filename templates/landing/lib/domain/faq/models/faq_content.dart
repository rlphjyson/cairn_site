import 'package:equatable/equatable.dart';

import '../../shared/models/link.dart';

/// The FAQ section.
class FaqContent extends Equatable {
  /// Creates the content.
  const FaqContent({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.items,
    required this.contactText,
    required this.contact,
  });

  /// The label above the title.
  final String eyebrow;

  /// The section title.
  final String title;

  /// The copy under the title.
  final String subtitle;

  /// The questions.
  final List<FaqItem> items;

  /// The sentence before the contact link.
  final String contactText;

  /// The contact link.
  final Link contact;

  @override
  List<Object?> get props => <Object?>[
    eyebrow,
    title,
    subtitle,
    items,
    contactText,
    contact,
  ];
}

/// One question and its answer.
class FaqItem extends Equatable {
  /// Creates an item.
  const FaqItem({
    required this.id,
    required this.question,
    required this.answer,
  });

  /// A stable id, used as the accordion value.
  final String id;

  /// The question.
  final String question;

  /// The answer.
  final String answer;

  @override
  List<Object?> get props => <Object?>[id, question, answer];
}
