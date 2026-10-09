import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

/// A thin coordinator between a screen and its cubit.
///
/// A view model owns what is scoped to one visit of a screen: it creates the
/// feature cubit, exposes it to the view, and closes it in [dispose]. Session
/// cubits (navigation, site) are never owned by a view model.
abstract interface class ViewModel {
  /// Releases anything the view model owns.
  void dispose();
}

/// Resolves a [ViewModel] from the template's container and disposes it when
/// the widget leaves the tree, so no screen knows how its dependencies are
/// built.
class ViewModelBuilder<T extends ViewModel> extends StatefulWidget {
  /// Creates a builder.
  const ViewModelBuilder({super.key, required this.builder, this.onCreate});

  /// Builds the screen from the resolved view model.
  final Widget Function(BuildContext context, T viewModel) builder;

  /// Called once, right after the view model is resolved.
  final void Function(BuildContext context, T viewModel)? onCreate;

  @override
  State<ViewModelBuilder<T>> createState() => _ViewModelBuilderState<T>();
}

class _ViewModelBuilderState<T extends ViewModel>
    extends State<ViewModelBuilder<T>> {
  late final T _viewModel = AppLandingScope.of(context).get<T>();

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

/// Makes the template's [GetIt] container available to the widget tree.
///
/// One container per mounted [AppLandingApp], not the global instance, so two
/// copies never share state.
class AppLandingScope extends InheritedWidget {
  /// Creates a scope.
  const AppLandingScope({
    super.key,
    required this.locator,
    required super.child,
  });

  /// The container for this template instance.
  final GetIt locator;

  /// The nearest container.
  static GetIt of(BuildContext context) {
    // Not a dependency: the container never changes for a mounted app, and
    // this is called from initState, where dependencies are not allowed.
    final AppLandingScope? scope = context
        .getInheritedWidgetOfExactType<AppLandingScope>();
    assert(scope != null, 'No AppLandingScope above this context.');
    return scope!.locator;
  }

  @override
  bool updateShouldNotify(AppLandingScope oldWidget) =>
      locator != oldWidget.locator;
}
