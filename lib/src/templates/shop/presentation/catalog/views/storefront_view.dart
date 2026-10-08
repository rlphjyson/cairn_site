import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/constants/product_categories.dart';
import '../../../core/presentation/shop_text.dart';
import '../../../core/presentation/view_model.dart';
import '../../profile/bloc/profile_cubit.dart';
import '../bloc/catalog_cubit.dart';
import '../bloc/catalog_state.dart';
import '../view_models/storefront_view_model.dart';
import '../widgets/category_chips.dart';
import '../widgets/product_grid.dart';
import '../widgets/promo_banner.dart';

/// The storefront: greeting, search, banner, categories and the grid.
class StorefrontView extends StatelessWidget {
  /// Creates the view.
  const StorefrontView({super.key});

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return ViewModelBuilder<StorefrontViewModel>(
      onCreate: (BuildContext context, StorefrontViewModel vm) =>
          vm.cubit.load(),
      builder: (BuildContext context, StorefrontViewModel vm) =>
          BlocBuilder<CatalogCubit, CatalogState>(
            bloc: vm.cubit,
            builder: (BuildContext context, CatalogState state) => ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              children: <Widget>[
                const _Header(),
                const SizedBox(height: 14),
                CairnInput(
                  placeholder: 'Search products',
                  semanticLabel: 'Search products',
                  leading: Icon(
                    Icons.search,
                    size: 16,
                    color: theme.mutedForeground,
                  ),
                  onChanged: vm.cubit.search,
                ),
                const SizedBox(height: 14),
                PromoBanner(onShop: () => vm.cubit.selectCategory('Shoes')),
                const SizedBox(height: 14),
                CategoryChips(
                  selected: state.category,
                  onSelected: vm.cubit.selectCategory,
                ),
                const SizedBox(height: 16),
                if (state.loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CairnSpinner()),
                  )
                else if (state.visible.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      state.category == ProductCategories.all
                          ? 'Nothing matches that search.'
                          : 'Nothing in ${state.category} matches that '
                                'search.',
                      textAlign: TextAlign.center,
                      style: shopText(
                        theme,
                        theme.textStyle(CairnTypography.sm),
                        color: theme.mutedForeground,
                      ),
                    ),
                  )
                else
                  ProductGrid(products: state.visible),
              ],
            ),
          ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final String first =
        context
            .select((ProfileCubit c) => c.state.account?.name)
            ?.split(' ')
            .first ??
        'there';
    final String initials =
        context.select((ProfileCubit c) => c.state.account?.initials) ?? '';
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Good morning, $first',
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
          indicator: const CairnStatus(tone: CairnTone.success, size: 9),
          placement: CairnIndicatorPlacement.bottomEnd,
          offset: const Offset(-2, -2),
          child: CairnAvatar(fallback: Text(initials)),
        ),
      ],
    );
  }
}
