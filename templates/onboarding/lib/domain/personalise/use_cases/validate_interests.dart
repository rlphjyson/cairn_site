import '../models/interest.dart';
import '../models/interests_validation.dart';

/// Checks that enough known interests are chosen.
///
/// Ids the flow does not offer (left over from an older version of the content)
/// are ignored, so they can never satisfy the minimum.
class ValidateInterests {
  /// Creates the use case.
  const ValidateInterests();

  /// Runs it.
  InterestsValidation call({
    required Set<String> selected,
    required Iterable<Interest> available,
    required int min,
  }) {
    final Set<String> known = available.map((Interest i) => i.id).toSet();
    return InterestsValidation(
      count: selected.where(known.contains).length,
      min: min,
    );
  }
}
