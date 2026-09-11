import 'package:cairn_site/src/data/components_catalog.dart';
import 'package:cairn_site/src/data/variant_sample.dart';
import 'package:cairn_site/src/widgets/clickable_variant.dart';
import 'package:cairn_site/src/widgets/code_block.dart';
import 'package:cairn_site/src/widgets/preview_pane.dart';
import 'package:cairn_site/src/widgets/variant_preview_pane.dart';
import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'site_harness.dart';

/// Click-to-reveal is the one feature on this site with a real interaction
/// contract: a visitor points at one rendered instance and gets *that*
/// instance's code, never a generic block. These tests hold both halves of it —
/// the data (every catalogue entry really does carry addressable variants) and
/// the behaviour (tapping one really does change which snippet is showing).
void main() {
  group('every catalogue entry carries real variants', () {
    testWidgets('non-empty, distinct labels and non-empty snippets', (
      WidgetTester tester,
    ) async {
      final BuildContext context = await _aContext(tester);

      for (final ComponentEntry entry in componentCatalog) {
        final List<VariantSample> samples = entry.preview(context).samples;

        expect(
          samples,
          isNotEmpty,
          reason: '${entry.name} has no variants at all',
        );

        final Set<String> labels = <String>{};
        for (final VariantSample sample in samples) {
          expect(
            sample.label.trim(),
            isNotEmpty,
            reason: '${entry.name} has an unlabelled variant',
          );
          expect(
            labels.add(sample.label),
            isTrue,
            reason: '${entry.name} repeats the label "${sample.label}"',
          );
          expect(
            sample.code.trim(),
            isNotEmpty,
            reason: '${entry.name} · ${sample.label} has no code',
          );
          expect(
            sample.code,
            contains('Cairn'),
            reason:
                '${entry.name} · ${sample.label} should show a real Cairn '
                'widget',
          );
        }
      }
    });

    testWidgets('every snippet has balanced brackets', (
      WidgetTester tester,
    ) async {
      // Cheap proxy for "this actually parses". It will not catch a wrong
      // parameter name, but it does catch the failure mode that matters when
      // fifty snippets are hand-written: a trailing paren lost to an edit.
      final BuildContext context = await _aContext(tester);

      for (final ComponentEntry entry in componentCatalog) {
        for (final VariantSample sample in entry.preview(context).samples) {
          for (final List<String> pair in const <List<String>>[
            <String>['(', ')'],
            <String>['[', ']'],
            <String>['{', '}'],
          ]) {
            final int open = pair.first.allMatches(sample.code).length;
            final int close = pair.last.allMatches(sample.code).length;
            expect(
              open,
              close,
              reason:
                  '${entry.name} · ${sample.label}: ${open - close} unmatched '
                  '"${pair.first}"',
            );
          }
        }
      }
    });

    testWidgets('the catalogue has more variants than components', (
      WidgetTester tester,
    ) async {
      // A guard against the whole feature silently collapsing back to
      // one-snippet-per-component.
      final BuildContext context = await _aContext(tester);
      final int total = componentCatalog.fold<int>(
        0,
        (int sum, ComponentEntry e) => sum + e.preview(context).samples.length,
      );
      expect(total, greaterThan(componentCatalog.length));
    });
  });

  group('clicking a variant reveals that variant\'s code', () {
    testWidgets('button: tapping Secondary shows the secondary snippet', (
      WidgetTester tester,
    ) async {
      await pumpSite(tester, '/components/button');

      // Nothing is revealed until something is clicked.
      expect(find.byType(SelectedVariantCode), findsNothing);

      await _tapVariant(
        tester,
        find.widgetWithText(ClickableVariant, 'Secondary'),
      );

      expect(_selectedLabel(tester), 'Secondary');
      _expectCodeShowing(tester, 'CairnButtonVariant.secondary');
      // ...and specifically *not* the whole six-variant block the pane used to
      // show regardless of what you were looking at.
      _expectCodeNotShowing(tester, 'CairnButtonVariant.ghost');
    });

    testWidgets('button: tapping Destructive replaces the shown snippet', (
      WidgetTester tester,
    ) async {
      await pumpSite(tester, '/components/button');

      await _tapVariant(
        tester,
        find.widgetWithText(ClickableVariant, 'Secondary'),
      );
      _expectCodeShowing(tester, 'CairnButtonVariant.secondary');

      await _tapVariant(
        tester,
        find.widgetWithText(ClickableVariant, 'Destructive'),
      );

      expect(_selectedLabel(tester), 'Destructive');
      _expectCodeShowing(tester, 'CairnButtonVariant.destructive');
      _expectCodeNotShowing(tester, 'CairnButtonVariant.secondary');
    });

    testWidgets('input: tapping the disabled field shows enabled: false', (
      WidgetTester tester,
    ) async {
      await pumpSite(tester, '/components/input');

      // Column order: default, error, disabled.
      await _tapVariant(tester, find.byType(ClickableVariant).at(2));

      expect(_selectedLabel(tester), 'Disabled');
      _expectCodeShowing(tester, 'enabled: false');
      _expectCodeNotShowing(tester, 'hasError: true');
    });

    testWidgets('badge: tapping the icon badge shows its leading slot', (
      WidgetTester tester,
    ) async {
      await pumpSite(tester, '/components/badge');

      await _tapVariant(
        tester,
        find.widgetWithText(ClickableVariant, 'Verified'),
      );

      expect(_selectedLabel(tester), 'With icon');
      _expectCodeShowing(tester, 'CairnIconData.check');
    });

    testWidgets('alert: tapping the destructive banner shows its variant', (
      WidgetTester tester,
    ) async {
      await pumpSite(tester, '/components/alert');

      await _tapVariant(
        tester,
        find.widgetWithText(ClickableVariant, 'Payment failed'),
      );

      expect(_selectedLabel(tester), 'Destructive');
      _expectCodeShowing(tester, 'CairnAlertVariant.destructive');
    });
  });

  group('the Code tab', () {
    testWidgets('defaults to the first variant rather than being empty', (
      WidgetTester tester,
    ) async {
      await pumpSite(tester, '/components/button');

      await _openCodeTab(tester);

      expect(_selectedLabel(tester), 'Primary');
      _expectCodeShowing(tester, "child: const Text('Primary')");
    });

    testWidgets('follows the selection made on the Preview tab', (
      WidgetTester tester,
    ) async {
      await pumpSite(tester, '/components/tabs');

      await _tapVariant(
        tester,
        find.widgetWithText(ClickableVariant, 'Overview'),
      );
      expect(_selectedLabel(tester), 'Line');

      await _openCodeTab(tester);

      expect(_selectedLabel(tester), 'Line');
      _expectCodeShowing(tester, "CairnTab<String>(value: 'reports'");
    });
  });

  group('the catalogue grid stays read-only', () {
    testWidgets('no variant is clickable on the overview page', (
      WidgetTester tester,
    ) async {
      await pumpSite(tester, '/components');
      expect(find.byType(VariantSetView), findsWidgets);
      expect(find.byType(ClickableVariant), findsNothing);
    });
  });
}

/// Mounts an empty app and hands back a usable [BuildContext].
///
/// Preview builders only *construct* widgets, so any live context will do.
Future<BuildContext> _aContext(WidgetTester tester) async {
  late BuildContext captured;
  await tester.pumpWidget(
    MaterialApp(
      theme: CairnTheme.materialTheme(CairnTheme.dark),
      home: Builder(
        builder: (BuildContext context) {
          captured = context;
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  return captured;
}

Future<void> _openCodeTab(WidgetTester tester) async {
  await tester.tap(
    find.descendant(of: find.byType(PreviewTabs), matching: find.text('Code')),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _tapVariant(WidgetTester tester, Finder finder) async {
  await tester.tap(finder.first, warnIfMissed: false);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

String _selectedLabel(WidgetTester tester) {
  final SelectedVariantCode block = tester.widget<SelectedVariantCode>(
    find.byType(SelectedVariantCode).first,
  );
  return block.sample.label;
}

/// Only code blocks *inside the pane* count — the page also carries a folded
/// "Quick start" block, which is exactly the generic snippet this feature
/// exists to stop standing in for per-instance code.
Finder _paneCode(String needle) => find.descendant(
  of: find.byType(VariantPreviewPane),
  matching: find.byWidgetPredicate(
    (Widget w) => w is CodeBlock && w.code.contains(needle),
  ),
);

void _expectCodeShowing(WidgetTester tester, String needle) {
  expect(
    _paneCode(needle),
    findsWidgets,
    reason: 'no rendered CodeBlock in the pane contains "$needle"',
  );
}

void _expectCodeNotShowing(WidgetTester tester, String needle) {
  expect(
    _paneCode(needle),
    findsNothing,
    reason: 'a rendered CodeBlock in the pane still contains "$needle"',
  );
}
