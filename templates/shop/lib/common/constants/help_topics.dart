/// A question and its answer, for the profile's help section.
class HelpTopic {
  /// Creates a topic.
  const HelpTopic(this.id, this.question, this.answer);

  /// Stable key.
  final String id;

  /// The question.
  final String question;

  /// The answer.
  final String answer;
}

/// The help topics, in display order.
abstract final class HelpTopics {
  /// Every topic.
  static const List<HelpTopic> values = <HelpTopic>[
    HelpTopic(
      'shipping',
      'How long does delivery take?',
      'Standard delivery takes about 5 business days and is free on orders '
          'of \$150 or more. Express takes about 2 business days for \$12.',
    ),
    HelpTopic(
      'returns',
      'Can I return something?',
      'Yes. Unworn items can be returned within 30 days of delivery for a '
          'full refund.',
    ),
    HelpTopic(
      'contact',
      'How do I contact support?',
      'Email help@example.com and we will reply within one working day.',
    ),
  ];
}
