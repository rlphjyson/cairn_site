import '../../../common/utils/json.dart';
import '../../../domain/waitlist/models/join_outcome.dart';

/// Reads the waitlist copy and submits signups.
abstract interface class WaitlistRemoteDataSource {
  /// The section copy as decoded JSON.
  Future<JsonMap> fetchWaitlist();

  /// Submits [email]; returns the service response as decoded JSON.
  ///
  /// Throws a `WaitlistException` when the service refuses.
  Future<JsonMap> submit(String email);
}

/// A stand-in for a real service.
///
/// It waits [latency], then accepts any email, except addresses ending in
/// `@fail.example`, which are refused so the error state can be tried out.
/// To go live, implement [WaitlistRemoteDataSource] against your provider and
/// register it in `core/infrastructure/di/landing_injection.dart`.
class InMemoryWaitlistRemoteDataSource implements WaitlistRemoteDataSource {
  /// Creates the data source.
  InMemoryWaitlistRemoteDataSource({
    this.latency = const Duration(milliseconds: 700),
  });

  /// How long a signup takes.
  final Duration latency;

  int _next = 1284;

  static const JsonMap _json = <String, Object?>{
    'eyebrow': 'Early access',
    'title': 'Be first in line for Kestrel',
    'subtitle':
        'Join the waitlist and we will invite you as soon as your spot '
        'opens up. Early members get three months of Team free.',
    'placeholder': 'you@company.com',
    'buttonLabel': 'Join the waitlist',
    'privacyNote': 'No spam, ever. Unsubscribe with one click.',
    'successTitle': 'You are on the list!',
    'successMessage':
        'Thanks for joining. Check your inbox for a confirmation email.',
  };

  @override
  Future<JsonMap> fetchWaitlist() async => _json;

  @override
  Future<JsonMap> submit(String email) async {
    await Future<void>.delayed(latency);
    if (email.toLowerCase().endsWith('@fail.example')) {
      throw const WaitlistException(
        'We could not add you right now. Please try again in a moment.',
      );
    }
    return <String, Object?>{'position': _next++};
  }
}
