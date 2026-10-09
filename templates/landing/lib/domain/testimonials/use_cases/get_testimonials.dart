import '../models/testimonials_content.dart';
import '../repositories/testimonials_repository.dart';

/// Loads the testimonials section's content.
class GetTestimonials {
  /// Creates the use case.
  const GetTestimonials(this._repository);

  final TestimonialsRepository _repository;

  /// Runs the use case.
  Future<TestimonialsContent> call() => _repository.getTestimonials();
}
