import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/content_cubit.dart';
import '../../../domain/features/models/features_content.dart';
import '../../../domain/features/use_cases/get_features.dart';

/// The feature showcase: its content and which feature is selected.
class FeaturesState extends Equatable {
  /// Creates a state.
  const FeaturesState({
    this.status = ContentStatus.initial,
    this.content,
    this.selectedId,
  });

  /// Whether the content has loaded.
  final ContentStatus status;

  /// The content, once loaded.
  final FeaturesContent? content;

  /// The id of the selected feature, or `null` before the content loads.
  final String? selectedId;

  /// The selected feature, or `null` before the content loads.
  Feature? get selected {
    final FeaturesContent? c = content;
    final String? id = selectedId;
    if (c == null || id == null) return null;
    return c.byId(id);
  }

  /// A copy with the given fields replaced.
  FeaturesState copyWith({
    ContentStatus? status,
    FeaturesContent? content,
    String? selectedId,
  }) => FeaturesState(
    status: status ?? this.status,
    content: content ?? this.content,
    selectedId: selectedId ?? this.selectedId,
  );

  @override
  List<Object?> get props => <Object?>[status, content, selectedId];
}

/// Loads the features and tracks which one is selected.
class FeaturesCubit extends Cubit<FeaturesState> {
  /// Creates the cubit.
  FeaturesCubit(this._getFeatures) : super(const FeaturesState());

  final GetFeatures _getFeatures;

  /// Loads the features and selects the first; does nothing once loaded.
  Future<void> load() async {
    if (state.status == ContentStatus.loading ||
        state.status == ContentStatus.loaded) {
      return;
    }
    emit(state.copyWith(status: ContentStatus.loading));
    try {
      final FeaturesContent content = await _getFeatures();
      emit(
        state.copyWith(
          status: ContentStatus.loaded,
          content: content,
          selectedId: content.items.first.id,
        ),
      );
    } on Object {
      emit(state.copyWith(status: ContentStatus.failure));
    }
  }

  /// Shows the feature with [id]; unknown ids and repeats are ignored.
  void select(String id) {
    final FeaturesContent? content = state.content;
    if (content == null || id == state.selectedId) return;
    if (!content.items.any((Feature f) => f.id == id)) return;
    emit(state.copyWith(selectedId: id));
  }
}
