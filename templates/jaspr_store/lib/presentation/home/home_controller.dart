library;

import '../../core/config/brand.dart';
import '../../core/seo/seo_data.dart';
import '../../di/service_locator.dart';
import '../../domain/catalog/models/product_query.dart';
import '../../http/reply.dart';
import '../../http/request_info.dart';
import '../components/media.dart';
import '../seo/structured_data.dart';
import 'home_page.dart';

class HomeController {
  HomeController(this.deps);
  final StoreDeps deps;

  Future<Reply> home(RequestInfo r) async {
    final featured = await deps.getFeatured(limit: 4);
    final categories = await deps.getCategories();
    final all = (await deps.queryProducts(const ProductQuery(pageSize: 1000)));
    final counts = <String, int>{};
    for (final p in all.items) {
      counts[p.categorySlug] = (counts[p.categorySlug] ?? 0) + 1;
    }
    final seo = SeoData(
      title: '${Brand.name}: ${Brand.tagline}',
      fullTitle: true,
      description: Brand.description,
      path: '/',
      preloadImage: PreloadImage(
        srcset: HeroImage.srcset,
        sizes: HeroImage.sizes,
        fallbackUrl: '/images/hero/hero.jpg',
      ),
      jsonLd: [organizationLd(deps.config), websiteLd(deps.config)],
    );
    return PageReply(
      seo: seo,
      body: HomePage(config: deps.config, featured: featured, categories: categories, categoryCounts: counts),
    );
  }
}
