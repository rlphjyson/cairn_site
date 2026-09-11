import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

import 'code_block.dart';
import 'surfaces.dart';
import 'syntax.dart';

/// Which half of a pane is showing.
enum PreviewTab {
  /// The live widget.
  preview,

  /// The snippet.
  code,
}

/// The bordered canvas a live preview sits on.
///
/// Extracted so [PreviewPane] and `VariantPreviewPane` draw an identical
/// surface rather than two that drift apart. A bordered panel over a [DotGrid],
/// so that transparent components still read as deliberate.
class PreviewSurface extends StatelessWidget {
  /// Creates a surface around [child].
  const PreviewSurface({
    super.key,
    required this.child,
    this.minHeight = 240.0,
    this.padding = const EdgeInsets.all(CairnSpacing.s8),
    this.alignment = Alignment.center,
    this.fillWidth = false,
    this.minContentWidth = 640.0,
  });

  /// The live content.
  final Widget child;

  /// The minimum height of the surface.
  final double minHeight;

  /// Padding around the content.
  final EdgeInsets padding;

  /// Where the content sits inside the surface.
  final Alignment alignment;

  /// Whether the content should stretch to the surface's width.
  final bool fillWidth;

  /// The narrowest the content is ever laid out at.
  final double minContentWidth;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final Widget body = Padding(padding: padding, child: child);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.border),
        borderRadius: BorderRadius.circular(theme.radiusScale.lg),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(theme.radiusScale.lg),
        child: DotGrid(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: fillWidth
                ? SizedBox(width: double.infinity, child: body)
                : MinWidthScroller(
                    minWidth: minContentWidth,
                    alignment: alignment,
                    child: body,
                  ),
          ),
        ),
      ),
    );
  }
}

/// The Preview / Code toggle, as a real [CairnTabs].
///
/// The same widget the catalogue documents, doing the site's own job.
class PreviewTabs extends StatelessWidget {
  /// Creates the toggle.
  const PreviewTabs({super.key, required this.value, required this.onChanged});

  /// The showing half.
  final PreviewTab value;

  /// Called when the visitor switches.
  final ValueChanged<PreviewTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return CairnTabs<PreviewTab>(
      value: value,
      onChanged: onChanged,
      tabs: const <CairnTab<PreviewTab>>[
        CairnTab<PreviewTab>(value: PreviewTab.preview, label: Text('Preview')),
        CairnTab<PreviewTab>(value: PreviewTab.code, label: Text('Code')),
      ],
    );
  }
}

/// A live preview with a Preview / Code toggle over one fixed snippet.
///
/// Used by Blocks and Charts, where the preview is one composed thing rather
/// than a set of addressable variants. Component detail pages use
/// `VariantPreviewPane` instead.
class PreviewPane extends StatefulWidget {
  /// Creates a pane.
  const PreviewPane({
    super.key,
    required this.preview,
    required this.code,
    this.language = CodeLanguage.dart,
    this.minHeight = 240.0,
    this.padding = const EdgeInsets.all(CairnSpacing.s8),
    this.alignment = Alignment.center,
    this.codeMaxHeight = 420.0,
    this.fillWidth = false,
    this.minContentWidth = 640.0,
  });

  /// Builds the live widget.
  final WidgetBuilder preview;

  /// The snippet shown on the Code tab.
  final String code;

  /// Which grammar the snippet is.
  final CodeLanguage language;

  /// The minimum height of the preview surface.
  final double minHeight;

  /// Padding around the preview.
  final EdgeInsets padding;

  /// Where the preview sits inside the surface.
  final Alignment alignment;

  /// Caps the code pane's height.
  final double codeMaxHeight;

  /// Whether the preview should stretch to the pane's width.
  ///
  /// Off by default, which centres the preview at its natural size. Charts set
  /// this, because they fill rather than size themselves.
  final bool fillWidth;

  /// The narrowest the preview is ever laid out at.
  ///
  /// 640 covers every component preview in the catalogue — the widest is the
  /// 560px data table. Blocks that need a desktop canvas raise it.
  final double minContentWidth;

  @override
  State<PreviewPane> createState() => _PreviewPaneState();
}

class _PreviewPaneState extends State<PreviewPane> {
  PreviewTab _pane = PreviewTab.preview;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Align(
          alignment: Alignment.centerLeft,
          child: PreviewTabs(
            value: _pane,
            onChanged: (PreviewTab v) => setState(() => _pane = v),
          ),
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
                    child: PreviewSurface(
                      minHeight: widget.minHeight,
                      padding: widget.padding,
                      alignment: widget.alignment,
                      fillWidth: widget.fillWidth,
                      minContentWidth: widget.minContentWidth,
                      child: Builder(builder: widget.preview),
                    ),
                  )
                : KeyedSubtree(
                    key: const ValueKey<String>('code'),
                    child: CodeBlock(
                      widget.code,
                      language: widget.language,
                      maxHeight: widget.codeMaxHeight,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
