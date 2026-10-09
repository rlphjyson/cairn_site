import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/site/models/site_info.dart';
import '../app_landing_actions.dart';
import '../app_landing_icons.dart';
import '../app_landing_text.dart';
import '../content_cubit.dart';

/// Builds [builder] once the site info (brand and store links) has loaded.
///
/// The site info is a session cubit shared by the navbar, the hero, the
/// download section and the footer, so the app is named in exactly one place.
class SiteBuilder extends StatelessWidget {
  /// Creates a builder.
  const SiteBuilder({super.key, required this.builder});

  /// Builds from the loaded site info.
  final Widget Function(BuildContext context, SiteInfo site) builder;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ContentCubit<SiteInfo>, ContentState<SiteInfo>>(
        builder: (BuildContext context, ContentState<SiteInfo> state) {
          final SiteInfo? site = state.data;
          if (site == null) return const SizedBox(height: 40);
          return builder(context, site);
        },
      );
}

/// The two store buttons, built as [CairnButton]s with Material glyphs: a
/// generic "Download on the App Store" and "Get it on Google Play". No real
/// store logos are used.
class StoreButtons extends StatelessWidget {
  /// Creates the buttons.
  const StoreButtons({
    super.key,
    this.alignment = WrapAlignment.start,
    this.variant = CairnButtonVariant.primary,
  });

  /// How the two buttons sit when they wrap.
  final WrapAlignment alignment;

  /// The button variant.
  final CairnButtonVariant variant;

  @override
  Widget build(BuildContext context) => SiteBuilder(
    builder: (BuildContext context, SiteInfo site) => Wrap(
      alignment: alignment,
      spacing: CairnSpacing.s3,
      runSpacing: CairnSpacing.s3,
      children: <Widget>[
        for (final StoreKind kind in StoreKind.values)
          StoreButton(kind: kind, link: site.storeFor(kind), variant: variant),
      ],
    ),
  );
}

/// One store button: a small caption over the store name.
class StoreButton extends StatelessWidget {
  /// Creates a button.
  const StoreButton({
    super.key,
    required this.kind,
    required this.link,
    this.variant = CairnButtonVariant.primary,
  });

  /// Which store.
  final StoreKind kind;

  /// The label, glyph and listing URL.
  final StoreLink link;

  /// The button variant.
  final CairnButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool filled = variant == CairnButtonVariant.primary;
    final Color color = filled ? theme.primaryForeground : theme.foreground;
    return CairnButton(
      size: CairnButtonSize.lg,
      variant: variant,
      semanticLabel: link.spoken,
      leading: Icon(AppLandingIcons.byName(link.icon), size: 22, color: color),
      onPressed: () => AppLandingActions.of(context).openStore(kind, link.href),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            link.caption,
            style: appLandingText(
              theme,
              CairnTypography.xs,
              size: 10,
              color: color.withValues(alpha: 0.85),
              height: 1.1,
            ),
          ),
          Text(
            link.label,
            style: appLandingText(
              theme,
              CairnTypography.base,
              color: color,
              weight: CairnTypography.semibold,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}
