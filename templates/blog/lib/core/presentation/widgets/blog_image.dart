import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';

import '../../../common/constants/blog_package.dart';

/// The [ImageProvider] for a bundled asset path or an `http(s)` URL.
ImageProvider<Object> blogImageProvider(String source) =>
    source.startsWith('http://') || source.startsWith('https://')
    ? NetworkImage(source)
    : AssetImage(source, package: BlogPackage.name);

/// A photograph cropped to fill its box, with a quiet fallback.
///
/// [source] is a bundled asset path (resolved against [BlogPackage.name]) or
/// an `http(s)` URL, so content from a CMS works without changes. Size it
/// with the parent (usually an `AspectRatio`).
class BlogImage extends StatelessWidget {
  /// Creates an image.
  const BlogImage(
    this.source, {
    super.key,
    this.semanticLabel,
    this.alignment = Alignment.center,
  });

  /// Asset path or URL.
  final String source;

  /// A description for screen readers; the image is decorative without one.
  final String? semanticLabel;

  /// Which part of the photo stays in view when it is cropped.
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final Widget placeholder = ColoredBox(
      color: theme.muted,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 28,
          color: theme.mutedForeground,
        ),
      ),
    );
    return ColoredBox(
      color: theme.muted,
      child: Image(
        image: blogImageProvider(source),
        fit: BoxFit.cover,
        alignment: alignment,
        width: double.infinity,
        height: double.infinity,
        gaplessPlayback: true,
        semanticLabel: semanticLabel,
        excludeFromSemantics: semanticLabel == null,
        errorBuilder: (BuildContext c, Object e, StackTrace? s) => placeholder,
      ),
    );
  }
}

/// A round author photo larger than [CairnAvatar] offers, with initials as the
/// fallback.
class BlogAvatar extends StatelessWidget {
  /// Creates an avatar.
  const BlogAvatar({
    super.key,
    required this.source,
    required this.name,
    this.size = 64,
  });

  /// Asset path or URL.
  final String source;

  /// The person's name; used for the label.
  final String name;

  /// Diameter in logical pixels.
  final double size;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Semantics(
      image: true,
      label: name,
      child: ExcludeSemantics(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: theme.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: BlogImage(source, alignment: Alignment.topCenter),
        ),
      ),
    );
  }
}
