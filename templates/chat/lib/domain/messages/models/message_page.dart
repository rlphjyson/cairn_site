import 'package:equatable/equatable.dart';

import 'message.dart';

/// One page of history.
class MessagePage extends Equatable {
  /// Creates a page.
  const MessagePage({required this.messages, required this.hasMore});

  /// The messages, oldest first.
  final List<Message> messages;

  /// Whether there is older history to load.
  final bool hasMore;

  @override
  List<Object?> get props => <Object?>[messages, hasMore];
}
