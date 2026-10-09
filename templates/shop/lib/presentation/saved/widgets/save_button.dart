import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/saved_cubit.dart';

/// A heart button bound to the shopper's saved list.
class SaveButton extends StatelessWidget {
  /// Creates a button for [productId].
  const SaveButton({
    super.key,
    required this.productId,
    this.size = CairnButtonSize.iconSm,
  });

  /// The product this toggles.
  final String productId;

  /// The button's size.
  final CairnButtonSize size;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool saved = context.select(
      (SavedCubit c) => c.state.isSaved(productId),
    );
    return CairnButton.icon(
      size: size,
      variant: CairnButtonVariant.secondary,
      semanticLabel: saved ? 'Remove from saved' : 'Save',
      onPressed: () => context.read<SavedCubit>().toggle(productId),
      icon: Icon(
        saved ? Icons.favorite : Icons.favorite_border,
        size: 16,
        color: saved ? theme.destructive : theme.foreground,
      ),
    );
  }
}
