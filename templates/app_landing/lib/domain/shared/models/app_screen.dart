import 'package:equatable/equatable.dart';

/// Which mock app screen to draw. Each kind has a widget in
/// `presentation/shared/screens/`.
enum ScreenKind {
  /// Today's checklist with a progress ring.
  today,

  /// A weekly bar chart and per-habit progress.
  progress,

  /// A month grid with the active days marked.
  calendar,

  /// Toggles and preferences.
  settings,

  /// A goal picker, the first screen after install.
  goals,
}

/// Everything one mock phone screen shows.
///
/// The screens are drawn live from Cairn widgets, so changing a value here
/// changes the phone. Fields a kind does not use are simply ignored.
class AppScreen extends Equatable {
  /// Creates a screen.
  const AppScreen({
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.headline,
    required this.caption,
    required this.items,
    required this.bars,
    required this.barLabels,
    required this.monthLabel,
    required this.daysInMonth,
    required this.startWeekday,
    required this.activeDays,
    required this.today,
    required this.tab,
    required this.dock,
    required this.badge,
    required this.footnote,
    required this.description,
  });

  /// Which widget draws it.
  final ScreenKind kind;

  /// The large title at the top of the screen.
  final String title;

  /// The line under the title.
  final String subtitle;

  /// The big number or phrase, such as `12 day streak`.
  final String headline;

  /// The small line under [headline].
  final String caption;

  /// The rows: habits, goals or settings.
  final List<ScreenItem> items;

  /// Bar heights from 0 to 1 (progress screen).
  final List<double> bars;

  /// One label per bar.
  final List<String> barLabels;

  /// The month shown on the calendar, such as `October 2026`.
  final String monthLabel;

  /// How many days the month has.
  final int daysInMonth;

  /// The weekday the month starts on, 1 for Monday to 7 for Sunday.
  final int startWeekday;

  /// The days with every habit done (calendar screen).
  final List<int> activeDays;

  /// The current day of the month, or 0 for none.
  final int today;

  /// The index of the highlighted tab in the bottom dock.
  final int tab;

  /// The four labels of the bottom dock, in order.
  final List<String> dock;

  /// A small badge on the screen, such as `Premium` (settings screen).
  final String badge;

  /// A line of small print at the foot of the screen (settings screen).
  final String footnote;

  /// What a screen reader announces for this mock screen.
  final String description;

  @override
  List<Object?> get props => <Object?>[
    kind,
    title,
    subtitle,
    headline,
    caption,
    items,
    bars,
    barLabels,
    monthLabel,
    daysInMonth,
    startWeekday,
    activeDays,
    today,
    tab,
    dock,
    badge,
    footnote,
    description,
  ];
}

/// One row on a mock screen.
class ScreenItem extends Equatable {
  /// Creates an item.
  const ScreenItem({
    required this.label,
    required this.detail,
    required this.icon,
    required this.value,
    required this.done,
    required this.on,
  });

  /// The row title.
  final String label;

  /// The row's second line or trailing text.
  final String detail;

  /// An icon name (see `AppLandingIcons`).
  final String icon;

  /// Progress from 0 to 1.
  final double value;

  /// Whether a habit is ticked, or a goal selected.
  final bool done;

  /// Whether a setting is switched on.
  final bool on;

  @override
  List<Object?> get props => <Object?>[label, detail, icon, value, done, on];
}
