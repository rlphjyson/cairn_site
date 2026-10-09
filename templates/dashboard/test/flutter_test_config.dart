import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the Geist faces before any test runs, when they can be found.
///
/// `flutter test` otherwise lays text out with a placeholder font in which every
/// glyph is a wide box, which reports overflows that real text never has.
/// Cairn UI's own goldens are pinned to Geist, so this matches production
/// metrics. The font is not bundled with the template: it is looked up in the
/// Cairn site checkout this package lives in, and skipped when absent.
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
