import '../../../domain/download/models/send_outcome.dart';

/// Sends the app's download link to a visitor by SMS or email.
///
/// The page only knows this interface. The in-memory implementation below
/// pretends to send; to go live, implement it against your backend (see the
/// docs for a Twilio and an email example) and pass it to
/// `AppLandingApp(linkService: ...)`.
abstract interface class DownloadLinkService {
  /// Sends the link to [contact].
  ///
  /// Throws a [DownloadLinkException] with a message for the visitor when the
  /// message cannot be sent.
  Future<void> send(Contact contact);
}

/// A stand-in for a real service.
///
/// It waits [latency], then accepts any contact, except addresses ending in
/// `@fail.example` and numbers ending in `0000`, which are refused so the
/// error state can be tried out.
class InMemoryDownloadLinkService implements DownloadLinkService {
  /// Creates the service.
  InMemoryDownloadLinkService({
    this.latency = const Duration(milliseconds: 700),
  });

  /// How long a send takes.
  final Duration latency;

  /// Every contact this instance accepted, oldest first.
  final List<Contact> sent = <Contact>[];

  @override
  Future<void> send(Contact contact) async {
    await Future<void>.delayed(latency);
    final String v = contact.value.toLowerCase();
    if (v.endsWith('@fail.example') || v.endsWith('0000')) {
      throw const DownloadLinkException(
        'We could not send the link right now. Please try again in a moment.',
      );
    }
    sent.add(contact);
  }
}
