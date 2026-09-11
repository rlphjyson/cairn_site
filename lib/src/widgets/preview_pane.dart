import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

import 'code_block.dart';
import 'surfaces.dart';
import 'syntax.dart';

enum _Pane { preview, code }

/// A live component preview with a Preview / Code toggle.
///
/// The toggle is a real [CairnTabs] — the same widget the catalogue documents,
/// doing the site's own job. The preview surface is a bordered panel over a
/// [DotGrid] so that transparent components still read as deliberate.
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
  _Pane _pane = _Pane.preview;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Align(
          alignment: Alignment.centerLeft,
          child: CairnTabs<_Pane>(
            value: _pane,
            onChanged: (_Pane v) => setState(() => _pane = v),
            tabs: const <CairnTab<_Pane>>[
              CairnTab<_Pane>(value: _Pane.preview, label: Text('Preview')),
              CairnTab<_Pane>(value: _Pane.code, label: Text('Code')),
            ],
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
            child: _pane == _Pane.preview
                ? _previewSurface(theme)
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

  Widget _previewSurface(CairnTheme theme) {
    final Widget body = Padding(
      padding: widget.padding,
      child: Builder(builder: widget.preview),
    );

    return KeyedSubtree(
      key: const ValueKey<String>('preview'),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: theme.border),
          borderRadius: BorderRadius.circular(theme.radiusScale.lg),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(theme.radiusScale.lg),
          child: DotGrid(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: widget.minHeight),
              child: widget.fillWidth
                  ? SizedBox(width: double.infinity, child: body)
                  : MinWidthScroller(
                      minWidth: widget.minContentWidth,
                      alignment: widget.alignment,
                      child: body,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
