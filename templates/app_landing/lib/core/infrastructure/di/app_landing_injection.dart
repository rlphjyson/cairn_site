import 'package:get_it/get_it.dart';

import '../../../data/content/remote/app_content_data_source.dart';
import '../../../data/download/remote/download_link_service.dart';
import '../../../data/download/repositories/download_repository_impl.dart';
import '../../../data/faq/repositories/faq_repository_impl.dart';
import '../../../data/features/repositories/features_repository_impl.dart';
import '../../../data/footer/repositories/footer_repository_impl.dart';
import '../../../data/gallery/repositories/gallery_repository_impl.dart';
import '../../../data/hero/repositories/hero_repository_impl.dart';
import '../../../data/how_it_works/repositories/how_it_works_repository_impl.dart';
import '../../../data/pricing/repositories/pricing_repository_impl.dart';
import '../../../data/reviews/repositories/reviews_repository_impl.dart';
import '../../../data/site/repositories/site_repository_impl.dart';
import '../../../data/stats/repositories/stats_repository_impl.dart';
import '../../../data/trust/repositories/trust_repository_impl.dart';
import '../../../domain/download/repositories/download_repository.dart';
import '../../../domain/download/use_cases/build_qr_pattern.dart';
import '../../../domain/download/use_cases/get_download.dart';
import '../../../domain/download/use_cases/send_download_link.dart';
import '../../../domain/download/use_cases/validate_contact.dart';
import '../../../domain/faq/models/faq_content.dart';
import '../../../domain/faq/repositories/faq_repository.dart';
import '../../../domain/faq/use_cases/get_faq.dart';
import '../../../domain/features/repositories/features_repository.dart';
import '../../../domain/features/use_cases/get_features.dart';
import '../../../domain/footer/models/footer_content.dart';
import '../../../domain/footer/repositories/footer_repository.dart';
import '../../../domain/footer/use_cases/get_footer.dart';
import '../../../domain/gallery/repositories/gallery_repository.dart';
import '../../../domain/gallery/use_cases/get_gallery.dart';
import '../../../domain/hero/models/hero_content.dart';
import '../../../domain/hero/repositories/hero_repository.dart';
import '../../../domain/hero/use_cases/get_hero.dart';
import '../../../domain/how_it_works/models/how_it_works_content.dart';
import '../../../domain/how_it_works/repositories/how_it_works_repository.dart';
import '../../../domain/how_it_works/use_cases/get_how_it_works.dart';
import '../../../domain/pricing/repositories/pricing_repository.dart';
import '../../../domain/pricing/use_cases/calculate_price.dart';
import '../../../domain/pricing/use_cases/get_pricing.dart';
import '../../../domain/reviews/models/reviews_content.dart';
import '../../../domain/reviews/repositories/reviews_repository.dart';
import '../../../domain/reviews/use_cases/get_reviews.dart';
import '../../../domain/site/models/site_info.dart';
import '../../../domain/site/repositories/site_repository.dart';
import '../../../domain/site/use_cases/get_site_info.dart';
import '../../../domain/stats/models/stats_content.dart';
import '../../../domain/stats/repositories/stats_repository.dart';
import '../../../domain/stats/use_cases/get_stats.dart';
import '../../../domain/trust/models/trust_content.dart';
import '../../../domain/trust/repositories/trust_repository.dart';
import '../../../domain/trust/use_cases/get_trust.dart';
import '../../../presentation/download/bloc/download_cubit.dart';
import '../../../presentation/download/view_models/download_view_model.dart';
import '../../../presentation/features/bloc/features_cubit.dart';
import '../../../presentation/features/view_models/features_view_model.dart';
import '../../../presentation/gallery/bloc/gallery_cubit.dart';
import '../../../presentation/gallery/view_models/gallery_view_model.dart';
import '../../../presentation/pricing/bloc/pricing_cubit.dart';
import '../../../presentation/pricing/view_models/pricing_view_model.dart';
import '../../presentation/content_cubit.dart';
import '../../presentation/navigation/app_landing_navigation_cubit.dart';

/// Builds a fresh dependency container for one mount of the template.
///
/// Registration is explicit, so there is no `build_runner` step. Scopes:
///
/// * the content data source and the link service: lazy singletons. **To use a
///   real CMS or SMS and email backend, pass your own [contentDataSource] and
///   [linkService] (or register them in place of the `InMemory` ones here).**
/// * repositories: lazy singletons;
/// * use cases: factories (stateless and free to build);
/// * **session cubits** (navigation, the site info shared by the navbar, the
///   hero, the download section and the footer): lazy singletons, provided once
///   and never closed by a view model;
/// * **screen cubits** (every section, the feature tabs, the gallery, the
///   pricing toggle, the send-link form): created and closed by their view
///   model.
///
/// [overrides] runs after every registration and before anything is resolved,
/// so it can swap any registration with `unregister` and `register...`
/// without editing this file.
GetIt createAppLandingLocator({
  AppContentDataSource? contentDataSource,
  DownloadLinkService? linkService,
  void Function(GetIt locator)? overrides,
}) {
  final GetIt g = GetIt.asNewInstance();

  // Data sources.
  g
    ..registerLazySingleton<AppContentDataSource>(
      () => contentDataSource ?? const InMemoryAppContentDataSource(),
    )
    ..registerLazySingleton<DownloadLinkService>(
      () => linkService ?? InMemoryDownloadLinkService(),
    );

  // Repositories.
  g
    ..registerLazySingleton<SiteRepository>(() => SiteRepositoryImpl(g()))
    ..registerLazySingleton<HeroRepository>(() => HeroRepositoryImpl(g()))
    ..registerLazySingleton<TrustRepository>(() => TrustRepositoryImpl(g()))
    ..registerLazySingleton<FeaturesRepository>(
      () => FeaturesRepositoryImpl(g()),
    )
    ..registerLazySingleton<HowItWorksRepository>(
      () => HowItWorksRepositoryImpl(g()),
    )
    ..registerLazySingleton<GalleryRepository>(() => GalleryRepositoryImpl(g()))
    ..registerLazySingleton<StatsRepository>(() => StatsRepositoryImpl(g()))
    ..registerLazySingleton<ReviewsRepository>(() => ReviewsRepositoryImpl(g()))
    ..registerLazySingleton<PricingRepository>(() => PricingRepositoryImpl(g()))
    ..registerLazySingleton<FaqRepository>(() => FaqRepositoryImpl(g()))
    ..registerLazySingleton<DownloadRepository>(
      () => DownloadRepositoryImpl(g(), g()),
    )
    ..registerLazySingleton<FooterRepository>(() => FooterRepositoryImpl(g()));

  // Use cases.
  g
    ..registerFactory<GetSiteInfo>(() => GetSiteInfo(g()))
    ..registerFactory<GetHero>(() => GetHero(g()))
    ..registerFactory<GetTrust>(() => GetTrust(g()))
    ..registerFactory<GetFeatures>(() => GetFeatures(g()))
    ..registerFactory<GetHowItWorks>(() => GetHowItWorks(g()))
    ..registerFactory<GetGallery>(() => GetGallery(g()))
    ..registerFactory<GetStats>(() => GetStats(g()))
    ..registerFactory<GetReviews>(() => GetReviews(g()))
    ..registerFactory<GetPricing>(() => GetPricing(g()))
    ..registerFactory<CalculatePrice>(CalculatePrice.new)
    ..registerFactory<GetFaq>(() => GetFaq(g()))
    ..registerFactory<GetDownload>(() => GetDownload(g()))
    ..registerFactory<ValidateContact>(ValidateContact.new)
    ..registerFactory<SendDownloadLink>(() => SendDownloadLink(g(), g()))
    ..registerFactory<BuildQrPattern>(BuildQrPattern.new)
    ..registerFactory<GetFooter>(() => GetFooter(g()));

  // Session cubits.
  g
    ..registerLazySingleton<AppLandingNavigationCubit>(
      AppLandingNavigationCubit.new,
      dispose: (AppLandingNavigationCubit c) => c.close(),
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
    ..registerFactory<ContentViewModel<TrustContent>>(
      () => ContentViewModel<TrustContent>(
        ContentCubit<TrustContent>(g<GetTrust>().call),
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
    ..registerFactory<ContentViewModel<ReviewsContent>>(
      () => ContentViewModel<ReviewsContent>(
        ContentCubit<ReviewsContent>(g<GetReviews>().call),
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
    ..registerFactory<FeaturesViewModel>(
      () => FeaturesViewModel(FeaturesCubit(g())),
    )
    ..registerFactory<GalleryViewModel>(
      () => GalleryViewModel(GalleryCubit(g())),
    )
    ..registerFactory<PricingViewModel>(
      () => PricingViewModel(PricingCubit(g(), g())),
    )
    ..registerFactory<DownloadViewModel>(
      () => DownloadViewModel(DownloadCubit(g(), g(), g())),
    );

  overrides?.call(g);

  return g;
}
