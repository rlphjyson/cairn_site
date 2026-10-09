import '../../../common/utils/settings_failure.dart';
import '../models/setting_definition.dart';
import '../models/settings_snapshot.dart';
import '../registry/settings_registry.dart';
import '../repositories/settings_repository.dart';

/// Changes one setting and persists the result.
///
/// The value is checked against the definition first, so nothing invalid is
/// ever stored.
class UpdateSetting {
  /// Creates the use case.
  const UpdateSetting(this._registry, this._repository);

  final SettingsRegistry _registry;
  final SettingsRepository _repository;

  /// The snapshot [current] with [id] set to [value], without saving it.
  ///
  /// Throws a [SettingsFailure] when [id] is unknown, is not a stored kind, or
  /// [value] is not valid for it.
  SettingsSnapshot apply(SettingsSnapshot current, String id, Object? value) {
    final SettingDefinition? definition = _registry.byId(id);
    if (definition == null) {
      throw SettingsFailure('There is no setting called "$id".');
    }
    if (!definition.accepts(value)) {
      throw SettingsFailure(
        '"$value" is not a valid value for ${definition.title}.',
      );
    }
    return current.set(id, value);
  }

  /// Applies the change and saves it. Returns the new snapshot.
  Future<SettingsSnapshot> call(
    SettingsSnapshot current,
    String id,
    Object? value,
  ) async {
    final SettingsSnapshot next = apply(current, id, value);
    await persist(next);
    return next;
  }

  /// Saves [snapshot] as it is.
  Future<void> persist(SettingsSnapshot snapshot) => _repository.save(snapshot);
}
