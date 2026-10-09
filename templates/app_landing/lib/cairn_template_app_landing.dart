/// The mobile app landing page template.
///
/// [AppLandingApp] is the entry point. The content and link-service interfaces
/// are exported too, so a host can serve the copy from a CMS and send real SMS
/// or email through `AppLandingApp(contentDataSource:, linkService:)` without
/// importing from `src`-style paths.
library;

export 'app_landing_app.dart';
export 'common/constants/content_sections.dart' show ContentSections;
export 'common/constants/section_ids.dart' show SectionIds;
export 'common/utils/json.dart' show JsonMap, JsonReader;
export 'core/infrastructure/di/app_landing_injection.dart'
    show createAppLandingLocator;
export 'core/presentation/view_model.dart' show AppLandingScope;
export 'data/content/remote/app_content_data_source.dart'
    show AppContentDataSource, InMemoryAppContentDataSource;
export 'data/download/remote/download_link_service.dart'
    show DownloadLinkService, InMemoryDownloadLinkService;
export 'domain/download/models/send_outcome.dart'
    show Contact, ContactKind, DownloadLinkException;
export 'domain/site/models/site_info.dart' show StoreKind;
