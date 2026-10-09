import 'package:equatable/equatable.dart';

import 'attachment.dart';
import 'reply_preview.dart';

/// What the composer hands to the repository.
class OutgoingMessage extends Equatable {
  /// Creates an outgoing message.
  const OutgoingMessage({
    required this.conversationId,
    this.text = '',
    this.replyTo,
    this.attachment,
  });

  /// Where it goes.
  final String conversationId;

  /// The body, or the caption of [attachment].
  final String text;

  /// The message being answered.
  final ReplyPreview? replyTo;

  /// A photo, file or location.
  final Attachment? attachment;

  @override
  List<Object?> get props => <Object?>[
    conversationId,
    text,
    replyTo,
    attachment,
  ];
}
