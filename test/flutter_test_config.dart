import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the bundled Geist faces before any test runs.
///
/// `flutter test` registers no real font by default: text lays out with a
/// placeholder where every glyph is an identical box of a fixed width. That is
/// fine for "does this widget exist" assertions and actively misleading for
/// anything about layout — a row that fits with real metrics can overflow with
/// placeholder ones, and the failure is noise rather than signal.
///
/// The library does the same thing for its golden tests, for the stronger
/// reason that the reference images have to be reproducible. Here it is just
/// about making layout assertions mean something.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await _loadGeist();
  return testMain();
}

Future<void> _loadGeist() async {
  final FontLoader loader = FontLoader('Geist');
  for (final String weight in <String>[
    'Regular',
    'Medium',
    'SemiBold',
    'Bold',
  ]) {
    final File file = File('fonts/Geist-$weight.ttf');
    if (!file.existsSync()) continue;
    loader.addFont(
      file.readAsBytes().then((Uint8List bytes) => ByteData.view(bytes.buffer)),
    );
  }
  await loader.load();
}
