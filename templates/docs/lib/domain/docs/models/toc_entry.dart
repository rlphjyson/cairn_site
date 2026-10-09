import 'package:equatable/equatable.dart';

/// A heading in the "On this page" rail.
class TocEntry extends Equatable {
  /// Creates an entry.
  const TocEntry({required this.id, required this.text, required this.level});

  /// The anchor id.
  final String id;

  /// The heading text.
  final String text;

  /// 2 or 3.
  final int level;

  @override
  List<Object?> get props => <Object?>[id, text, level];
}
