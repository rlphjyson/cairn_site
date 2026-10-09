/// Numbers that shape the chat's behaviour, in one place.
abstract final class ChatLimits {
  /// How many messages one page of history holds.
  static const int pageSize = 30;

  /// Messages from the same sender closer together than this share one run:
  /// one avatar, one name, one timestamp.
  static const Duration runWindow = Duration(minutes: 5);

  /// The composer grows to this many lines, then scrolls.
  static const int composerMaxLines = 5;

  /// The longest group name.
  static const int groupNameMaxLength = 40;

  /// A group needs at least this many people besides you.
  static const int groupMinMembers = 2;

  /// How far from the newest message (in logical pixels) the thread has to be
  /// scrolled before the "scroll to latest" button appears.
  static const double scrollButtonDistance = 160;

  /// Wide enough for two panes: the list on the left, the thread on the right.
  static const double twoPaneBreakpoint = 700;

  /// The width of the list pane in the two-pane layout.
  static const double listPaneWidth = 320;
}
