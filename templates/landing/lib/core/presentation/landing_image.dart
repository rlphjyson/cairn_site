import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../common/constants/landing_package.dart';

/// The provider for a bundled image, honouring [LandingPackage.name].
ImageProvider<Object> landingImage(String asset) =>
    AssetImage(asset, package: LandingPackage.name);

/// A bundled photograph, cropped to fill its box.
///
/// While the file decodes (or if it is missing) a muted surface shows instead
/// of a blank hole.
class LandingPhoto extends StatelessWidget {
  /// Creates a photo.
  const LandingPhoto(
    this.asset, {
    super.key,
    this.semanticLabel,
    this.alignment = Alignment.center,
  });

  /// The asset path, for example `assets/images/team-meeting.jpg`.
  final String asset;

  /// A description for screen readers; null marks the image decorative.
  final String? semanticLabel;

  /// Which part of the photo stays in view when it is cropped.
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return ColoredBox(
      color: theme.muted,
      child: Image(
        image: landingImage(asset),
        fit: BoxFit.cover,
        alignment: alignment,
        width: double.infinity,
        height: double.infinity,
        semanticLabel: semanticLabel,
        excludeFromSemantics: semanticLabel == null,
        errorBuilder: (BuildContext _, Object _, StackTrace? _) =>
            const SizedBox.expand(),
      ),
    );
  }
}
