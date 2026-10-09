import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/constants/product_categories.dart';
import '../../../common/constants/promo_slides.dart';
import '../../../core/presentation/navigation/shop_navigation_cubit.dart';
import '../../../core/presentation/shop_text.dart';
import '../../../core/presentation/widgets/section_header.dart';
import '../../../core/presentation/widgets/tap_target.dart';
import '../../cart/bloc/cart_cubit.dart';
import '../../profile/bloc/profile_cubit.dart';
import '../bloc/catalog_cubit.dart';
import '../bloc/catalog_state.dart';
import '../widgets/category_chips.dart';
import '../widgets/product_grid.dart';
import '../widgets/product_row.dart';
import '../widgets/promo_banner.dart';
import '../widgets/sort_select.dart';
import '../widgets/storefront_skeleton.dart';

/// The storefront: header, search, promotions, categories and products.
///
/// By default it shows curated sections (Featured, New arrivals, All
/// products). As soon as the shopper searches or picks a category it shows one
/// results grid instead.
class StorefrontView extends StatefulWidget {
  /// Creates the view.
  const StorefrontView({super.key});

  @override
  State<StorefrontView> createState() => _StorefrontViewState();
}

class _StorefrontViewState extends State<StorefrontView> {
  late final TextEditingController _search = TextEditingController(
    text: context.read<CatalogCubit>().state.query,
  );

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final CatalogCubit cubit = context.read<CatalogCubit>();
    return BlocConsumer<CatalogCubit, CatalogState>(
      // Keep the search box in step when the filters are cleared elsewhere.
      listenWhen: (CatalogState a, CatalogState b) => a.query != b.query,
      listener: (BuildContext context, CatalogState state) {
        if (_search.text != state.query) _search.text = state.query;
      },
      builder: (BuildContext context, CatalogState state) {
        const Widget gap14 = SizedBox(height: 14);
        const EdgeInsets side = EdgeInsets.symmetric(horizontal: 16);
        return ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          children: <Widget>[
            const Padding(padding: side, child: _Header()),
            gap14,
            Padding(
              padding: side,
              child: CairnInput(
                controller: _search,
                placeholder: 'Search products',
                semanticLabel: 'Search products',
                textInputAction: TextInputAction.search,
                leading: Icon(
                  Icons.search,
                  size: 16,
                  color: theme.mutedForeground,
                ),
                onChanged: cubit.search,
              ),
            ),
            gap14,
            if (state.loading)
              const StorefrontBannerSkeleton()
            else
              PromoBanner(
                onSelect: (PromoSlide slide) =>
                    cubit.selectCategory(slide.category),
              ),
            gap14,
            CategoryChips(
              selected: state.category,
              onSelected: cubit.selectCategory,
            ),
            const SizedBox(height: 18),
            if (state.status == CatalogStatus.loading)
              const StorefrontGridSkeleton()
            else if (state.status == CatalogStatus.failed)
              Padding(
                padding: side,
                child: _LoadFailed(onRetry: cubit.load),
              )
            else if (state.isFiltering)
              _Results(state: state)
            else
              _Sections(state: state),
          ],
        );
      },
    );
  }
}

class _Sections extends StatelessWidget {
  const _Sections({required this.state});

  final CatalogState state;

  @override
  Widget build(BuildContext context) {
    const EdgeInsets side = EdgeInsets.symmetric(horizontal: 16);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(padding: side, child: SectionHeader('Featured')),
        const SizedBox(height: 12),
        ProductRow(products: state.featured, tileWidth: 176, aspectRatio: 0.92),
        if (state.newArrivals.isNotEmpty) ...<Widget>[
          const SizedBox(height: 24),
          const Padding(padding: side, child: SectionHeader('New arrivals')),
          const SizedBox(height: 12),
          Padding(
            padding: side,
            child: ProductGrid(products: state.newArrivals),
          ),
        ],
        const SizedBox(height: 24),
        Padding(
          padding: side,
          child: _SortedHeader(title: 'All products', state: state),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: side,
          child: ProductGrid(products: state.visible),
        ),
      ],
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({required this.state});

  final CatalogState state;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final int n = state.visible.length;
    final String title = n == 1 ? '1 result' : '$n results';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SortedHeader(title: title, state: state),
          const SizedBox(height: 12),
          if (state.visible.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: <Widget>[
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.muted,
                    ),
                    child: Icon(Icons.search_off, color: theme.mutedForeground),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Nothing matches',
                    style: shopText(
                      theme,
                      theme.textStyle(CairnTypography.base),
                      weight: CairnTypography.semibold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.category == ProductCategories.all
                        ? 'Nothing matches "${state.query.trim()}". Try '
                              'another word, or clear the search.'
                        : 'Nothing in ${state.category} matches that. Try '
                              'another word, or clear the filters.',
                    textAlign: TextAlign.center,
                    style: shopText(
                      theme,
                      theme.textStyle(CairnTypography.sm),
                      color: theme.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 14),
                  CairnButton(
                    size: CairnButtonSize.sm,
                    variant: CairnButtonVariant.outline,
                    onPressed: context.read<CatalogCubit>().clearFilters,
                    child: const Text('Clear filters'),
                  ),
                ],
              ),
            )
          else
            ProductGrid(products: state.visible),
        ],
      ),
    );
  }
}

class _SortedHeader extends StatelessWidget {
  const _SortedHeader({required this.title, required this.state});

  final String title;
  final CatalogState state;

  @override
  Widget build(BuildContext context) => SectionHeader(
    title,
    trailing: state.visible.length < 2
        ? null
        : SortSelect(
            value: state.sort,
            onChanged: context.read<CatalogCubit>().sortBy,
          ),
  );
}

class _LoadFailed extends StatelessWidget {
  const _LoadFailed({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 12,
    children: <Widget>[
      const CairnAlert(
        variant: CairnAlertVariant.destructive,
        icon: Icon(Icons.error_outline),
        title: Text('We could not load the shop'),
        description: Text('Check your connection and try again.'),
      ),
      CairnButton(
        size: CairnButtonSize.sm,
        onPressed: onRetry,
        child: const Text('Try again'),
      ),
    ],
  );
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final String? first = context.select(
      (ProfileCubit c) => c.state.account?.firstName,
    );
    final String? initials = context.select(
      (ProfileCubit c) => c.state.account?.initials,
    );
    final int count = context.select((CartCubit c) => c.state.itemCount);
    return Row(
      spacing: 8,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                first == null ? 'Welcome to Cairn' : 'Welcome back, $first',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: shopText(
                  theme,
                  theme.textStyle(CairnTypography.xs),
                  color: theme.mutedForeground,
                ),
              ),
              Text(
                'Discover',
                style: shopText(
                  theme,
                  theme.textStyle(CairnTypography.xl2),
                  weight: CairnTypography.semibold,
                ),
              ),
            ],
          ),
        ),
        CairnIndicator(
          indicator: count == 0
              ? const SizedBox.shrink()
              : CairnBadge(
                  variant: CairnBadgeVariant.destructive,
                  label: Text('$count'),
                ),
          child: CairnButton.icon(
            variant: CairnButtonVariant.outline,
            size: CairnButtonSize.iconMd,
            icon: const Icon(Icons.shopping_bag_outlined, size: 18),
            semanticLabel: count == 0
                ? 'Cart, empty'
                : 'Cart, $count ${count == 1 ? 'item' : 'items'}',
            onPressed: () =>
                context.read<ShopNavigationCubit>().selectTab(ShopTab.cart),
          ),
        ),
        TapTarget(
          semanticLabel: 'Profile',
          onTap: () =>
              context.read<ShopNavigationCubit>().selectTab(ShopTab.profile),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: CairnAvatar(
                fallback: initials == null
                    ? const Icon(Icons.person_outline, size: 18)
                    : Text(initials),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
