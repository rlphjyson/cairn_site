import '../../../common/constants/chat_limits.dart';
import '../models/conversation.dart';
import '../repositories/conversation_repository.dart';

/// Why a group cannot be created yet.
enum GroupProblem {
  /// The name is empty.
  nameRequired('Give the group a name.'),

  /// The name is longer than [ChatLimits.groupNameMaxLength].
  nameTooLong('That name is too long.'),

  /// Fewer than [ChatLimits.groupMinMembers] people are selected.
  tooFewMembers('Choose at least two people.');

  const GroupProblem(this.message);

  /// Text for the person.
  final String message;
}

/// Thrown by [CreateGroup] when asked to create an invalid group.
class InvalidGroupException implements Exception {
  /// Creates the exception.
  const InvalidGroupException(this.problem);

  /// What is wrong.
  final GroupProblem problem;

  @override
  String toString() => 'InvalidGroupException(${problem.name})';
}

/// Creates a group conversation.
class CreateGroup {
  /// Creates the use case.
  const CreateGroup(this._conversations);

  final ConversationRepository _conversations;

  /// What is wrong with [name] and [memberIds], or `null` when the group can
  /// be created. Duplicate members count once.
  static GroupProblem? validate(String name, Iterable<String> memberIds) {
    final String trimmed = name.trim();
    if (trimmed.isEmpty) return GroupProblem.nameRequired;
    if (trimmed.length > ChatLimits.groupNameMaxLength) {
      return GroupProblem.nameTooLong;
    }
    if (memberIds.toSet().length < ChatLimits.groupMinMembers) {
      return GroupProblem.tooFewMembers;
    }
    return null;
  }

  /// Creates the group, or throws an [InvalidGroupException].
  Future<Conversation> call(String name, Iterable<String> memberIds) {
    final GroupProblem? problem = validate(name, memberIds);
    if (problem != null) throw InvalidGroupException(problem);
    return _conversations.createGroup(name.trim(), memberIds.toSet().toList());
  }
}
