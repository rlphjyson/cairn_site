import 'package:equatable/equatable.dart';

/// One published version of the documentation.
class DocVersion extends Equatable {
  /// Creates a version.
  const DocVersion({
    required this.id,
    required this.label,
    this.isLatest = false,
    this.notice,
  });

  /// The stable id, such as `v2.0`. Used as the key for the content set.
  final String id;

  /// What the version selector shows.
  final String label;

  /// Whether this is the version new readers should be on.
  final bool isLatest;

  /// A banner shown above every page of an older version, or `null`.
  final String? notice;

  @override
  List<Object?> get props => <Object?>[id, label, isLatest, notice];
}
