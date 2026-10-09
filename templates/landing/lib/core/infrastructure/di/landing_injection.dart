import 'package:get_it/get_it.dart';

import '../../../data/faq/remote/faq_remote_data_source.dart';
import '../../../data/faq/repositories/faq_repository_impl.dart';
import '../../../data/features/remote/features_remote_data_source.dart';
import '../../../data/features/repositories/features_repository_impl.dart';
import '../../../data/footer/remote/footer_remote_data_source.dart';
import '../../../data/footer/repositories/footer_repository_impl.dart';
import '../../../data/hero/remote/hero_remote_data_source.dart';
import '../../../data/hero/repositories/hero_repository_impl.dart';
import '../../../data/how_it_works/remote/how_it_works_remote_data_source.dart';
import '../../../data/how_it_works/repositories/how_it_works_repository_impl.dart';
import '../../../data/logos/remote/logos_remote_data_source.dart';
import '../../../data/logos/repositories/logos_repository_impl.dart';
import '../../../data/pricing/remote/pricing_remote_data_source.dart';
import '../../../data/pricing/repositories/pricing_repository_impl.dart';
import '../../../data/site/remote/site_remote_data_source.dart';
import '../../../data/site/repositories/site_repository_impl.dart';
import '../../../data/stats/remote/stats_remote_data_source.dart';
import '../../../data/stats/repositories/stats_repository_impl.dart';
import '../../../data/testimonials/remote/testimonials_remote_data_source.dart';
import '../../../data/testimonials/repositories/testimonials_repository_impl.dart';
import '../../../data/waitlist/remote/waitlist_remote_data_source.dart';
import '../../../data/waitlist/repositories/waitlist_repository_impl.dart';
import '../../../domain/faq/models/faq_content.dart';
import '../../../domain/faq/repositories/faq_repository.dart';
import '../../../domain/faq/use_cases/get_faq.dart';
import '../../../domain/features/models/features_content.dart';
import '../../../domain/features/repositories/features_repository.dart';
import '../../../domain/features/use_cases/get_features.dart';
import '../../../domain/footer/models/footer_content.dart';
import '../../../domain/footer/repositories/footer_repository.dart';
import '../../../domain/footer/use_cases/get_footer.dart';
import '../../../domain/hero/models/hero_content.dart';
import '../../../domain/hero/repositories/hero_repository.dart';
import '../../../domain/hero/use_cases/get_hero.dart';
import '../../../domain/how_it_works/models/how_it_works_content.dart';
import '../../../domain/how_it_works/repositories/how_it_works_repository.dart';
import '../../../domain/how_it_works/use_cases/get_how_it_works.dart';
import '../../../domain/logos/models/logo_cloud.dart';
import '../../../domain/logos/repositories/logos_repository.dart';
import '../../../domain/logos/use_cases/get_logo_cloud.dart';
import '../../../domain/pricing/repositories/pricing_repository.dart';
import '../../../domain/pricing/use_cases/calculate_price.dart';
import '../../../domain/pricing/use_cases/get_pricing.dart';
import '../../../domain/site/models/site_info.dart';
import '../../../domain/site/repositories/site_repository.dart';
import '../../../domain/site/use_cases/get_site_info.dart';
import '../../../domain/stats/models/stats_content.dart';
import '../../../domain/stats/repositories/stats_repository.dart';
import '../../../domain/stats/use_cases/get_stats.dart';
import '../../../domain/testimonials/models/testimonials_content.dart';
import '../../../domain/testimonials/repositories/testimonials_repository.dart';
import '../../../domain/testimonials/use_cases/get_testimonials.dart';
import '../../../domain/waitlist/repositories/waitlist_repository.dart';
import '../../../domain/waitlist/use_cases/get_waitlist.dart';
import '../../../domain/waitlist/use_cases/join_waitlist.dart';
import '../../../domain/waitlist/use_cases/validate_email.dart';
import '../../../presentation/pricing/bloc/pricing_cubit.dart';
import '../../../presentation/pricing/view_models/pricing_view_model.dart';
import '../../../presentation/waitlist/bloc/waitlist_cubit.dart';
import '../../../presentation/waitlist/view_models/waitlist_view_model.dart';
import '../../presentation/content_cubit.dart';
import '../../presentation/navigation/landing_navigation_cubit.dart';

/// Builds a fresh dependency container for one mount of the template.
///
/// Registration is explicit, so there is no `build_runner` step. Scopes:
///
/// * data sources and repositories: lazy singletons. **To use a real backend,
///   register your own data source here in place of the `InMemory` one.**
/// * use cases: factories (stateless and free to build);
/// * **session cubits** (navigation, the site info shared by navbar and
///   footer): lazy singletons, provided once and never closed by a view model;
/// * **screen cubits** (every section, the pricing toggle, the waitlist
///   form): created and closed by their view model.
///
/// [overrides] runs after every registration and before anything is resolved,
/// so it can swap a data source, a repository or a use case for your own with
/// `unregister` and `register...`, without editing this file.
GetIt createLandingLocator({void Function(GetIt locator)? overrides}) {
  final GetIt g = GetIt.asNewInstance();

  // Data sources.
  g
    ..registerLazySingleton<SiteRemoteDataSource>(
      InMemorySiteRemoteDataSource.new,
    )
    ..registerLazySingleton<HeroRemoteDataSource>(
      InMemoryHeroRemoteDataSource.new,
    )
    ..registerLazySingleton<LogosRemoteDataSource>(
      InMemoryLogosRemoteDataSource.new,
    )
    ..registerLazySingleton<FeaturesRemoteDataSource>(
      InMemoryFeaturesRemoteDataSource.new,
    )
    ..registerLazySingleton<HowItWorksRemoteDataSource>(
      InMemoryHowItWorksRemoteDataSource.new,
    )
    ..registerLazySingleton<StatsRemoteDataSource>(
      InMemoryStatsRemoteDataSource.new,
    )
    ..registerLazySingleton<TestimonialsRemoteDataSource>(
      InMemoryTestimonialsRemoteDataSource.new,
    )
    ..registerLazySingleton<PricingRemoteDataSource>(
      InMemoryPricingRemoteDataSource.new,
    )
    ..registerLazySingleton<FaqRemoteDataSource>(
      InMemoryFaqRemoteDataSource.new,
    )
    ..registerLazySingleton<WaitlistRemoteDataSource>(
      InMemoryWaitlistRemoteDataSource.new,
    )
    ..registerLazySingleton<FooterRemoteDataSource>(
      InMemoryFooterRemoteDataSource.new,
    );

  // Repositories.
  g
    ..registerLazySingleton<SiteRepository>(() => SiteRepositoryImpl(g()))
    ..registerLazySingleton<HeroRepository>(() => HeroRepositoryImpl(g()))
    ..registerLazySingleton<LogosRepository>(() => LogosRepositoryImpl(g()))
    ..registerLazySingleton<FeaturesRepository>(
      () => FeaturesRepositoryImpl(g()),
    )
    ..registerLazySingleton<HowItWorksRepository>(
      () => HowItWorksRepositoryImpl(g()),
    )
    ..registerLazySingleton<StatsRepository>(() => StatsRepositoryImpl(g()))
    ..registerLazySingleton<TestimonialsRepository>(
      () => TestimonialsRepositoryImpl(g()),
    )
    ..registerLazySingleton<PricingRepository>(() => PricingRepositoryImpl(g()))
    ..registerLazySingleton<FaqRepository>(() => FaqRepositoryImpl(g()))
    ..registerLazySingleton<WaitlistRepository>(
      () => WaitlistRepositoryImpl(g()),
    )
    ..registerLazySingleton<FooterRepository>(() => FooterRepositoryImpl(g()));

  // Use cases.
  g
    ..registerFactory<GetSiteInfo>(() => GetSiteInfo(g()))
    ..registerFactory<GetHero>(() => GetHero(g()))
    ..registerFactory<GetLogoCloud>(() => GetLogoCloud(g()))
    ..registerFactory<GetFeatures>(() => GetFeatures(g()))
    ..registerFactory<GetHowItWorks>(() => GetHowItWorks(g()))
    ..registerFactory<GetStats>(() => GetStats(g()))
    ..registerFactory<GetTestimonials>(() => GetTestimonials(g()))
    ..registerFactory<GetPricing>(() => GetPricing(g()))
    ..registerFactory<CalculatePrice>(CalculatePrice.new)
    ..registerFactory<GetFaq>(() => GetFaq(g()))
    ..registerFactory<GetWaitlist>(() => GetWaitlist(g()))
    ..registerFactory<ValidateEmail>(ValidateEmail.new)
    ..registerFactory<JoinWaitlist>(() => JoinWaitlist(g(), g()))
    ..registerFactory<GetFooter>(() => GetFooter(g()));

  // Session cubits.
  g
    ..registerLazySingleton<LandingNavigationCubit>(
      LandingNavigationCubit.new,
      dispose: (LandingNavigationCubit c) => c.close(),
    )
    ..registerLazySingleton<ContentCubit<SiteInfo>>(
      () => ContentCubit<SiteInfo>(g<GetSiteInfo>().call),
      dispose: (ContentCubit<SiteInfo> c) => c.close(),
    );

  // Screen view models. Content-only sections share one generic view model;
  // sections with behaviour have their own.
  g
    ..registerFactory<ContentViewModel<HeroContent>>(
      () => ContentViewModel<HeroContent>(
        ContentCubit<HeroContent>(g<GetHero>().call),
      ),
    )
    ..registerFactory<ContentViewModel<LogoCloud>>(
      () => ContentViewModel<LogoCloud>(
        ContentCubit<LogoCloud>(g<GetLogoCloud>().call),
      ),
    )
    ..registerFactory<ContentViewModel<FeaturesContent>>(
      () => ContentViewModel<FeaturesContent>(
        ContentCubit<FeaturesContent>(g<GetFeatures>().call),
      ),
    )
    ..registerFactory<ContentViewModel<HowItWorksContent>>(
      () => ContentViewModel<HowItWorksContent>(
        ContentCubit<HowItWorksContent>(g<GetHowItWorks>().call),
      ),
    )
    ..registerFactory<ContentViewModel<StatsContent>>(
      () => ContentViewModel<StatsContent>(
        ContentCubit<StatsContent>(g<GetStats>().call),
      ),
    )
    ..registerFactory<ContentViewModel<TestimonialsContent>>(
      () => ContentViewModel<TestimonialsContent>(
        ContentCubit<TestimonialsContent>(g<GetTestimonials>().call),
      ),
    )
    ..registerFactory<ContentViewModel<FaqContent>>(
      () => ContentViewModel<FaqContent>(
        ContentCubit<FaqContent>(g<GetFaq>().call),
      ),
    )
    ..registerFactory<ContentViewModel<FooterContent>>(
      () => ContentViewModel<FooterContent>(
        ContentCubit<FooterContent>(g<GetFooter>().call),
      ),
    )
    ..registerFactory<PricingViewModel>(
      () => PricingViewModel(PricingCubit(g(), g())),
    )
    ..registerFactory<WaitlistViewModel>(
      () => WaitlistViewModel(WaitlistCubit(g(), g())),
    );

  overrides?.call(g);

  return g;
}
