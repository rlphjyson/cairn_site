import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../../core/presentation/blog_text.dart';
import '../../../core/presentation/widgets/blog_image.dart';
import '../../../domain/posts/models/content_block.dart';

/// Renders an article's [ContentBlock]s: headings, paragraphs, quotes,
/// bullet lists, code listings and captioned images.
class PostBody extends StatelessWidget {
  /// Creates the body.
  const PostBody(this.blocks, {super.key});

  /// The blocks, in reading order.
  final List<ContentBlock> blocks;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < blocks.length; i++)
          Padding(
            padding: EdgeInsets.only(top: _gapBefore(i)),
            child: _Block(blocks[i]),
          ),
      ],
    );
  }

  /// Headings sit closer to what they introduce than to what came before.
  double _gapBefore(int i) {
    if (i == 0) return 0;
    return switch (blocks[i]) {
      HeadingBlock(level: 2) => 44,
      HeadingBlock() => 32,
      _ => switch (blocks[i - 1]) {
        HeadingBlock() => 12,
        _ => 24,
      },
    };
  }
}

class _Block extends StatelessWidget {
  const _Block(this.block);

  final ContentBlock block;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return switch (block) {
      HeadingBlock(:final String text, :final int level) => Semantics(
        header: true,
        child: Text(
          text,
          style: blogText(
            theme,
            level == 2 ? CairnTypography.xl2 : CairnTypography.lg,
            size: level == 2 ? 26 : 20,
            weight: CairnTypography.semibold,
            tight: true,
            height: 1.3,
          ),
        ),
      ),
      ParagraphBlock(:final String text) => Text(
        text,
        style: blogText(
          theme,
          CairnTypography.base,
          size: 17,
          height: 1.75,
          color: theme.foreground.withValues(alpha: 0.88),
        ),
      ),
      QuoteBlock(:final String text, :final String? cite) => _Quote(
        text: text,
        cite: cite,
      ),
      BulletListBlock(:final List<String> items) => _Bullets(items),
      CodeBlock(:final String code, :final String? language) => _Code(
        code: code,
        language: language,
      ),
      ImageBlock(
        :final String source,
        :final String? caption,
        :final String? alt,
      ) =>
        _Figure(source: source, caption: caption, alt: alt),
    };
  }
}

class _Quote extends StatelessWidget {
  const _Quote({required this.text, this.cite});

  final String text;
  final String? cite;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Container(
      padding: const EdgeInsets.only(left: CairnSpacing.s6),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: theme.foreground, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: CairnSpacing.s3,
        children: <Widget>[
          Text(
            text,
            style: blogText(
              theme,
              CairnTypography.xl,
              size: 21,
              weight: CairnTypography.medium,
              height: 1.5,
              tight: true,
            ),
          ),
          if (cite != null)
            Text(
              cite!,
              style: blogText(theme, CairnTypography.sm, muted: true),
            ),
        ],
      ),
    );
  }
}

class _Bullets extends StatelessWidget {
  const _Bullets(this.items);

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: CairnSpacing.s3,
      children: <Widget>[
        for (final String item in items)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 12, left: 4, right: 14),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: theme.mutedForeground,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  item,
                  style: blogText(
                    theme,
                    CairnTypography.base,
                    size: 17,
                    height: 1.65,
                    color: theme.foreground.withValues(alpha: 0.88),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _Code extends StatelessWidget {
  const _Code({required this.code, this.language});

  final String code;
  final String? language;

  static const List<String> _mono = <String>[
    'SFMono-Regular',
    'Menlo',
    'Consolas',
    'Liberation Mono',
    'monospace',
  ];

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.muted.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(theme.radiusScale.lg),
        border: Border.all(color: theme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(
              CairnSpacing.s4,
              CairnSpacing.s1,
              CairnSpacing.s2,
              CairnSpacing.s1,
            ),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: theme.border)),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    (language ?? 'code').toUpperCase(),
                    style: blogText(
                      theme,
                      CairnTypography.xs,
                      muted: true,
                      weight: CairnTypography.medium,
                    ).copyWith(letterSpacing: 0.8),
                  ),
                ),
                CairnButton.icon(
                  icon: const Icon(Icons.content_copy, size: 14),
                  semanticLabel: 'Copy code',
                  variant: CairnButtonVariant.ghost,
                  size: CairnButtonSize.iconSm,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    CairnToast.show(
                      context,
                      const CairnToast(
                        title: 'Code copied',
                        variant: CairnToastVariant.success,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(CairnSpacing.s4),
            child: Text(
              code,
              softWrap: false,
              style: blogText(
                theme,
                CairnTypography.sm,
                size: 13,
                height: 1.7,
              ).copyWith(fontFamily: _mono.first, fontFamilyFallback: _mono),
            ),
          ),
        ],
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.source, this.caption, this.alt});

  final String source;
  final String? caption;
  final String? alt;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: CairnSpacing.s3,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(theme.radiusScale.xl),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: BlogImage(source, semanticLabel: alt ?? caption),
          ),
        ),
        if (caption != null)
          Text(
            caption!,
            textAlign: TextAlign.center,
            style: blogText(theme, CairnTypography.sm, muted: true),
          ),
      ],
    );
  }
}
