import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

import '../data/variant_sample.dart';
import 'clickable_variant.dart';
import 'code_block.dart';
import 'preview_pane.dart';

/// A live preview whose every rendered instance is clickable, and whose code
/// is always the code for the instance you clicked.
///
/// The interaction is deliberately *not* "click a widget, get bounced to the
/// Code tab". Bouncing costs the visitor the thing they were looking at: a
/// half-dragged Slider, an open Select, a Carousel mid-swipe. Instead the
/// snippet opens in place, directly under the preview surface, so one click on
/// a rendered widget reveals its exact code without the preview going away.
///
/// The Preview / Code toggle stays what it was — the Code tab is the same
/// selected snippet given the full width, and switching back to Preview leaves
/// the selection alone.
class VariantPreviewPane extends StatefulWidget {
  /// Creates a pane over [variants].
  const VariantPreviewPane({
    super.key,
    required this.variants,
    this.minHeight = 260.0,
    this.padding = const EdgeInsets.all(CairnSpacing.s8),
    this.codeMaxHeight = 420.0,
    this.minContentWidth = 640.0,
  });

  /// Builds the addressable instances.
  final VariantsBuilder variants;

  /// The minimum height of the preview surface.
  final double minHeight;

  /// Padding around the preview.
  final EdgeInsets padding;

  /// Caps the code block's height.
  final double codeMaxHeight;

  /// The narrowest the preview is ever laid out at.
  final double minContentWidth;

  @override
  State<VariantPreviewPane> createState() => _VariantPreviewPaneState();
}

class _VariantPreviewPaneState extends State<VariantPreviewPane> {
  PreviewTab _pane = PreviewTab.preview;
  int _selected = 0;

  /// Whether the visitor has clicked a variant yet.
  ///
  /// Selection defaults to the first variant so the Code tab is never empty,
  /// but the ring is held back until a real click. Painting a ring around, say,
  /// the first Button on arrival would read as *that button being focused* —
  /// the affordance would be indistinguishable from the component's own focus
  /// treatment, which is exactly the confusion this site should not create.
  bool _touched = false;

  void _select(int index) {
    if (_selected == index && _touched) return;
    setState(() {
      _selected = index;
      _touched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final VariantSet set = widget.variants(context);
    final List<VariantSample> samples = set.samples;
    assert(
      samples.isNotEmpty,
      'A component preview needs at least one variant',
    );

    final int selected = _selected < samples.length ? _selected : 0;
    final VariantSample sample = samples[selected];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            PreviewTabs(
              value: _pane,
              onChanged: (PreviewTab v) => setState(() => _pane = v),
            ),
            const SizedBox(width: CairnSpacing.s4),
            Expanded(
              child: Text(
                _pane == PreviewTab.preview
                    ? (samples.length == 1
                          ? 'Click the example to see its code'
                          : 'Click any example to see its code')
                    : '',
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme
                    .textStyle(CairnTypography.xs)
                    .copyWith(color: theme.mutedForeground),
              ),
            ),
          ],
        ),
        const SizedBox(height: CairnSpacing.s4),
        AnimatedSize(
          duration: CairnMotion.d200,
          curve: CairnMotion.standard,
          alignment: Alignment.topCenter,
          child: AnimatedSwitcher(
            duration: CairnMotion.d150,
            switchInCurve: CairnMotion.easeOut,
            switchOutCurve: CairnMotion.easeIn,
            child: _pane == PreviewTab.preview
                ? KeyedSubtree(
                    key: const ValueKey<String>('preview'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        PreviewSurface(
                          minHeight: widget.minHeight,
                          padding: widget.padding,
                          minContentWidth: widget.minContentWidth,
                          child: VariantSetView(
                            set: set,
                            selectedIndex: _touched ? selected : null,
                            onSelected: _select,
                          ),
                        ),
                        if (_touched) ...<Widget>[
                          const SizedBox(height: CairnSpacing.s4),
                          SelectedVariantCode(
                            sample: sample,
                            maxHeight: widget.codeMaxHeight,
                          ),
                        ],
                      ],
                    ),
                  )
                : KeyedSubtree(
                    key: const ValueKey<String>('code'),
                    child: SelectedVariantCode(
                      sample: sample,
                      maxHeight: widget.codeMaxHeight,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

/// A variant's snippet under its own name.
///
/// The name is a real [CairnBadge] rather than a styled `Text`, for the same
/// reason everything else on this site is a real Cairn widget.
class SelectedVariantCode extends StatelessWidget {
  /// Shows [sample]'s code.
  const SelectedVariantCode({
    super.key,
    required this.sample,
    this.maxHeight = 420.0,
  });

  /// The selected variant.
  final VariantSample sample;

  /// Caps the code block's height.
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            CairnBadge(
              variant: CairnBadgeVariant.secondary,
              label: Text(sample.label),
            ),
            const SizedBox(width: CairnSpacing.s3),
            Expanded(
              child: Text(
                'Exactly this instance',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme
                    .textStyle(CairnTypography.xs)
                    .copyWith(color: theme.mutedForeground),
              ),
            ),
          ],
        ),
        const SizedBox(height: CairnSpacing.s3),
        CodeBlock(sample.code, maxHeight: maxHeight),
      ],
    );
  }
}
