import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/content_cubit.dart';
import '../../../domain/gallery/models/gallery_content.dart';
import '../../../domain/gallery/use_cases/get_gallery.dart';

/// The gallery: its content and the slide in view.
class GalleryState extends Equatable {
  /// Creates a state.
  const GalleryState({
    this.status = ContentStatus.initial,
    this.content,
    this.page = 0,
  });

  /// Whether the content has loaded.
  final ContentStatus status;

  /// The content, once loaded.
  final GalleryContent? content;

  /// The index of the slide in view.
  final int page;

  /// The slide in view, or `null` before the content loads.
  GallerySlide? get current {
    final GalleryContent? c = content;
    if (c == null || c.slides.isEmpty) return null;
    return c.slides[page.clamp(0, c.slides.length - 1)];
  }

  /// A copy with the given fields replaced.
  GalleryState copyWith({
    ContentStatus? status,
    GalleryContent? content,
    int? page,
  }) => GalleryState(
    status: status ?? this.status,
    content: content ?? this.content,
    page: page ?? this.page,
  );

  @override
  List<Object?> get props => <Object?>[status, content, page];
}

/// Loads the gallery and tracks the slide in view.
class GalleryCubit extends Cubit<GalleryState> {
  /// Creates the cubit.
  GalleryCubit(this._getGallery) : super(const GalleryState());

  final GetGallery _getGallery;

  /// Loads the slides; does nothing once loaded.
  Future<void> load() async {
    if (state.status == ContentStatus.loading ||
        state.status == ContentStatus.loaded) {
      return;
    }
    emit(state.copyWith(status: ContentStatus.loading));
    try {
      emit(
        state.copyWith(
          status: ContentStatus.loaded,
          content: await _getGallery(),
        ),
      );
    } on Object {
      emit(state.copyWith(status: ContentStatus.failure));
    }
  }

  /// Records that slide [page] is in view.
  void setPage(int page) {
    final int count = state.content?.slides.length ?? 0;
    if (count == 0 || page < 0 || page >= count || page == state.page) return;
    emit(state.copyWith(page: page));
  }
}
