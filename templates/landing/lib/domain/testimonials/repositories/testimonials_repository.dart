import '../models/testimonials_content.dart';

/// Where the testimonials section's content comes from.
abstract interface class TestimonialsRepository {
  /// The section's content.
  Future<TestimonialsContent> getTestimonials();
}
