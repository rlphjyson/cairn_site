import '../../../common/utils/json.dart';
import '../models/app_screen.dart';

/// Maps one mock screen.
AppScreen mapScreen(JsonMap json) => AppScreen(
  kind: _kind(json.string('kind')),
  title: json.string('title'),
  subtitle: json.maybeString('subtitle') ?? '',
  headline: json.maybeString('headline') ?? '',
  caption: json.maybeString('caption') ?? '',
  items: <ScreenItem>[
    for (final JsonMap e in json.maybeObjects('items'))
      ScreenItem(
        label: e.string('label'),
        detail: e.maybeString('detail') ?? '',
        icon: e.maybeString('icon') ?? 'task',
        value: (e.maybeNumber('value') ?? 0).clamp(0.0, 1.0),
        done: e.flag('done'),
        on: e.flag('on'),
      ),
  ],
  bars: <double>[
    for (final Object? v in (json['bars'] as List<Object?>? ?? <Object?>[]))
      (v! as num).toDouble().clamp(0.0, 1.0),
  ],
  barLabels: json.strings('barLabels'),
  monthLabel: json.maybeString('monthLabel') ?? '',
  daysInMonth: (json.maybeNumber('daysInMonth') ?? 30).round(),
  startWeekday: (json.maybeNumber('startWeekday') ?? 1).round().clamp(1, 7),
  activeDays: <int>[
    for (final Object? v
        in (json['activeDays'] as List<Object?>? ?? <Object?>[]))
      (v! as num).toInt(),
  ],
  today: (json.maybeNumber('today') ?? 0).round(),
  tab: (json.maybeNumber('tab') ?? 0).round().clamp(0, 3),
  dock: _dock(json.strings('dock')),
  badge: json.maybeString('badge') ?? '',
  footnote: json.maybeString('footnote') ?? '',
  description: json.string('description'),
);

const List<String> _defaultDock = <String>[
  'Today',
  'Progress',
  'Calendar',
  'Settings',
];

ScreenKind _kind(String name) {
  for (final ScreenKind k in ScreenKind.values) {
    if (k.name == name) return k;
  }
  throw FormatException('Unknown screen kind "$name"');
}

/// Always four labels: the ones given, topped up from the English defaults.
List<String> _dock(List<String> given) => <String>[
  for (int i = 0; i < _defaultDock.length; i++)
    i < given.length ? given[i] : _defaultDock[i],
];
