import '../models/device_session.dart';
import '../repositories/security_repository.dart';

/// Requests a copy of the person's data.
class ExportData {
  /// Creates the use case.
  const ExportData(this._repository);

  final SecurityRepository _repository;

  /// Files the request. The data is prepared later and sent by email.
  Future<DataExportRequest> call() => _repository.requestExport();
}
