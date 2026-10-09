import '../../../common/constants/chat_limits.dart';
import '../../../common/utils/dates.dart';
import '../models/message.dart';
import '../models/thread_item.dart';

/// Turns a flat list of messages into thread rows: runs of messages by one
/// sender, with a separator whenever the day changes.
class GroupMessages {
  /// Creates the use case.
  const GroupMessages({this.window = ChatLimits.runWindow});

  /// How close two messages must be to share a run.
  final Duration window;

  /// [messages] must be oldest first.
  ///
  /// A message continues the previous run when it has the same sender, is on
  /// the same calendar day, and was sent within [window] of the previous
  /// message.
  List<ThreadItem> call(List<Message> messages) {
    final List<ThreadItem> items = <ThreadItem>[];
    for (int i = 0; i < messages.length; i++) {
      final Message message = messages[i];
      final Message? previous = i > 0 ? messages[i - 1] : null;
      final Message? next = i < messages.length - 1 ? messages[i + 1] : null;
      if (previous == null || !isSameDay(previous.sentAt, message.sentAt)) {
        items.add(DateSeparator(startOfDay(message.sentAt)));
      }
      items.add(
        ThreadMessage(
          message,
          startsRun: previous == null || !_continues(previous, message),
          endsRun: next == null || !_continues(message, next),
        ),
      );
    }
    return items;
  }

  bool _continues(Message earlier, Message later) =>
      earlier.senderId == later.senderId &&
      isSameDay(earlier.sentAt, later.sentAt) &&
      later.sentAt.difference(earlier.sentAt) <= window;
}
