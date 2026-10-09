library;

import '../../core/config/brand.dart';
import '../../core/result.dart';
import '../../core/seo/seo_data.dart';
import '../../di/service_locator.dart';
import '../../http/reply.dart';
import '../../http/request_info.dart';
import '../components/navigation.dart';
import '../seo/structured_data.dart';
import 'static_pages.dart';

class PagesController {
  PagesController(this.deps);
  final StoreDeps deps;

  Reply about(RequestInfo r) => PageReply(
    seo: SeoData(
      title: 'About ${Brand.name}',
      description:
          'Who we are and how we choose what to sell: well-made everyday objects, honest reviews, '
          'free 30-day returns and spare parts for years.',
      path: '/about',
      jsonLd: [
        breadcrumbLd(deps.config, const [Crumb('Home', '/'), Crumb('About')], currentPath: '/about'),
        organizationLd(deps.config),
      ],
    ),
    body: AboutPage(config: deps.config),
  );

  static const SeoData _newsletterSeo = SeoData(
    title: 'Newsletter',
    description: 'Subscribe to one short email a month with new arrivals, restocks and a repair tip.',
    path: '/newsletter',
    robots: RobotsPolicy.noIndexFollow,
  );

  Reply newsletterForm(RequestInfo r) {
    final status = r.query['status'];
    return PageReply(
      seo: _newsletterSeo,
      cache: CachePolicy.noStore,
      body: NewsletterPage(subscribed: status == 'ok' || status == 'exists', alreadySubscribed: status == 'exists'),
    );
  }

  Future<Reply> newsletterSubmit(RequestInfo r) async {
    final email = r.form['email'] ?? '';
    final result = await deps.subscribe(email);
    switch (result) {
      case Ok(:final value):
        deps.analytics.track('newsletter_subscribe');
        return RedirectReply('/newsletter?status=${value ? 'ok' : 'exists'}');
      case Err(:final failure):
        return PageReply(
          status: 422,
          seo: _newsletterSeo,
          cache: CachePolicy.noStore,
          body: NewsletterPage(
            email: email.trim().length > 254 ? '' : email.trim(),
            error: failure.fieldErrors['email'] ?? failure.message,
          ),
        );
    }
  }

  PageReply notFound(RequestInfo r) => const PageReply(
    status: 404,
    seo: SeoData(
      title: 'Page not found',
      description: 'We could not find the page you were looking for.',
      path: '/404',
      robots: RobotsPolicy.noIndexNoFollow,
    ),
    body: ErrorPage(
      status: 404,
      title: 'We could not find that page',
      message: 'The link may be broken, or the page may have moved. Try searching or browse the shop.',
    ),
  );

  PageReply serverError() => const PageReply(
    status: 500,
    cache: CachePolicy.noStore,
    seo: SeoData(
      title: 'Something went wrong',
      description: 'An unexpected error occurred.',
      path: '/500',
      robots: RobotsPolicy.noIndexNoFollow,
    ),
    body: ErrorPage(
      status: 500,
      title: 'Something went wrong',
      message: 'Sorry, that was our mistake. Please try again in a moment.',
    ),
  );
}
