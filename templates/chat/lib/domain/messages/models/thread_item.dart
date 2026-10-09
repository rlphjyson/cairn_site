import 'package:equatable/equatable.dart';

import 'message.dart';

/// One row of a thread: a date separator or a message.
sealed class ThreadItem extends Equatable {
  const ThreadItem();

  /// A key that stays the same for the same row between rebuilds.
  String get key;
}

/// "Today", "Yesterday", "Mon 7 Oct": the start of a new day.
class DateSeparator extends ThreadItem {
  /// Creates a separator for [day].
  const DateSeparator(this.day);

  /// Midnight at the start of the day.
  final DateTime day;

  @override
  String get key => 'day-${day.toIso8601String()}';

  @override
  List<Object?> get props => <Object?>[day];
}

/// A message, with where it sits in its run.
///
/// A *run* is a stretch of messages from one sender, on one day, each within
/// five minutes of the one before. The first shows the sender's name (in
/// groups), the last shows the avatar and the time; the ones between are
/// tucked together.
class ThreadMessage extends ThreadItem {
  /// Creates a message row.
  const ThreadMessage(
    this.message, {
    required this.startsRun,
    required this.endsRun,
  });

  /// The message.
  final Message message;

  /// It is the first of its run.
  final bool startsRun;

  /// It is the last of its run.
  final bool endsRun;

  @override
  String get key => 'msg-${message.id}';

  @override
  List<Object?> get props => <Object?>[message, startsRun, endsRun];
}
