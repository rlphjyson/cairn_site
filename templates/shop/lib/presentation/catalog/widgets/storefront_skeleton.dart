import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

/// A placeholder for the promotional banner while the catalogue loads.
class StorefrontBannerSkeleton extends StatelessWidget {
  /// Creates the placeholder.
  const StorefrontBannerSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Loading offers',
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CairnSkeleton(
        height: 164,
        borderRadius: BorderRadius.circular(
          CairnTheme.of(context).radiusScale.xl,
        ),
      ),
    ),
  );
}

/// Placeholder tiles shaped like the product grid, shown while loading.
class StorefrontGridSkeleton extends StatelessWidget {
  /// Creates the placeholder.
  const StorefrontGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final double radius = CairnTheme.of(context).radiusScale.lg;
    Widget tile() => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1,
            child: CairnSkeleton(borderRadius: BorderRadius.circular(radius)),
          ),
          const SizedBox(height: 8),
          const CairnSkeleton(height: 14, width: 110),
          const SizedBox(height: 6),
          const CairnSkeleton(height: 12, width: 70),
        ],
      ),
    );
    return Semantics(
      label: 'Loading products',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const CairnSkeleton(height: 18, width: 100),
            const SizedBox(height: 12),
            for (int row = 0; row < 2; row++) ...<Widget>[
              Row(spacing: 12, children: <Widget>[tile(), tile()]),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}
