import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/utils/money.dart';
import '../../../core/presentation/navigation/shop_navigation_cubit.dart';
import '../../../core/presentation/shop_text.dart';
import '../../../core/presentation/view_model.dart';
import '../../../core/presentation/widgets/product_photo.dart';
import '../../../domain/catalog/models/product.dart';
import '../../cart/bloc/cart_cubit.dart';
import '../../saved/widgets/save_button.dart';
import '../bloc/product_detail_cubit.dart';
import '../view_models/product_detail_view_model.dart';

/// A product page: photo, details, option picker and a sticky buy bar.
class ProductDetailView extends StatelessWidget {
  /// Creates the view.
  const ProductDetailView({super.key, required this.productId});

  /// Which product to show.
  final String productId;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ProductDetailViewModel>(
      onCreate: (BuildContext context, ProductDetailViewModel vm) =>
          vm.cubit.load(productId),
      builder: (BuildContext context, ProductDetailViewModel vm) =>
          BlocBuilder<ProductDetailCubit, ProductDetailState>(
            bloc: vm.cubit,
            builder: (BuildContext context, ProductDetailState state) {
              final Product? product = state.product;
              if (product == null) {
                return const Center(child: CairnSpinner());
              }
              return _Content(
                product: product,
                option: state.option ?? product.options.first,
                onOption: vm.cubit.selectOption,
              );
            },
          ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.product,
    required this.option,
    required this.onOption,
  });

  final Product product;
  final String option;
  final ValueChanged<String> onOption;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final int inCart = context.select(
      (CartCubit c) => c.state.quantityOf(product.id),
    );

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 16, 4),
          child: Row(
            children: <Widget>[
              CairnButton.icon(
                variant: CairnButtonVariant.ghost,
                icon: const CairnIcon(CairnIconData.chevronLeft),
                semanticLabel: 'Back',
                onPressed: () => context.read<ShopNavigationCubit>().back(),
              ),
              Expanded(
                child: Text(
                  product.category,
                  style: shopText(
                    theme,
                    theme.textStyle(CairnTypography.sm),
                    color: theme.mutedForeground,
                  ),
                ),
              ),
              SaveButton(productId: product.id),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            children: <Widget>[
              AspectRatio(
                aspectRatio: 1,
                child: ProductPhoto(
                  product.imageAsset,
                  radius: theme.radiusScale.xl,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                product.name,
                style: shopText(
                  theme,
                  theme.textStyle(CairnTypography.xl),
                  weight: CairnTypography.semibold,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                spacing: 8,
                children: <Widget>[
                  CairnRating(value: product.rating, size: 14),
                  Text(
                    '${product.rating.toStringAsFixed(1)} · '
                    '${product.reviews} reviews',
                    style: shopText(
                      theme,
                      theme.textStyle(CairnTypography.xs),
                      color: theme.mutedForeground,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                product.description,
                style: shopText(
                  theme,
                  theme.textStyle(CairnTypography.sm),
                  color: theme.mutedForeground,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                product.optionLabel,
                style: shopText(
                  theme,
                  theme.textStyle(CairnTypography.sm),
                  weight: CairnTypography.medium,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: CairnToggleGroup<String>(
                  type: CairnToggleGroupType.single,
                  variant: CairnToggleVariant.outline,
                  size: CairnToggleSize.sm,
                  semanticLabel: product.optionLabel,
                  values: <String>{option},
                  onChanged: (Set<String> v) {
                    if (v.isNotEmpty) onOption(v.first);
                  },
                  items: <CairnToggleGroupItem<String>>[
                    for (final String o in product.options)
                      CairnToggleGroupItem<String>(value: o, child: Text(o)),
                  ],
                ),
              ),
            ],
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: theme.border)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              spacing: 16,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Price',
                      style: shopText(
                        theme,
                        theme.textStyle(CairnTypography.xs),
                        color: theme.mutedForeground,
                      ),
                    ),
                    Text(
                      formatMoney(product.price),
                      style: shopText(
                        theme,
                        theme.textStyle(CairnTypography.lg),
                        weight: CairnTypography.semibold,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: CairnButton(
                    expand: true,
                    onPressed: () => context.read<CartCubit>().add(product.id),
                    leading: const Icon(Icons.add_shopping_cart, size: 16),
                    child: Text(
                      inCart == 0 ? 'Add to cart' : 'Add another ($inCart)',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
