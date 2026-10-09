import 'package:get_it/get_it.dart';

import '../../../data/cart/remote/cart_remote_data_source.dart';
import '../../../data/cart/repositories/cart_repository_impl.dart';
import '../../../data/catalog/remote/product_remote_data_source.dart';
import '../../../data/catalog/repositories/product_repository_impl.dart';
import '../../../data/orders/remote/order_remote_data_source.dart';
import '../../../data/orders/repositories/order_repository_impl.dart';
import '../../../data/profile/remote/profile_remote_data_source.dart';
import '../../../data/profile/repositories/profile_repository_impl.dart';
import '../../../data/saved/remote/saved_remote_data_source.dart';
import '../../../data/saved/repositories/saved_repository_impl.dart';
import '../../../domain/cart/repositories/cart_repository.dart';
import '../../../domain/cart/use_cases/add_to_cart.dart';
import '../../../domain/cart/use_cases/apply_promo_code.dart';
import '../../../domain/cart/use_cases/calculate_cart_totals.dart';
import '../../../domain/cart/use_cases/get_cart.dart';
import '../../../domain/cart/use_cases/remove_promo_code.dart';
import '../../../domain/cart/use_cases/set_cart_quantity.dart';
import '../../../domain/catalog/repositories/product_repository.dart';
import '../../../domain/catalog/use_cases/filter_products.dart';
import '../../../domain/catalog/use_cases/get_product_by_id.dart';
import '../../../domain/catalog/use_cases/get_products.dart';
import '../../../domain/catalog/use_cases/recommend_products.dart';
import '../../../domain/catalog/use_cases/sort_products.dart';
import '../../../domain/checkout/use_cases/place_order.dart';
import '../../../domain/checkout/use_cases/validate_payment_details.dart';
import '../../../domain/checkout/use_cases/validate_shipping_details.dart';
import '../../../domain/orders/repositories/order_repository.dart';
import '../../../domain/orders/use_cases/get_orders.dart';
import '../../../domain/orders/use_cases/get_saved_addresses.dart';
import '../../../domain/profile/repositories/profile_repository.dart';
import '../../../domain/profile/use_cases/get_account.dart';
import '../../../domain/profile/use_cases/get_preferences.dart';
import '../../../domain/profile/use_cases/save_preferences.dart';
import '../../../domain/profile/use_cases/sign_in.dart';
import '../../../domain/profile/use_cases/sign_out.dart';
import '../../../domain/saved/repositories/saved_repository.dart';
import '../../../domain/saved/use_cases/get_saved_ids.dart';
import '../../../domain/saved/use_cases/get_saved_products.dart';
import '../../../domain/saved/use_cases/toggle_saved.dart';
import '../../../presentation/cart/bloc/cart_cubit.dart';
import '../../../presentation/catalog/bloc/catalog_cubit.dart';
import '../../../presentation/catalog/bloc/product_detail_cubit.dart';
import '../../../presentation/catalog/bloc/suggestions_cubit.dart';
import '../../../presentation/catalog/view_models/product_detail_view_model.dart';
import '../../../presentation/catalog/view_models/suggestions_view_model.dart';
import '../../../presentation/checkout/bloc/checkout_cubit.dart';
import '../../../presentation/orders/bloc/orders_cubit.dart';
import '../../../presentation/profile/bloc/profile_cubit.dart';
import '../../../presentation/saved/bloc/saved_cubit.dart';
import '../../presentation/navigation/shop_navigation_cubit.dart';

/// Builds a fresh dependency container for one mount of the template.
///
/// Registration is explicit rather than generated, so the template needs no
/// `build_runner` step. The scopes follow one rule:
///
/// * data sources, repositories: lazy singletons, one per session;
/// * use cases: factories (they are stateless and free to build);
/// * **session cubits** (navigation, catalogue, saved, cart, checkout, orders,
///   profile): lazy singletons, provided to the tree once and never closed by
///   a view model;
/// * **screen cubits** (product page, suggestions): created and closed by their
///   view model, which is a factory.
///
/// [catalogLatency] is how long the in-memory catalogue takes to answer; keep
/// it at zero in tests, give it a few hundred milliseconds to see the
/// storefront's skeletons.
GetIt createShopLocator({Duration catalogLatency = Duration.zero}) {
  final GetIt g = GetIt.asNewInstance();

  // Data sources. Replace these with ones that call your backend.
  g
    ..registerLazySingleton<ProductRemoteDataSource>(
      () => InMemoryProductRemoteDataSource(latency: catalogLatency),
    )
    ..registerLazySingleton<SavedRemoteDataSource>(
      InMemorySavedRemoteDataSource.new,
    )
    ..registerLazySingleton<CartRemoteDataSource>(
      InMemoryCartRemoteDataSource.new,
    )
    ..registerLazySingleton<OrderRemoteDataSource>(
      InMemoryOrderRemoteDataSource.new,
    )
    ..registerLazySingleton<ProfileRemoteDataSource>(
      InMemoryProfileRemoteDataSource.new,
    );

  // Repositories.
  g
    ..registerLazySingleton<ProductRepository>(() => ProductRepositoryImpl(g()))
    ..registerLazySingleton<SavedRepository>(() => SavedRepositoryImpl(g()))
    ..registerLazySingleton<CartRepository>(() => CartRepositoryImpl(g(), g()))
    ..registerLazySingleton<OrderRepository>(
      () => OrderRepositoryImpl(g(), g()),
    )
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(g()),
    );

  // Use cases.
  g
    ..registerFactory<GetProducts>(() => GetProducts(g()))
    ..registerFactory<GetProductById>(() => GetProductById(g()))
    ..registerFactory<FilterProducts>(FilterProducts.new)
    ..registerFactory<SortProducts>(SortProducts.new)
    ..registerFactory<RecommendProducts>(RecommendProducts.new)
    ..registerFactory<GetSavedIds>(() => GetSavedIds(g()))
    ..registerFactory<ToggleSaved>(() => ToggleSaved(g()))
    ..registerFactory<GetSavedProducts>(() => GetSavedProducts(g()))
    ..registerFactory<GetCart>(() => GetCart(g()))
    ..registerFactory<AddToCart>(() => AddToCart(g()))
    ..registerFactory<SetCartQuantity>(() => SetCartQuantity(g()))
    ..registerFactory<ApplyPromoCode>(() => ApplyPromoCode(g()))
    ..registerFactory<RemovePromoCode>(() => RemovePromoCode(g()))
    ..registerFactory<CalculateCartTotals>(CalculateCartTotals.new)
    ..registerFactory<ValidateShippingDetails>(ValidateShippingDetails.new)
    ..registerFactory<ValidatePaymentDetails>(ValidatePaymentDetails.new)
    ..registerFactory<PlaceOrder>(() => PlaceOrder(g(), g(), g()))
    ..registerFactory<GetOrders>(() => GetOrders(g()))
    ..registerFactory<GetSavedAddresses>(GetSavedAddresses.new)
    ..registerFactory<GetAccount>(() => GetAccount(g()))
    ..registerFactory<SignIn>(() => SignIn(g()))
    ..registerFactory<SignOut>(() => SignOut(g()))
    ..registerFactory<GetPreferences>(() => GetPreferences(g()))
    ..registerFactory<SavePreferences>(() => SavePreferences(g()));

  // Session cubits.
  g
    ..registerLazySingleton<ShopNavigationCubit>(
      ShopNavigationCubit.new,
      dispose: (ShopNavigationCubit c) => c.close(),
    )
    ..registerLazySingleton<CatalogCubit>(
      () => CatalogCubit(g(), g(), g()),
      dispose: (CatalogCubit c) => c.close(),
    )
    ..registerLazySingleton<SavedCubit>(
      () => SavedCubit(g(), g(), g()),
      dispose: (SavedCubit c) => c.close(),
    )
    ..registerLazySingleton<CartCubit>(
      () => CartCubit(g(), g(), g(), g(), g(), g()),
      dispose: (CartCubit c) => c.close(),
    )
    ..registerLazySingleton<CheckoutCubit>(
      () => CheckoutCubit(g(), g(), g()),
      dispose: (CheckoutCubit c) => c.close(),
    )
    ..registerLazySingleton<OrdersCubit>(
      () => OrdersCubit(g(), g()),
      dispose: (OrdersCubit c) => c.close(),
    )
    ..registerLazySingleton<ProfileCubit>(
      () => ProfileCubit(g(), g(), g(), g(), g()),
      dispose: (ProfileCubit c) => c.close(),
    );

  // Screen view models; each creates and owns its own cubit.
  g
    ..registerFactory<ProductDetailViewModel>(
      () => ProductDetailViewModel(ProductDetailCubit(g(), g(), g())),
    )
    ..registerFactory<SuggestionsViewModel>(
      () => SuggestionsViewModel(SuggestionsCubit(g(), g())),
    );

  return g;
}
