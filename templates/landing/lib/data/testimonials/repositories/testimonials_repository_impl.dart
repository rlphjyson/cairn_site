import '../../../domain/testimonials/mappers/testimonials_mapper.dart';
import '../../../domain/testimonials/models/testimonials_content.dart';
import '../../../domain/testimonials/repositories/testimonials_repository.dart';
import '../remote/testimonials_remote_data_source.dart';

/// Reads testimonials content from a remote data source and maps it.
class TestimonialsRepositoryImpl implements TestimonialsRepository {
  /// Creates the repository.
  const TestimonialsRepositoryImpl(this._remote);

  final TestimonialsRemoteDataSource _remote;

  @override
  Future<TestimonialsContent> getTestimonials() async =>
      mapTestimonials(await _remote.fetchTestimonials());
}
