import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'view_model.dart';

/// Where a section's content is in its life.
enum ContentStatus {
  /// Not requested yet.
  initial,

  /// Requested, not back yet.
  loading,

  /// Available in [ContentState.data].
  loaded,

  /// The request failed.
  failure,
}

/// The state of one content-driven section.
class ContentState<T extends Object> extends Equatable {
  /// Creates a state.
  const ContentState(this.status, [this.data]);

  /// The status.
  final ContentStatus status;

  /// The content, once [status] is [ContentStatus.loaded].
  final T? data;

  @override
  List<Object?> get props => <Object?>[status, data];
}

/// Loads one section's content through a use case.
///
/// Most sections are plain content: a use case returns a model, the cubit
/// holds it. Sections with behaviour (pricing, the waitlist form) have their
/// own cubits.
class ContentCubit<T extends Object> extends Cubit<ContentState<T>> {
  /// Creates a cubit that loads with [loader].
  ContentCubit(this._loader) : super(ContentState<T>(ContentStatus.initial));

  final Future<T> Function() _loader;

  /// Loads the content; does nothing while loading or once loaded.
  Future<void> load() async {
    if (state.status == ContentStatus.loading ||
        state.status == ContentStatus.loaded) {
      return;
    }
    emit(ContentState<T>(ContentStatus.loading));
    try {
      emit(ContentState<T>(ContentStatus.loaded, await _loader()));
    } on Object {
      emit(ContentState<T>(ContentStatus.failure));
    }
  }
}

/// Owns a [ContentCubit] for the life of one section.
class ContentViewModel<T extends Object> implements ViewModel {
  /// Creates the view model.
  ContentViewModel(this.cubit);

  /// The section's cubit.
  final ContentCubit<T> cubit;

  @override
  void dispose() => cubit.close();
}
