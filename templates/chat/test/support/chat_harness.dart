import 'package:cairn_template_chat/cairn_template_chat.dart';
import 'package:cairn_template_chat/presentation/shell/chat_shell.dart';
import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// Widths the template is tested at: a small phone, the site's phone frame, a
/// large phone and the smallest tablet layout (two panes).
const List<double> testWidths = <double>[320, 360, 390, 700];

/// The clock every test uses: a Friday at noon.
final DateTime testNow = DateTime(2026, 10, 9, 12);

DateTime fixedNow() => testNow;

/// Mounts [ChatApp] in a `MaterialApp` themed by Cairn, in a viewport of
/// [width] by [height] logical pixels, with the demo bot answering at once.
Future<void> mountChat(
  WidgetTester tester, {
  double width = 360,
  double height = 780,
  Duration replyLatency = Duration.zero,
  CairnTheme theme = CairnTheme.light,
  ChatRemoteDataSource? dataSource,
  void Function(Message message)? onMessageSent,
}) async {
  // The clipboard has no platform behind it in tests.
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (MethodCall call) async => call.method == 'Clipboard.getData'
        ? <String, Object?>{'text': ''}
        : null,
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: CairnTheme.materialTheme(theme.copyWith(fontFamily: 'Geist')),
      home: Scaffold(
        body: ChatApp(
          chatDataSource: dataSource,
          replyLatency: replyLatency,
          now: fixedNow,
          onMessageSent: onMessageSent,
        ),
      ),
    ),
  );
  await pumpFrames(tester);
}

/// Pumps [frames] short frames. Never `pumpAndSettle`: Cairn has repeating
/// animations (spinner, skeleton, typing dots) that never settle.
Future<void> pumpFrames(WidgetTester tester, [int frames = 6]) async {
  for (int i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Reads a session cubit from the mounted app.
T read<T extends StateStreamableSource<Object?>>(WidgetTester tester) =>
    tester.element(find.byType(ChatShell)).read<T>();

/// Taps the first widget showing [text].
Future<void> tapText(WidgetTester tester, String text) async {
  await tester.tap(find.text(text).first);
  await pumpFrames(tester);
}

/// Taps the widget with accessibility label [label].
Future<void> tapLabel(WidgetTester tester, String label) async {
  await tester.tap(find.bySemanticsLabel(label).first);
  await pumpFrames(tester);
}

/// The first text field on screen whose placeholder or label is [label].
Finder fieldLabelled(String label) => find.descendant(
  of: find.bySemanticsLabel(label),
  matching: find.byType(EditableText),
);
