import 'package:flutter/widgets.dart';

import '../../common/constants/section_ids.dart';
import '../download/views/download_view.dart';
import '../faq/views/faq_view.dart';
import '../features/views/features_view.dart';
import '../footer/views/footer_view.dart';
import '../gallery/views/gallery_view.dart';
import '../hero/views/hero_view.dart';
import '../how_it_works/views/how_it_works_view.dart';
import '../pricing/views/pricing_view.dart';
import '../reviews/views/reviews_view.dart';
import '../stats/views/stats_view.dart';
import '../trust/views/trust_view.dart';

/// Every section, top to bottom.
///
/// Each section is wrapped in the [GlobalKey] registered for its id in
/// `SectionIds`, which is what the navbar scrolls to. To reorder, add or
/// remove a section, edit this list and `SectionIds`.
class AppLandingPage extends StatelessWidget {
  /// Creates the page.
  const AppLandingPage({super.key, required this.sectionKeys});

  /// One key per id in [SectionIds.all].
  final Map<String, GlobalKey> sectionKeys;

  @override
  Widget build(BuildContext context) {
    Widget keyed(String id, Widget child) =>
        KeyedSubtree(key: sectionKeys[id], child: child);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        keyed(SectionIds.hero, const HeroView()),
        keyed(SectionIds.trust, const TrustView()),
        keyed(SectionIds.features, const FeaturesView()),
        keyed(SectionIds.howItWorks, const HowItWorksView()),
        keyed(SectionIds.gallery, const GalleryView()),
        keyed(SectionIds.stats, const StatsView()),
        keyed(SectionIds.reviews, const ReviewsView()),
        keyed(SectionIds.pricing, const PricingView()),
        keyed(SectionIds.faq, const FaqView()),
        keyed(SectionIds.download, const DownloadView()),
        keyed(SectionIds.footer, const FooterView()),
      ],
    );
  }
}
