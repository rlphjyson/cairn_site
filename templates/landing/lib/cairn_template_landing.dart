/// The SaaS landing page template.
///
/// [LandingApp] is the entry point. The data source interfaces are exported
/// too, so a host can swap in real content or a real signup service through
/// `LandingApp.overrides` without importing from `src`-style paths.
library;

export 'common/constants/section_ids.dart' show SectionIds;
export 'common/utils/json.dart' show JsonMap, JsonReader;
export 'data/faq/remote/faq_remote_data_source.dart' show FaqRemoteDataSource;
export 'data/features/remote/features_remote_data_source.dart'
    show FeaturesRemoteDataSource;
export 'data/footer/remote/footer_remote_data_source.dart'
    show FooterRemoteDataSource;
export 'data/hero/remote/hero_remote_data_source.dart'
    show HeroRemoteDataSource;
export 'data/how_it_works/remote/how_it_works_remote_data_source.dart'
    show HowItWorksRemoteDataSource;
export 'data/logos/remote/logos_remote_data_source.dart'
    show LogosRemoteDataSource;
export 'data/pricing/remote/pricing_remote_data_source.dart'
    show InMemoryPricingRemoteDataSource, PricingRemoteDataSource;
export 'data/site/remote/site_remote_data_source.dart'
    show SiteRemoteDataSource;
export 'data/stats/remote/stats_remote_data_source.dart'
    show StatsRemoteDataSource;
export 'data/testimonials/remote/testimonials_remote_data_source.dart'
    show TestimonialsRemoteDataSource;
export 'data/waitlist/remote/waitlist_remote_data_source.dart'
    show InMemoryWaitlistRemoteDataSource, WaitlistRemoteDataSource;
export 'domain/waitlist/models/join_outcome.dart' show WaitlistException;
export 'landing_app.dart';
