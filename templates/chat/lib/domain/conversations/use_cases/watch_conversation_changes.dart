import '../repositories/conversation_repository.dart';

/// The ids of conversations whose list entry just changed.
class WatchConversationChanges {
  /// Creates the use case.
  const WatchConversationChanges(this._conversations);

  final ConversationRepository _conversations;

  /// Subscribes.
  Stream<String> call() => _conversations.watchChanges();
}
