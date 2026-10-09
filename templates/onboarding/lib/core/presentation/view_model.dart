import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

/// A thin coordinator between a screen and its cubits.
///
/// A view model owns whatever is *scoped to one screen visit*: it creates the
/// feature cubit, exposes it to the view, and closes it in [dispose]. Cubits
/// that live for the whole session (the flow, navigation) are not owned by a
/// view model and must never be closed by one.
abstract interface class ViewModel {
  /// Releases anything the view model owns.
  void dispose();
}

/// Resolves a [ViewModel] from the template's container and disposes it when
/// the widget leaves the tree.
///
/// Views use this instead of reaching for the service locator themselves, so
/// no screen knows how its dependencies are built.
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
  late final T _viewModel = OnboardingScope.of(context).get<T>();

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
/// The container is created per `OnboardingApp` mount rather than being the
/// global instance, so two copies of the template (or a hot restart) never
/// share state or collide on registrations.
class OnboardingScope extends InheritedWidget {
  /// Creates a scope.
  const OnboardingScope({
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
    final OnboardingScope? scope = context
        .getInheritedWidgetOfExactType<OnboardingScope>();
    assert(scope != null, 'No OnboardingScope above this context.');
    return scope!.locator;
  }

  @override
  bool updateShouldNotify(OnboardingScope oldWidget) =>
      locator != oldWidget.locator;
}
