import '../../../common/utils/json.dart';

/// Reads the FAQ as decoded JSON.
abstract interface class FaqRemoteDataSource {
  /// The FAQ section.
  Future<JsonMap> fetchFaq();
}

/// The demo questions. Each `id` must be unique.
class InMemoryFaqRemoteDataSource implements FaqRemoteDataSource {
  /// Creates the data source.
  const InMemoryFaqRemoteDataSource();

  static const JsonMap _json = <String, Object?>{
    'eyebrow': 'FAQ',
    'title': 'Questions, answered',
    'subtitle': 'Can not find what you are looking for? We are happy to help.',
    'items': <Object?>[
      <String, Object?>{
        'id': 'trial',
        'question': 'Is there a free trial?',
        'answer':
            'Yes. Every paid plan starts with a 14-day trial and no credit '
            'card. The Starter plan is free forever.',
      },
      <String, Object?>{
        'id': 'import',
        'question': 'Can I import my existing work?',
        'answer':
            'You can import from CSV files and from the most popular '
            'project tools. Our importer keeps statuses, assignees and '
            'due dates intact.',
      },
      <String, Object?>{
        'id': 'seats',
        'question': 'How does seat-based billing work?',
        'answer':
            'You pay for each person who can edit. Guests and viewers are '
            'always free, so stakeholders never cost you extra.',
      },
      <String, Object?>{
        'id': 'cancel',
        'question': 'Can I change or cancel my plan?',
        'answer':
            'At any time, from your billing settings. Upgrades apply '
            'immediately; downgrades take effect at the end of the period.',
      },
      <String, Object?>{
        'id': 'security',
        'question': 'How do you keep our data safe?',
        'answer':
            'Data is encrypted in transit and at rest, backed up every hour '
            'and stored in your chosen region. Scale adds single sign-on and '
            'audit logs.',
      },
      <String, Object?>{
        'id': 'discount',
        'question': 'Do you offer discounts?',
        'answer':
            'Yearly billing saves 20%. Nonprofits, schools and open-source '
            'projects qualify for an additional discount.',
      },
    ],
    'contactText': 'Still have questions?',
    'contact': <String, Object?>{
      'label': 'Talk to us',
      'href': 'mailto:hello@kestrel.example',
    },
  };

  @override
  Future<JsonMap> fetchFaq() async => _json;
}
