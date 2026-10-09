import '../../../core/presentation/view_model.dart';
import '../bloc/thread_cubit.dart';

/// Owns the [ThreadCubit] of one open conversation and closes it with the
/// screen.
class ThreadViewModel implements ViewModel {
  /// Creates the view model.
  ThreadViewModel(this.cubit);

  /// The thread's state.
  final ThreadCubit cubit;

  @override
  void dispose() => cubit.close();
}
