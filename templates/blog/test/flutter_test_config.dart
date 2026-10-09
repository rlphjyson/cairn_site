import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the Geist faces (when the repository's `fonts/` folder is two levels
/// up) and Material's icon font before any test runs.
///
/// `flutter test` registers no real font by default: text lays out with a
/// placeholder where every glyph is the same box, which makes layout
/// assertions meaningless. Without the files this silently does nothing and
/// the tests still pass, with the placeholder metrics.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await _loadGeist();
  return testMain();
}

Future<void> _loadGeist() async {
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
      file.readAsBytes().then((Uint8List bytes) => ByteData.view(bytes.buffer)),
    );
  }
  if (any) await loader.load();
}
