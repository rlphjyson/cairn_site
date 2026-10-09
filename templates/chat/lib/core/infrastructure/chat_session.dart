/// A source of the current time. Tests pass a fixed one.
typedef NowProvider = DateTime Function();

/// Who is signed in, and what time it is.
///
/// Registered once per mounted app and read by cubits and (through
/// `ChatSessionScope`) by views, so "now" is the same everywhere and tests can
/// pin it.
class ChatSession {
  /// Creates a session.
  const ChatSession({required this.userId, required this.now});

  /// The signed-in user's id.
  final String userId;

  /// The clock.
  final NowProvider now;
}
