library;

import '../../common/constants.dart';
import '../../common/utils/money.dart';
import '../../common/utils/slug.dart';
import '../../common/utils/text.dart';
import '../../core/config/brand.dart';
import '../../core/seo/seo_data.dart';
import '../../di/service_locator.dart';
import '../../domain/catalog/models/product.dart';
import '../../domain/catalog/models/product_query.dart';
import '../../domain/catalog/use_cases/product_lookup.dart';
import '../../http/reply.dart';
import '../../http/request_info.dart';
import '../components/navigation.dart';
import '../seo/structured_data.dart';
import 'listing_page.dart';
import 'listing_params.dart';
import 'product_page.dart';

/// Product listing, category pages and product detail.
///
/// SEO rules implemented here (each has a test in `test/server/`):
///  * `/products?category=x` -> 301 `/categories/x` (one URL per category).
///  * Non-canonical spellings (`?page=1`, `?sort=featured`, `?q=`) -> 301.
///  * A page past the last one -> 404.
///  * Search results (`?q=`) -> `noindex, follow`: unbounded query space with
///    thin, duplicate content. Everything else stays indexable.
///  * Sorted variants stay indexable but canonicalise to the unsorted URL, so
///    ranking signals consolidate without a noindex/canonical conflict.
///  * Page 2+ are self-canonical with `rel=prev/next`: the products on them are
///    otherwise unreachable for a crawler, so folding them into page 1 would
///    hide part of the catalogue.
class CatalogController {
  CatalogController(this.deps);
  final StoreDeps deps;

  Future<Reply> products(RequestInfo r) async {
    // Legacy filter URL: /products?category=audio -> /categories/audio
    final legacy = r.query['category'];
    if (legacy != null) {
      final params = ListingParams.parse(r.query);
      final exists = (await deps.getCategories()).any((c) => c.slug == legacy);
      final base = exists ? '/categories/$legacy' : '/products';
      return RedirectReply(listingUrl(base, q: params.q, sort: params.sort, page: params.page), status: 301);
    }
    return _listing(r, basePath: '/products');
  }

  Future<Reply> category(RequestInfo r, String slug) async {
    if (!isValidSlug(slug)) return notFound(r);
    final categories = await deps.getCategories();
    final category = categories.where((c) => c.slug == slug).firstOrNull;
    if (category == null) return notFound(r);
    return _listing(r, basePath: '/categories/$slug', category: category);
  }

  Future<Reply> _listing(RequestInfo r, {required String basePath, Category? category}) async {
    final params = ListingParams.parse(r.query);
    if (params.needsRedirect) {
      return RedirectReply(listingUrl(basePath, q: params.q, sort: params.sort, page: params.page), status: 301);
    }
    final categories = await deps.getCategories();
    final listing = await deps.queryProducts(
      ProductQuery(
        categorySlug: category?.slug,
        search: params.q,
        sort: params.sort,
        page: params.page,
        pageSize: kProductsPerPage,
      ),
    );
    if (listing.pageOutOfRange) return notFound(r);

    final canonicalSort = params.hasSearch ? params.sort : ProductSort.defaultSort;
    final selfPath = listingUrl(basePath, q: params.q, sort: params.sort, page: params.page);
    final canonicalPath = listingUrl(basePath, q: params.q, sort: canonicalSort, page: params.page);
    final robots = params.hasSearch ? RobotsPolicy.noIndexFollow : RobotsPolicy.indexed;

    final crumbs = [
      const Crumb('Home', '/'),
      if (category != null) ...[const Crumb('Shop', '/products'), Crumb(category.name)] else const Crumb('Shop'),
    ];

    final pageSuffix = listing.page > 1 ? ', page ${listing.page}' : '';
    final String heading;
    final String title;
    final String description;
    if (params.hasSearch) {
      heading = 'Results for "${params.q}"';
      title = 'Search: ${params.q}$pageSuffix';
      description =
          '${listing.total} ${pluralize(listing.total, 'result')} for "${params.q}" at ${Brand.name}. '
          'Free shipping over ${formatMoney(deps.config.shipping.freeThresholdCents, currency: deps.config.currency)}.';
    } else if (category != null) {
      heading = category.name;
      title = '${category.name}${category.headline == null ? '' : ': ${category.headline}'}$pageSuffix';
      description =
          '${category.description} Shop ${listing.total} ${pluralize(listing.total, 'product')}.'
          '${listing.page > 1 ? ' Page ${listing.page} of ${listing.pageCount}.' : ''}';
    } else {
      heading = 'All products';
      title = 'Shop all products$pageSuffix';
      description =
          'Browse every ${Brand.name} product: sneakers, headphones, watches, bags and desk essentials. '
          '${listing.total} ${pluralize(listing.total, 'item')}, free shipping over '
          '${formatMoney(deps.config.shipping.freeThresholdCents, currency: deps.config.currency)}.'
          '${listing.page > 1 ? ' Page ${listing.page} of ${listing.pageCount}.' : ''}';
    }

    String pageUrl(int p) => listingUrl(basePath, q: params.q, sort: params.sort, page: p);
    final seo = SeoData(
      title: title,
      description: description,
      path: canonicalPath,
      robots: robots,
      imagePath: category?.image.fallbackUrl,
      imageAlt: category?.image.alt,
      imageWidth: category?.image.width,
      imageHeight: category?.image.height,
      prevPath: listing.hasPrev ? pageUrl(listing.page - 1) : null,
      nextPath: listing.hasNext ? pageUrl(listing.page + 1) : null,
      jsonLd: [
        breadcrumbLd(deps.config, crumbs, currentPath: selfPath),
        if (!listing.isEmpty)
          itemListLd(
            deps.config,
            listing.items,
            startPosition: listing.firstIndex,
            name: heading,
          ),
      ],
    );

    return PageReply(
      seo: seo,
      body: ListingPage(
        config: deps.config,
        listing: listing,
        categories: categories,
        basePath: basePath,
        heading: heading,
        intro: params.hasSearch ? null : category?.description,
        category: category,
        crumbs: crumbs,
      ),
    );
  }

  Future<Reply> product(RequestInfo r, String slug) async {
    if (!isValidSlug(slug)) return notFound(r);
    final resolution = await deps.resolveSlug(slug);
    switch (resolution) {
      case SlugNotFound():
        return notFound(r);
      case SlugMoved(:final product):
        // A renamed product keeps its search ranking through a permanent redirect.
        return RedirectReply('/products/${product.slug}', status: 301);
      case SlugFound(:final product):
        return _productPage(r, product);
    }
  }

  Future<Reply> _productPage(RequestInfo r, Product product) async {
    final categories = await deps.getCategories();
    final category = categories.where((c) => c.slug == product.categorySlug).firstOrNull;
    final reviews = await deps.getReviews(product.id);
    final related = await deps.getRelated(product);
    final crumbs = [
      const Crumb('Home', '/'),
      const Crumb('Shop', '/products'),
      if (category != null) Crumb(category.name, '/categories/${category.slug}'),
      Crumb(product.name),
    ];
    final path = '/products/${product.slug}';
    final image = product.primaryImage;
    final seo = SeoData(
      title: product.name,
      description:
          '${product.summary} ${formatMoney(product.priceCents, currency: deps.config.currency)}, '
          '${product.availability.label.toLowerCase()}.',
      path: path,
      ogType: 'product',
      imagePath: image.fallbackUrl,
      imageAlt: image.alt,
      imageWidth: image.width,
      imageHeight: image.height,
      preloadImage: PreloadImage(
        srcset: image.srcset,
        sizes: '(min-width: 64rem) 48vw, 100vw',
        fallbackUrl: image.fallbackUrl,
      ),
      openGraph: {
        'product:price:amount': decimalAmount(product.priceCents),
        'product:price:currency': deps.config.currency,
        'product:availability': product.inStock ? 'in stock' : 'out of stock',
        'product:brand': product.brand,
        'product:condition': 'new',
        'product:retailer_item_id': product.sku,
        'product:category': ?category?.name,
      },
      jsonLd: [
        breadcrumbLd(deps.config, crumbs, currentPath: path),
        productLd(deps.config, product, reviews: reviews, now: deps.clock(), categoryName: category?.name),
      ],
    );
    return PageReply(
      seo: seo,
      body: ProductPage(
        config: deps.config,
        product: product,
        category: category,
        reviews: reviews,
        related: related,
        crumbs: crumbs,
        errorCode: r.query['error'],
        selectedVariantId: r.query['variant'],
      ),
    );
  }

  /// The real 404: the app renders the 404 page and sets the status.
  Reply notFound(RequestInfo r) => const NotFoundReply();
}
