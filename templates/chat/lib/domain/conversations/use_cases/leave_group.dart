import '../repositories/conversation_repository.dart';

/// Leaves a group conversation.
class LeaveGroup {
  /// Creates the use case.
  const LeaveGroup(this._conversations);

  final ConversationRepository _conversations;

  /// Leaves [id].
  Future<void> call(String id) => _conversations.leaveGroup(id);
}
