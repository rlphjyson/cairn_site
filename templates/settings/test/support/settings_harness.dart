import 'package:cairn_template_settings/cairn_template_settings.dart';
import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Widths the template is tested at: a small phone, the site's phone frame and
/// a tablet.
const List<double> testWidths = <double>[320, 360, 700];

/// Wraps the whole app, so a screenshot test can capture dialogs too.
final GlobalKey captureKey = GlobalKey();

/// Everything a test needs to see what the host would see.
class Host {
  /// Creates a host. [source] replaces the default zero-latency data source.
  Host({InMemorySettingsDataSource? source})
    : source = source ?? InMemorySettingsDataSource(latency: Duration.zero);

  /// Modes reported to `onThemeModeChanged`.
  final List<ThemeMode> modes = <ThemeMode>[];

  /// Ids and values reported to `onSettingChanged`.
  final List<(String, Object?)> changes = <(String, Object?)>[];

  /// Times `onSignOut` was called.
  int signedOut = 0;

  /// Times `onDeleteAccount` was called.
  int deleted = 0;

  /// Times `onDeactivateAccount` was called.
  int deactivated = 0;

  /// Links reported to `onLinkTap`.
  final List<SettingsLink> links = <SettingsLink>[];

  /// Ratings reported to `onRateApp`.
  final List<int> ratings = <int>[];

  /// Times the system settings were asked for.
  int systemSettingsOpened = 0;

  /// The data source, kept so tests can inspect it.
  final InMemorySettingsDataSource source;

  /// The widget under test, mounted in a `Scaffold`.
  Widget app({
    String? initialLocation,
    NotificationPermission permission = NotificationPermission.granted,
    Profile? profile,
    SettingsRegistry? registry,
  }) => SettingsApp(
    settingsDataSource: source,
    registry: registry,
    profile: profile,
    initialLocation: initialLocation,
    notificationPermission: permission,
    onThemeModeChanged: modes.add,
    onSettingChanged: (String id, Object? v) => changes.add((id, v)),
    onSignOut: () => signedOut++,
    onDeactivateAccount: () => deactivated++,
    onDeleteAccount: () => deleted++,
    onLinkTap: links.add,
    onOpenSystemSettings: () => systemSettingsOpened++,
    onRateApp: ratings.add,
  );
}

/// Mounts [SettingsApp] in a `MaterialApp` themed by Cairn, in a viewport of
/// [width] by [height] logical pixels.
///
/// Geist is loaded by `flutter_test_config.dart` when it can be found, so text
/// has real metrics. [dark] sets the platform brightness, which the template
/// follows while its theme is System.
Future<Host> mountSettings(
  WidgetTester tester, {
  double width = 360,
  double height = 780,
  bool dark = false,
  double textScale = 1,
  Host? host,
  String? initialLocation,
  NotificationPermission permission = NotificationPermission.granted,
  Profile? profile,
  SettingsRegistry? registry,
  bool settle = true,
}) async {
  final Host h = host ?? Host();
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.platformBrightnessTestValue = dark
      ? Brightness.dark
      : Brightness.light;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);
  // A new tree each time, so state from a previous mount never leaks in.
  await tester.pumpWidget(const SizedBox());
  await tester.pumpWidget(
    RepaintBoundary(
      key: captureKey,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: CairnTheme.materialTheme(
          CairnTheme.light.copyWith(fontFamily: 'Geist'),
        ),
        darkTheme: CairnTheme.materialTheme(
          CairnTheme.dark.copyWith(fontFamily: 'Geist'),
        ),
        builder: (BuildContext context, Widget? child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: Scaffold(
          body: h.app(
            initialLocation: initialLocation,
            permission: permission,
            profile: profile,
            registry: registry,
          ),
        ),
      ),
    ),
  );
  if (settle) await pumpFrames(tester);
  return h;
}

/// Pumps [frames] short frames. Never `pumpAndSettle`: Cairn has repeating
/// animations (skeletons, spinners) that never settle.
Future<void> pumpFrames(WidgetTester tester, [int frames = 6]) async {
  for (int i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Scrolls [finder] into view, taps it and pumps.
Future<void> tapOn(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder.first);
  await pumpFrames(tester, 2);
  await tester.tap(finder.first, warnIfMissed: false);
  await pumpFrames(tester);
}

/// The row (a Cairn list item or any widget) whose accessible name starts with
/// [label].
Finder row(String label) => find.byWidgetPredicate(
  (Widget w) =>
      w is Semantics &&
      (w.properties.label ?? '').startsWith(label) &&
      (w.properties.button == true || w.properties.toggled != null),
  description: 'row "$label"',
);

/// Taps the row [label].
Future<void> tapRow(WidgetTester tester, String label) =>
    tapOn(tester, row(label));

/// The Cairn button with [label].
Finder button(String label) => find.widgetWithText(CairnButton, label);

/// The Cairn button with the accessible name [label].
Finder buttonNamed(String label) => find.byWidgetPredicate(
  (Widget w) => w is CairnButton && w.semanticLabel == label,
);

/// Taps the button labelled [label].
Future<void> tapButton(WidgetTester tester, String label) =>
    tapOn(tester, button(label));

/// The Cairn input or textarea with the accessible name [label].
Finder input(String label) => find.byWidgetPredicate(
  (Widget w) =>
      (w is CairnInput && w.semanticLabel == label) ||
      (w is CairnTextarea && w.semanticLabel == label),
);

/// Types [text] into the input named [label].
Future<void> typeInto(WidgetTester tester, String label, String text) async {
  final Finder field = find.descendant(
    of: input(label),
    matching: find.byType(TextField),
  );
  await tester.ensureVisible(field.first);
  await pumpFrames(tester, 2);
  await tester.enterText(field.first, text);
  await pumpFrames(tester, 2);
}

/// Opens [page] from the home list by tapping its row.
Future<void> openSection(WidgetTester tester, String title) =>
    tapRow(tester, title);
