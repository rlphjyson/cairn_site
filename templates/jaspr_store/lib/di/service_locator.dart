/// Composition root.
///
/// This is the only file that names concrete implementations. Everything else
/// depends on interfaces from `lib/domain/` and receives its collaborators
/// through constructors. To move to a real backend you change the repository
/// registrations below and delete `lib/backend/`.
///
/// `get_it` is plain Dart (no widget tree, no Flutter), which is why it is used
/// instead of Provider/Riverpod: the same registration code runs in the server
/// process and in tests, each with its own [GetIt] instance.
library;

import 'package:get_it/get_it.dart';

import '../backend/cart_cookie.dart';
import '../backend/stores.dart';
import '../core/analytics/analytics.dart';
import '../core/config/store_config.dart';
import '../core/errors/error_reporter.dart';
import '../data/cart/cart_repository_impl.dart';
import '../data/catalog/catalog_repository_impl.dart';
import '../data/checkout/order_repository_impl.dart';
import '../data/newsletter/newsletter_repository_impl.dart';
import '../data/reviews/review_repository_impl.dart';
import '../domain/cart/cart_repository.dart';
import '../domain/cart/use_cases/cart_mutations.dart';
import '../domain/cart/use_cases/price_cart.dart';
import '../domain/catalog/catalog_repository.dart';
import '../domain/catalog/use_cases/product_lookup.dart';
import '../domain/catalog/use_cases/query_products.dart';
import '../domain/checkout/order_repository.dart';
import '../domain/checkout/use_cases/place_order.dart';
import '../domain/newsletter/newsletter.dart';
import '../domain/reviews/review_repository.dart';

/// The process-wide locator used by `main.server.dart`. Tests create their own
/// with `GetIt.asNewInstance()` so they never share state.
final GetIt services = GetIt.asNewInstance();

T locate<T extends Object>() => services.get<T>();

/// Registers everything on [locator] (default: [services]).
///
/// Idempotent: `jaspr serve` re-runs `main()` on every hot reload and
/// re-registering a singleton would throw.
void configureDependencies({
  required StoreConfig config,
  GetIt? locator,
  DemoBackend? backend,
  AnalyticsService? analytics,
  ErrorReporter? errorReporter,
}) {
  final l = locator ?? services;
  if (l.isRegistered<StoreConfig>()) return;

  final store = backend ?? DemoBackend(carts: CartStore(ttl: config.cartTtl));

  l
    ..registerSingleton<StoreConfig>(config)
    ..registerSingleton<AnalyticsService>(
      analytics ?? (config.analyticsEnabled ? ConsoleAnalytics(print) : const NoopAnalytics()),
    )
    ..registerSingleton<ErrorReporter>(errorReporter ?? const ConsoleErrorReporter())
    ..registerSingleton<DemoBackend>(store)
    ..registerSingleton<CartCookie>(
      CartCookie(secret: config.cartSecret, secure: config.secureCookies, maxAge: config.cartTtl),
    )
    // Repositories: swap these for database-backed implementations.
    ..registerSingleton<CatalogRepository>(CatalogRepositoryImpl(store.catalog, store.reviews))
    ..registerSingleton<ReviewRepository>(ReviewRepositoryImpl(store.reviews))
    ..registerSingleton<CartRepository>(CartRepositoryImpl(store.carts))
    ..registerSingleton<OrderRepository>(OrderRepositoryImpl(store.orders))
    ..registerSingleton<NewsletterRepository>(NewsletterRepositoryImpl(store.newsletter))
    // Use cases.
    ..registerLazySingleton<QueryProducts>(() => QueryProducts(l<CatalogRepository>()))
    ..registerLazySingleton<ResolveProductSlug>(() => ResolveProductSlug(l<CatalogRepository>()))
    ..registerLazySingleton<GetCategories>(() => GetCategories(l<CatalogRepository>()))
    ..registerLazySingleton<GetFeaturedProducts>(() => GetFeaturedProducts(l<CatalogRepository>()))
    ..registerLazySingleton<GetRelatedProducts>(() => GetRelatedProducts(l<CatalogRepository>()))
    ..registerLazySingleton<GetReviews>(() => GetReviews(l<ReviewRepository>()))
    ..registerLazySingleton<LoadCart>(() => LoadCart(l<CartRepository>()))
    ..registerLazySingleton<AddToCart>(() => AddToCart(l<CatalogRepository>(), l<CartRepository>()))
    ..registerLazySingleton<UpdateLineQuantity>(() => UpdateLineQuantity(l<CatalogRepository>(), l<CartRepository>()))
    ..registerLazySingleton<RemoveFromCart>(() => RemoveFromCart(l<CartRepository>()))
    ..registerLazySingleton<ApplyPromo>(() => ApplyPromo(l<StoreConfig>(), l<CartRepository>()))
    ..registerLazySingleton<ClearCart>(() => ClearCart(l<CartRepository>()))
    ..registerLazySingleton<PriceCart>(() => PriceCart(l<CatalogRepository>(), l<StoreConfig>()))
    ..registerLazySingleton<PlaceOrder>(
      () => PlaceOrder(priceCart: l<PriceCart>(), catalog: l<CatalogRepository>(), orders: l<OrderRepository>()),
    )
    ..registerLazySingleton<SubscribeToNewsletter>(() => SubscribeToNewsletter(l<NewsletterRepository>()));
}

/// Everything the HTTP layer needs, resolved once from the locator and handed to
/// controllers through their constructors.
class StoreDeps {
  StoreDeps(GetIt l, {DateTime Function()? clock})
    : config = l<StoreConfig>(),
      analytics = l<AnalyticsService>(),
      errors = l<ErrorReporter>(),
      cartCookie = l<CartCookie>(),
      catalog = l<CatalogRepository>(),
      orders = l<OrderRepository>(),
      queryProducts = l<QueryProducts>(),
      resolveSlug = l<ResolveProductSlug>(),
      getCategories = l<GetCategories>(),
      getFeatured = l<GetFeaturedProducts>(),
      getRelated = l<GetRelatedProducts>(),
      getReviews = l<GetReviews>(),
      loadCart = l<LoadCart>(),
      addToCart = l<AddToCart>(),
      updateQuantity = l<UpdateLineQuantity>(),
      removeFromCart = l<RemoveFromCart>(),
      applyPromo = l<ApplyPromo>(),
      clearCart = l<ClearCart>(),
      priceCart = l<PriceCart>(),
      placeOrder = l<PlaceOrder>(),
      subscribe = l<SubscribeToNewsletter>(),
      clock = clock ?? DateTime.now;

  final StoreConfig config;
  final AnalyticsService analytics;
  final ErrorReporter errors;
  final CartCookie cartCookie;
  final CatalogRepository catalog;
  final OrderRepository orders;
  final QueryProducts queryProducts;
  final ResolveProductSlug resolveSlug;
  final GetCategories getCategories;
  final GetFeaturedProducts getFeatured;
  final GetRelatedProducts getRelated;
  final GetReviews getReviews;
  final LoadCart loadCart;
  final AddToCart addToCart;
  final UpdateLineQuantity updateQuantity;
  final RemoveFromCart removeFromCart;
  final ApplyPromo applyPromo;
  final ClearCart clearCart;
  final PriceCart priceCart;
  final PlaceOrder placeOrder;
  final SubscribeToNewsletter subscribe;
  final DateTime Function() clock;
}
