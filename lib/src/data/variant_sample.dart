import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

/// One individually addressable instance inside a component's preview.
///
/// The whole point of this type is that a rendered thing and the code that
/// produced it travel together. A visitor looking at the small destructive
/// button should be able to click it and get *that* snippet — not a generic
/// multi-example block they have to read and edit down themselves.
///
/// [code] is therefore held to a strict standard: it must be a complete,
/// syntactically valid, copy-pasteable Dart expression (or a short statement
/// sequence, where the component genuinely needs surrounding state) that
/// reproduces exactly the instance in [child], using the real `cairn_ui`
/// public API with the same parameter values.
@immutable
class VariantSample {
  /// Creates a sample.
  const VariantSample({
    required this.label,
    required this.code,
    required this.child,
  });

  /// A short human name for this instance, e.g. `Destructive`, `Size · sm`.
  ///
  /// Shown next to the code so it is never ambiguous which instance the
  /// snippet belongs to. Unique within its component.
  final String label;

  /// A standalone snippet that reproduces exactly [child].
  final String code;

  /// The live widget.
  final Widget child;
}

/// How one run of variants is arranged.
enum VariantLayout {
  /// A [Wrap] — the default, and what most catalogue previews already use.
  wrap,

  /// A [Column].
  column,

  /// A [Row] sized to its children.
  row,
}

/// A run of variants laid out together.
///
/// A group exists so a preview can keep the arrangement it already had. Button
/// renders its six variants on one line, then its icon/loading/disabled forms
/// on the next, then its sizes on a third — three groups, not one flat list.
@immutable
class VariantGroup {
  /// Creates a group.
  const VariantGroup(
    this.samples, {
    this.layout = VariantLayout.wrap,
    this.spacing = CairnSpacing.s2,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  /// The instances in this run.
  final List<VariantSample> samples;

  /// How they are arranged.
  final VariantLayout layout;

  /// The gap between rendered instances.
  ///
  /// This is the gap between the *widgets*, not between their clickable hit
  /// areas — the interactive renderer subtracts its own inset so that turning
  /// the selection affordance on does not silently loosen every layout.
  final double spacing;

  /// Cross-axis alignment, for [VariantLayout.column] and [VariantLayout.row].
  final CrossAxisAlignment crossAxisAlignment;
}

/// Everything a component's preview renders, as addressable instances.
@immutable
class VariantSet {
  /// Creates a set from explicit groups.
  const VariantSet(
    this.groups, {
    this.width,
    this.groupSpacing = CairnSpacing.s4,
  });

  /// Creates a set with a single group.
  factory VariantSet.one(
    List<VariantSample> samples, {
    VariantLayout layout = VariantLayout.wrap,
    double spacing = CairnSpacing.s2,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    double? width,
  }) {
    return VariantSet(<VariantGroup>[
      VariantGroup(
        samples,
        layout: layout,
        spacing: spacing,
        crossAxisAlignment: crossAxisAlignment,
      ),
    ], width: width);
  }

  /// The runs, top to bottom.
  final List<VariantGroup> groups;

  /// An optional fixed width for the whole set.
  ///
  /// Previews must size themselves — the surfaces that host them hand them
  /// unbounded width — so anything that would otherwise stretch declares its
  /// width here rather than wrapping itself in a `SizedBox`.
  final double? width;

  /// The gap between groups.
  final double groupSpacing;

  /// Every sample, flattened in render order.
  ///
  /// This is the index space selection uses: sample `n` is the `n`th instance
  /// reading top-to-bottom, left-to-right.
  List<VariantSample> get samples => <VariantSample>[
    for (final VariantGroup group in groups) ...group.samples,
  ];
}

/// Builds a component's variants against the ambient theme.
///
/// A plain function rather than a widget so that the catalogue can stay `const`
/// — every entry's `preview` field is a static tear-off.
typedef VariantsBuilder = VariantSet Function(BuildContext context);
