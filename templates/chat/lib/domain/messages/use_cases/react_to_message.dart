import '../models/message.dart';
import '../models/reaction.dart';
import '../repositories/message_repository.dart';

/// Adds or removes your emoji reaction on a message.
class ReactToMessage {
  /// Creates the use case.
  const ReactToMessage(this._messages);

  final MessageRepository _messages;

  /// The message as it would be after [userId] toggles [emoji]: the emoji is
  /// added, or removed when [userId] already used it. An emoji nobody uses any
  /// more disappears.
  ///
  /// Pure, so a screen can apply it at once and let [call] confirm it.
  static Message apply(Message message, String emoji, String userId) {
    final List<Reaction> next = <Reaction>[];
    bool found = false;
    for (final Reaction r in message.reactions) {
      if (r.emoji != emoji) {
        next.add(r);
        continue;
      }
      found = true;
      final List<String> users = r.includes(userId)
          ? r.userIds.where((String id) => id != userId).toList()
          : <String>[...r.userIds, userId];
      if (users.isNotEmpty) next.add(Reaction(emoji, users));
    }
    if (!found) next.add(Reaction(emoji, <String>[userId]));
    return message.copyWith(reactions: next);
  }

  /// Persists the toggle and returns the stored message.
  Future<Message> call(String conversationId, String messageId, String emoji) =>
      _messages.toggleReaction(conversationId, messageId, emoji);
}
