import 'package:flutter/widgets.dart';

import 'auth_scope.dart';

/// A thin coordinator between a screen and its cubit.
///
/// A view model owns whatever is *scoped to one screen visit*: it creates the
/// screen's cubit, exposes it to the view, and closes it in [dispose]. Cubits
/// that live for the whole session (navigation, session) are not owned by a
/// view model and must never be closed by one.
abstract interface class ViewModel {
  /// Releases anything the view model owns.
  void dispose();
}

/// Resolves a [ViewModel] from the template's container and disposes it when
/// the widget leaves the tree.
///
/// Views use this instead of reaching for the service locator themselves, so
/// no screen knows how its dependencies are built. [param] is handed to the
/// factory registered for [T] (the destination the screen was opened with).
class ViewModelBuilder<T extends ViewModel> extends StatefulWidget {
  /// Creates a builder.
  const ViewModelBuilder({
    super.key,
    required this.builder,
    this.param,
    this.onCreate,
  });

  /// Builds the screen from the resolved view model.
  final Widget Function(BuildContext context, T viewModel) builder;

  /// The argument for the view model's factory.
  final Object? param;

  /// Called once, right after the view model is resolved.
  final void Function(BuildContext context, T viewModel)? onCreate;

  @override
  State<ViewModelBuilder<T>> createState() => _ViewModelBuilderState<T>();
}

class _ViewModelBuilderState<T extends ViewModel>
    extends State<ViewModelBuilder<T>> {
  late final T _viewModel = AuthScope.of(context).get<T>(param1: widget.param);

  @override
  void initState() {
    super.initState();
    widget.onCreate?.call(context, _viewModel);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _viewModel);
}
