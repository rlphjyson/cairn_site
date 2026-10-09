import 'package:equatable/equatable.dart';

/// One choice a shopper makes before buying, e.g. `Size` with its values.
class VariantGroup extends Equatable {
  /// Creates a group.
  const VariantGroup({required this.label, required this.values});

  /// What the group chooses, e.g. `Size`.
  final String label;

  /// The selectable values. Never empty.
  final List<String> values;

  @override
  List<Object?> get props => <Object?>[label, values];
}
