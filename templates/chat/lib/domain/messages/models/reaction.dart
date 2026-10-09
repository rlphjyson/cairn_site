import 'package:equatable/equatable.dart';

/// One emoji and the people who used it on a message.
class Reaction extends Equatable {
  /// Creates a reaction.
  const Reaction(this.emoji, this.userIds);

  /// The emoji.
  final String emoji;

  /// Who reacted with it.
  final List<String> userIds;

  /// How many people reacted.
  int get count => userIds.length;

  /// Whether [userId] is one of them.
  bool includes(String userId) => userIds.contains(userId);

  @override
  List<Object?> get props => <Object?>[emoji, userIds];
}
