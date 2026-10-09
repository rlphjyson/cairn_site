import '../../../common/utils/clock.dart';
import '../../../domain/auth/mappers/auth_mapper.dart';
import '../../../domain/auth/models/auth_failure.dart';
import '../../../domain/auth/models/reset_grant.dart';
import '../../../domain/auth/models/session.dart';
import '../../../domain/auth/models/social_provider.dart';
import '../../../domain/auth/repositories/auth_repository.dart';
import '../remote/auth_remote_data_source.dart';

/// [AuthRepository] backed by an [AuthRemoteDataSource].
///
/// Maps the data source's JSON to models and turns anything that is not an
/// [AuthException] (a dropped connection, a timeout, a malformed body) into
/// [AuthFailure.network] or [AuthFailure.unknown].
class AuthRepositoryImpl implements AuthRepository {
  /// Creates the repository. [clock] stamps session expiry.
  AuthRepositoryImpl(this._dataSource, {this._clock = systemClock});

  final AuthRemoteDataSource _dataSource;
  final Clock _clock;

  @override
  Future<Session> signIn({
    required String email,
    required String password,
    required bool remember,
  }) => _guard(() async {
    final Map<String, Object?> json = await _dataSource.signIn(
      email: email,
      password: password,
      remember: remember,
    );
    return AuthMapper.sessionFromJson(
      json,
      now: _clock(),
      remembered: remember,
    );
  });

  @override
  Future<Session> signUp({
    required String name,
    required String email,
    required String password,
  }) => _guard(() async {
    final Map<String, Object?> json = await _dataSource.signUp(
      name: name,
      email: email,
      password: password,
    );
    return AuthMapper.sessionFromJson(json, now: _clock());
  });

  @override
  Future<Session> signInWithProvider({
    required SocialProvider provider,
    required String idToken,
  }) => _guard(() async {
    final Map<String, Object?> json = await _dataSource.signInWithProvider(
      provider: provider.id,
      idToken: idToken,
    );
    return AuthMapper.sessionFromJson(json, now: _clock());
  });

  @override
  Future<void> requestPasswordReset(String email) => _guard(() async {
    final Map<String, Object?> json = await _dataSource.requestPasswordReset(
      email: email,
    );
    AuthMapper.throwIfError(json);
  });

  @override
  Future<ResetGrant> verifyCode({
    required String email,
    required String code,
  }) => _guard(() async {
    final Map<String, Object?> json = await _dataSource.verifyCode(
      email: email,
      code: code,
    );
    return AuthMapper.resetGrantFromJson(json);
  });

  @override
  Future<void> resetPassword({
    required ResetGrant grant,
    required String password,
  }) => _guard(() async {
    final Map<String, Object?> json = await _dataSource.resetPassword(
      resetToken: grant.token,
      password: password,
    );
    AuthMapper.throwIfError(json);
  });

  @override
  Future<void> signOut() => _guard(() async {
    final Map<String, Object?> json = await _dataSource.signOut();
    AuthMapper.throwIfError(json);
  });

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on AuthException {
      rethrow;
    } on Exception {
      // Sockets, timeouts, TLS and decoding errors are all Exceptions.
      throw const AuthException(AuthFailure.network);
    } on Error {
      // A body that does not have the documented shape.
      throw const AuthException(AuthFailure.unknown);
    }
  }
}
