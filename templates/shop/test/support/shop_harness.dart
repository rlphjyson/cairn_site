import 'package:cairn_template_shop/cairn_template_shop.dart';
import 'package:cairn_template_shop/core/presentation/navigation/shop_navigation_cubit.dart';
import 'package:cairn_template_shop/core/presentation/widgets/labeled_field.dart';
import 'package:cairn_template_shop/presentation/shell/shop_shell.dart';
import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// Widths the template is tested at: a small phone, the site's phone frame and
/// a tablet.
const List<double> testWidths = <double>[320, 360, 700];

/// Mounts [ShopApp] in a `MaterialApp` themed by Cairn, in a viewport of
/// [width] by [height] logical pixels.
///
/// Flutter's test font draws every glyph as a full em square, far wider than
/// Geist, so text is scaled down to keep line lengths close to real ones;
/// otherwise a 320px phone would overflow in tests only.
Future<void> mountShop(
  WidgetTester tester, {
  double width = 360,
  double height = 780,
  Duration latency = Duration.zero,
  CairnTheme theme = CairnTheme.light,
}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: CairnTheme.materialTheme(theme),
      builder: (BuildContext context, Widget? child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: const TextScaler.linear(0.6)),
        child: child!,
      ),
      home: Scaffold(body: ShopApp(catalogLatency: latency)),
    ),
  );
  await pumpFrames(tester);
}

/// Pumps [frames] short frames. Never `pumpAndSettle`: Cairn has repeating
/// animations (spinner, skeleton, progress) that never settle.
Future<void> pumpFrames(WidgetTester tester, [int frames = 6]) async {
  for (int i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Reads a session cubit from the mounted shop.
T read<T extends StateStreamableSource<Object?>>(WidgetTester tester) =>
    tester.element(find.byType(ShopShell)).read<T>();

/// The nearest vertical scrollable of the current screen.
Finder verticalScrollable() => find
    .byWidgetPredicate(
      (Widget w) => w is Scrollable && w.axisDirection == AxisDirection.down,
    )
    .first;

/// Scrolls [finder] into view in the current screen, then pumps.
Future<void> reveal(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: verticalScrollable(),
    maxScrolls: 80,
  );
  await pumpFrames(tester, 2);
}

/// Scrolls to [finder], taps it and pumps.
Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await reveal(tester, finder);
  await tester.tap(finder.first);
  await pumpFrames(tester);
}

/// Taps the first widget showing [text].
Future<void> tapText(WidgetTester tester, String text) =>
    tapVisible(tester, find.text(text));

/// Taps a bottom-dock tab.
Future<void> tapDock(WidgetTester tester, String label) async {
  await tester.tap(
    find
        .descendant(of: find.byType(CairnDock), matching: find.text(label))
        .first,
  );
  await pumpFrames(tester);
}

/// The text field inside the [LabeledField] titled [label].
Finder field(String label) => find.descendant(
  of: find.widgetWithText(LabeledField, label),
  matching: find.byType(EditableText),
);

/// Types [text] into the [LabeledField] titled [label].
Future<void> fill(WidgetTester tester, String label, String text) async {
  await reveal(tester, field(label));
  await tester.enterText(field(label), text);
  await pumpFrames(tester, 2);
}

/// Opens a tab by its dock label and waits for the page change to finish.
Future<void> goToTab(WidgetTester tester, ShopTab tab) async {
  read<ShopNavigationCubit>(tester).selectTab(tab);
  await pumpFrames(tester);
}
