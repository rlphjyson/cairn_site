import 'dart:async';

import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/site_theme.dart';
import 'site_icons.dart';
import 'syntax.dart';

/// A syntax-highlighted code block with a copy button.
///
/// The surface, border, radius and type all come from Cairn tokens; the copy
/// affordance is a real [CairnButton] wrapped in a real [CairnTooltip], and the
/// confirmation is a real [CairnToast]. The only thing invented here is the
/// syntax palette, which is documented in `syntax.dart`.
class CodeBlock extends StatefulWidget {
  /// Creates a code block.
  const CodeBlock(
    this.code, {
    super.key,
    this.language = CodeLanguage.dart,
    this.filename,
    this.maxHeight,
    this.showHeader = true,
  });

  /// The source to render. Leading and trailing blank lines are trimmed.
  final String code;

  /// Which grammar to highlight with.
  final CodeLanguage language;

  /// Shown in the header instead of the language label.
  final String? filename;

  /// Caps the block's height and makes it scroll vertically.
  final double? maxHeight;

  /// Whether to draw the filename/copy header strip.
  final bool showHeader;

  @override
  State<CodeBlock> createState() => _CodeBlockState();
}

class _CodeBlockState extends State<CodeBlock> {
  bool _copied = false;
  Timer? _reset;

  @override
  void dispose() {
    _reset?.cancel();
    super.dispose();
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.code.trim()));
    if (!mounted) return;
    setState(() => _copied = true);
    CairnToast.show(
      context,
      const CairnToast(
        variant: CairnToastVariant.success,
        title: 'Copied to clipboard',
        duration: Duration(seconds: 2),
      ),
    );
    _reset?.cancel();
    _reset = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final SyntaxTheme palette = SyntaxTheme.of(theme);
    final Color surface = theme.brightness == Brightness.dark
        ? theme.card
        : theme.muted;

    final TextStyle mono = theme
        .textStyle(CairnTypography.sm)
        .copyWith(
          fontFamily: 'monospace',
          fontFamilyFallback: SiteTokens.monoFallback,
          height: 1.65,
          color: palette.plain,
        );

    Widget body = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(CairnSpacing.s4),
      child: SelectionArea(
        child: Text.rich(
          TextSpan(
            children: highlight(widget.code.trim(), widget.language, palette),
          ),
          style: mono,
        ),
      ),
    );

    if (widget.maxHeight != null) {
      body = ConstrainedBox(
        constraints: BoxConstraints(maxHeight: widget.maxHeight!),
        child: CairnScrollArea(child: body),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface,
        border: Border.all(color: theme.border),
        borderRadius: BorderRadius.circular(theme.radiusScale.lg),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(theme.radiusScale.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (widget.showHeader) _header(theme),
            Flexible(child: body),
          ],
        ),
      ),
    );
  }

  Widget _header(CairnTheme theme) {
    return Container(
      height: 40,
      padding: const EdgeInsets.only(
        left: CairnSpacing.s4,
        right: CairnSpacing.s1p5,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.border)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              widget.filename ?? widget.language.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme
                  .textStyle(CairnTypography.xs)
                  .copyWith(
                    fontFamily: 'monospace',
                    fontFamilyFallback: SiteTokens.monoFallback,
                    color: theme.mutedForeground,
                  ),
            ),
          ),
          CairnTooltip(
            message: _copied ? 'Copied' : 'Copy to clipboard',
            openDelay: const Duration(milliseconds: 400),
            child: CairnButton.icon(
              icon: _copied
                  ? const CairnIcon(CairnIconData.check, size: 14)
                  : const SiteIcon(SiteIconData.copy, size: 14),
              semanticLabel: 'Copy code to clipboard',
              variant: CairnButtonVariant.ghost,
              size: CairnButtonSize.iconSm,
              onPressed: () => unawaited(_copy()),
            ),
          ),
        ],
      ),
    );
  }
}
