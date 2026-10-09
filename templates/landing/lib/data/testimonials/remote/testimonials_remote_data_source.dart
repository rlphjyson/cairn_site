import '../../../common/utils/json.dart';

/// Reads the testimonials as decoded JSON.
abstract interface class TestimonialsRemoteDataSource {
  /// The testimonials section.
  Future<JsonMap> fetchTestimonials();
}

/// Six invented customers. `avatar` is a bundled square portrait.
class InMemoryTestimonialsRemoteDataSource
    implements TestimonialsRemoteDataSource {
  /// Creates the data source.
  const InMemoryTestimonialsRemoteDataSource();

  static const JsonMap _json = <String, Object?>{
    'eyebrow': 'Customers',
    'title': 'Teams ship calmer with Kestrel',
    'subtitle': 'Here is what product leaders say after their first quarter.',
    'items': <Object?>[
      <String, Object?>{
        'quote':
            'We replaced three tools and a weekly status meeting. Our '
            'roadmap is now the one thing everybody trusts.',
        'name': 'Maya Fernandez',
        'role': 'VP Product',
        'company': 'Lumen',
        'avatar': 'assets/images/avatar-maya.jpg',
        'rating': 5,
      },
      <String, Object?>{
        'quote':
            'The workload view paid for itself in a month. We caught a '
            'burnout risk two sprints before it would have hurt.',
        'name': 'Diego Alvarez',
        'role': 'Engineering Manager',
        'company': 'Pinecrest',
        'avatar': 'assets/images/avatar-diego.jpg',
        'rating': 5,
      },
      <String, Object?>{
        'quote':
            'Reporting used to take me a full day every Friday. Now it is a '
            'link I send on Monday morning.',
        'name': 'Amara Okafor',
        'role': 'Head of Operations',
        'company': 'Halcyon',
        'avatar': 'assets/images/avatar-amara.jpg',
        'rating': 5,
      },
      <String, Object?>{
        'quote':
            'Clean, fast and genuinely pleasant to use. Even our most '
            'sceptical engineers adopted it without being asked.',
        'name': 'Samuel Mensah',
        'role': 'Staff Engineer',
        'company': 'Meridian',
        'avatar': 'assets/images/avatar-samuel.jpg',
        'rating': 4.5,
      },
      <String, Object?>{
        'quote':
            'Onboarding took an afternoon. Support answered every question '
            'within the hour, including the odd ones.',
        'name': 'Claire Dubois',
        'role': 'Program Director',
        'company': 'Tidewater',
        'avatar': 'assets/images/avatar-claire.jpg',
        'rating': 5,
      },
      <String, Object?>{
        'quote':
            'Dependencies finally make sense to non-engineers. Planning '
            'conversations are shorter and a lot kinder.',
        'name': 'Elena Torres',
        'role': 'Chief of Staff',
        'company': 'Overland',
        'avatar': 'assets/images/avatar-elena.jpg',
        'rating': 5,
      },
    ],
  };

  @override
  Future<JsonMap> fetchTestimonials() async => _json;
}
