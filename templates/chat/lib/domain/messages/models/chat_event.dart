import 'package:equatable/equatable.dart';

import '../../contacts/models/contact.dart';
import 'message.dart';

/// Something that happened on the server while the app was open.
///
/// A real backend delivers these over a WebSocket or server-sent events; the
/// data source decodes each frame to JSON and the repository maps it here.
sealed class ChatEvent extends Equatable {
  const ChatEvent();
}

/// Someone else sent a message.
class MessageArrived extends ChatEvent {
  /// Creates the event.
  const MessageArrived(this.message);

  /// The new message.
  final Message message;

  @override
  List<Object?> get props => <Object?>[message];
}

/// A message changed: it was read, or someone reacted.
class MessageUpdated extends ChatEvent {
  /// Creates the event.
  const MessageUpdated(this.message);

  /// The message as it is now.
  final Message message;

  @override
  List<Object?> get props => <Object?>[message];
}

/// A message was removed.
class MessageRemoved extends ChatEvent {
  /// Creates the event.
  const MessageRemoved(this.conversationId, this.messageId);

  /// The conversation it was in.
  final String conversationId;

  /// The message.
  final String messageId;

  @override
  List<Object?> get props => <Object?>[conversationId, messageId];
}

/// Someone started or stopped typing.
class TypingChanged extends ChatEvent {
  /// Creates the event.
  const TypingChanged(this.conversationId, this.userId, {required this.typing});

  /// Where they are typing.
  final String conversationId;

  /// Who.
  final String userId;

  /// Whether they are typing now.
  final bool typing;

  @override
  List<Object?> get props => <Object?>[conversationId, userId, typing];
}

/// A contact's presence changed.
class PresenceChanged extends ChatEvent {
  /// Creates the event.
  const PresenceChanged(this.contact);

  /// The contact as they are now.
  final Contact contact;

  @override
  List<Object?> get props => <Object?>[contact];
}

/// A conversation's list entry changed (new last message, unread count, pin,
/// mute, archive...). The list should reload.
class ConversationChanged extends ChatEvent {
  /// Creates the event.
  const ConversationChanged(this.conversationId);

  /// Which conversation.
  final String conversationId;

  @override
  List<Object?> get props => <Object?>[conversationId];
}
