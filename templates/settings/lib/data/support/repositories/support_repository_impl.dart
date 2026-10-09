import '../../../domain/shared/mappers/action_result_mapper.dart';
import '../../../domain/shared/models/action_result.dart';
import '../../../domain/support/models/support_request.dart';
import '../../../domain/support/repositories/support_repository.dart';
import '../../settings/remote/settings_data_source.dart';

/// Support messages, through a [SettingsDataSource].
class SupportRepositoryImpl implements SupportRepository {
  /// Creates the repository.
  const SupportRepositoryImpl(this._source);

  final SettingsDataSource _source;

  @override
  Future<ActionResult> submit(SupportRequest request) async =>
      ActionResultMapper.fromJson(
        await _source.submitSupportRequest(<String, Object?>{
          'subject': request.subject,
          'message': request.message,
        }),
      );
}
