import 'package:equatable/equatable.dart';

/// A square grid of dark and light modules that looks like a QR code.
///
/// It is **not** a real QR code and will not scan: it has the three finder
/// squares, a timing line and an alignment mark, and the rest is filled from a
/// seed. Replace it with a real code before launch (see the docs).
class QrPattern extends Equatable {
  /// Creates a pattern from a row-major list of [modules].
  const QrPattern(this.size, this.modules);

  /// The number of modules along each side.
  final int size;

  /// `size * size` modules, row by row; `true` is dark.
  final List<bool> modules;

  /// Whether the module at column [x], row [y] is dark.
  bool isDark(int x, int y) => modules[y * size + x];

  @override
  List<Object?> get props => <Object?>[size, modules];
}
