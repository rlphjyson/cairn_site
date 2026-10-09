import '../models/attachment.dart';
import '../models/message.dart';
import '../repositories/message_repository.dart';

/// The photos shared in a conversation.
class GetSharedMedia {
  /// Creates the use case.
  const GetSharedMedia(this._messages);

  final MessageRepository _messages;

  /// Messages carrying a photo, newest first.
  Future<List<Message>> call(String conversationId) async {
    final List<Message> media = await _messages.getMedia(conversationId);
    return media
        .where((Message m) => m.attachment?.kind == AttachmentKind.image)
        .toList()
      ..sort((Message a, Message b) => b.sentAt.compareTo(a.sentAt));
  }
}
