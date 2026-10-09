import 'package:flutter/widgets.dart';

import '../../common/constants/section_ids.dart';
import '../faq/views/faq_view.dart';
import '../features/views/features_view.dart';
import '../footer/views/footer_view.dart';
import '../hero/views/hero_view.dart';
import '../how_it_works/views/how_it_works_view.dart';
import '../logos/views/logos_view.dart';
import '../pricing/views/pricing_view.dart';
import '../stats/views/stats_view.dart';
import '../testimonials/views/testimonials_view.dart';
import '../waitlist/views/waitlist_view.dart';

/// Every section, top to bottom.
///
/// Each section is wrapped in the [GlobalKey] registered for its id in
/// `SectionIds`, which is what the navbar scrolls to. To reorder, add or
/// remove a section, edit this list and `SectionIds`.
class LandingPage extends StatelessWidget {
  /// Creates the page.
  const LandingPage({super.key, required this.sectionKeys});

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
        keyed(SectionIds.logos, const LogosView()),
        keyed(SectionIds.features, const FeaturesView()),
        keyed(SectionIds.howItWorks, const HowItWorksView()),
        keyed(SectionIds.stats, const StatsView()),
        keyed(SectionIds.testimonials, const TestimonialsView()),
        keyed(SectionIds.pricing, const PricingView()),
        keyed(SectionIds.faq, const FaqView()),
        keyed(SectionIds.waitlist, const WaitlistView()),
        keyed(SectionIds.footer, const FooterView()),
      ],
    );
  }
}
