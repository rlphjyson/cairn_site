import '../../../domain/progress/mappers/progress_mapper.dart';
import '../../../domain/progress/models/onboarding_progress.dart';
import '../../../domain/progress/repositories/progress_repository.dart';
import '../local/progress_store.dart';

/// [ProgressRepository] backed by a [ProgressStore].
class ProgressRepositoryImpl implements ProgressRepository {
  /// Creates the repository.
  ProgressRepositoryImpl(this._store);

  final ProgressStore _store;

  @override
  Future<OnboardingProgress?> read() async {
    final Map<String, Object?>? json = await _store.read();
    return json == null ? null : ProgressMapper.fromJson(json);
  }

  @override
  Future<void> write(OnboardingProgress progress) =>
      _store.write(ProgressMapper.toJson(progress));

  @override
  Future<void> clear() => _store.clear();
}
