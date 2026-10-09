import 'dart:async';

import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart' show Icon, Icons, SelectionArea;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../../core/presentation/docs_text.dart';
import '../../../domain/docs/models/doc_block.dart';
import 'syntax.dart';

/// A syntax-highlighted code sample with a language label and a copy button.
///
/// Copying writes the trimmed source to the clipboard and shows a Cairn toast.
/// The surface, border, radius and type come from Cairn tokens; the only
/// invented colours are the syntax palette in `syntax.dart`.
class CodeBlockView extends StatefulWidget {
  /// Creates a code block.
  const CodeBlockView({super.key, required this.block});

  /// The code to show.
  final CodeBlock block;

  @override
  State<CodeBlockView> createState() => _CodeBlockViewState();
}

class _CodeBlockViewState extends State<CodeBlockView> {
  bool _copied = false;
  Timer? _reset;

  @override
  void dispose() {
    _reset?.cancel();
    super.dispose();
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.block.code.trim()));
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
    final bool dark = theme.brightness == Brightness.dark;
    final TextStyle mono = docsMono(
      theme,
      theme.textStyle(CairnTypography.sm),
      color: palette.plain,
      height: 1.7,
    ).copyWith(fontSize: 13);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: dark ? theme.card : theme.muted.withValues(alpha: 0.5),
        border: Border.all(color: theme.border),
        borderRadius: BorderRadius.circular(theme.radiusScale.lg),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(theme.radiusScale.lg - 1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 40,
              padding: const EdgeInsets.only(left: 16, right: 6),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: theme.border)),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      widget.block.title ?? widget.block.language.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: docsMono(
                        theme,
                        theme.textStyle(CairnTypography.xs),
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
                          : const Icon(Icons.content_copy_outlined, size: 14),
                      semanticLabel: 'Copy code to clipboard',
                      variant: CairnButtonVariant.ghost,
                      size: CairnButtonSize.iconSm,
                      onPressed: () => unawaited(_copy()),
                    ),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(16),
              child: SelectionArea(
                child: Text.rich(
                  TextSpan(
                    children: highlight(
                      widget.block.code.trim(),
                      widget.block.language,
                      palette,
                    ),
                  ),
                  style: mono,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
