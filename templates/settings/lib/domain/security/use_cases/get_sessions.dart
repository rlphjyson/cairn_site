import '../models/device_session.dart';
import '../repositories/security_repository.dart';

/// Lists the devices signed in to the account.
class GetSessions {
  /// Creates the use case.
  const GetSessions(this._repository);

  final SecurityRepository _repository;

  /// The sessions, this device first.
  Future<List<DeviceSession>> call() => _repository.sessions();
}
