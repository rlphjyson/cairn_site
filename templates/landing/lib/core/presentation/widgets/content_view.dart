import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../content_cubit.dart';
import '../view_model.dart';

/// Resolves a section's [ContentViewModel], loads it, and builds the section
/// once the content is in.
///
/// While loading it reserves [loadingHeight] so the page does not jump; if
/// loading fails it offers a retry.
class ContentView<T extends Object> extends StatelessWidget {
  /// Creates a view.
  const ContentView({
    super.key,
    required this.builder,
    this.loadingHeight = 320,
  });

  /// Builds the section from its content.
  final Widget Function(BuildContext context, T data) builder;

  /// The height reserved before the content arrives.
  final double loadingHeight;

  @override
  Widget build(BuildContext context) => ViewModelBuilder<ContentViewModel<T>>(
    onCreate: (BuildContext _, ContentViewModel<T> vm) => vm.cubit.load(),
    builder: (BuildContext context, ContentViewModel<T> vm) =>
        BlocBuilder<ContentCubit<T>, ContentState<T>>(
          bloc: vm.cubit,
          builder: (BuildContext context, ContentState<T> state) {
            final T? data = state.data;
            if (data != null) return builder(context, data);
            if (state.status == ContentStatus.failure) {
              return SizedBox(
                height: loadingHeight,
                child: Center(
                  child: CairnButton(
                    variant: CairnButtonVariant.outline,
                    onPressed: vm.cubit.load,
                    child: const Text('Could not load this section. Retry'),
                  ),
                ),
              );
            }
            return SizedBox(height: loadingHeight);
          },
        ),
  );
}
