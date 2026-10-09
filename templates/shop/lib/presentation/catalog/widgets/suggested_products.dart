import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/view_model.dart';
import '../../../core/presentation/widgets/section_header.dart';
import '../../../domain/catalog/models/product.dart';
import '../bloc/suggestions_cubit.dart';
import '../view_models/suggestions_view_model.dart';
import 'product_row.dart';

/// A titled row of suggested products, for screens with nothing else to show.
class SuggestedProducts extends StatelessWidget {
  /// Creates the row.
  const SuggestedProducts({
    super.key,
    this.title = 'You might like',
    this.exclude = const <String>{},
  });

  /// The heading.
  final String title;

  /// Product ids to leave out.
  final Set<String> exclude;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SuggestionsViewModel>(
      onCreate: (BuildContext context, SuggestionsViewModel vm) =>
          vm.cubit.load(exclude: exclude),
      builder: (BuildContext context, SuggestionsViewModel vm) =>
          BlocBuilder<SuggestionsCubit, List<Product>>(
            bloc: vm.cubit,
            builder: (BuildContext context, List<Product> products) {
              if (products.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SectionHeader(title),
                  const SizedBox(height: 12),
                  ProductRow(
                    products: products,
                    tileWidth: 136,
                    padding: EdgeInsets.zero,
                  ),
                ],
              );
            },
          ),
    );
  }
}
