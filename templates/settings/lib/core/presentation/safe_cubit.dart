import 'package:flutter_bloc/flutter_bloc.dart';

/// A [Cubit] that ignores `emit` once it is closed.
///
/// Screen cubits are closed when their screen goes, and a request that was
/// still in flight when that happened would otherwise throw when it finished.
/// Dropping its answer is the right outcome: nobody is looking any more.
abstract class SafeCubit<S> extends Cubit<S> {
  /// Creates the cubit in [initialState].
  SafeCubit(super.initialState);

  @override
  void emit(S state) {
    if (!isClosed) super.emit(state);
  }
}
