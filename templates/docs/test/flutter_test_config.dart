import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the Geist faces before any test runs, when they can be found.
///
/// `flutter test` registers no real font, so every glyph is an identical box.
/// That is fine for "does this widget exist" and misleading for layout: a row
/// that fits with real metrics can overflow with placeholder ones. This looks
/// for the faces next to the site this template ships in (`../../fonts`) and
/// quietly does nothing when they are absent, so the tests also pass when the
/// package is used on its own.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final FontLoader loader = FontLoader('Geist');
  bool any = false;
  for (final String weight in <String>[
    'Regular',
    'Medium',
    'SemiBold',
    'Bold',
  ]) {
    final File file = File('../../fonts/Geist-$weight.ttf');
    if (!file.existsSync()) continue;
    any = true;
    loader.addFont(
      file.readAsBytes().then((Uint8List b) => ByteData.view(b.buffer)),
    );
  }
  if (any) await loader.load();
  return testMain();
}
