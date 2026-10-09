import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/constants/docs_brand.dart';

/// Where a reader is: a version, a page, and optionally a heading on it.
///
/// This is also the type a host app hands to `DocsApp.initialLocation` and gets
/// back from `DocsApp.onLocationChanged`, which is what makes deep links with
/// an outside router a few lines of code.
class DocsLocation extends Equatable {
  /// Creates a location.
  const DocsLocation({
    this.versionId = DocsBrand.defaultVersionId,
    this.pageSlug = DocsBrand.homeSlug,
    this.headingId,
  });

  /// The documentation version.
  final String versionId;

  /// The page within that version.
  final String pageSlug;

  /// The heading anchor on the page, or `null` for the top.
  final String? headingId;

  @override
  List<Object?> get props => <Object?>[versionId, pageSlug, headingId];
}

/// The navigation state: a [DocsLocation] plus a counter.
///
/// [jump] increases every time something asks the page to scroll to
/// [headingId], so asking for the same heading twice (after the reader has
/// scrolled away) is still a state change and still scrolls.
class DocsNavigationState extends Equatable {
  /// Creates a state.
  const DocsNavigationState({
    this.versionId = DocsBrand.defaultVersionId,
    this.pageSlug = DocsBrand.homeSlug,
    this.headingId,
    this.jump = 0,
  });

  /// The documentation version.
  final String versionId;

  /// The open page.
  final String pageSlug;

  /// The heading to scroll to, or `null`.
  final String? headingId;

  /// Scroll-request counter; see the class comment.
  final int jump;

  /// The state as a location.
  DocsLocation get location => DocsLocation(
    versionId: versionId,
    pageSlug: pageSlug,
    headingId: headingId,
  );

  @override
  List<Object?> get props => <Object?>[versionId, pageSlug, headingId, jump];
}

/// Navigation inside the template.
///
/// The template deliberately does not use a router: it has to run unchanged
/// inside any Flutter app. To drive the URL, give `DocsApp` an
/// `onLocationChanged` callback and an `initialLocation`; the doc/index.html
/// guide shows the go_router version.
class DocsNavigationCubit extends Cubit<DocsNavigationState> {
  /// Creates the cubit at [initial].
  DocsNavigationCubit([DocsLocation initial = const DocsLocation()])
    : super(
        DocsNavigationState(
          versionId: initial.versionId,
          pageSlug: initial.pageSlug,
          headingId: initial.headingId,
          jump: initial.headingId == null ? 0 : 1,
        ),
      );

  /// Opens [slug], optionally scrolled to [headingId].
  void openPage(String slug, {String? headingId}) {
    emit(
      DocsNavigationState(
        versionId: state.versionId,
        pageSlug: slug,
        headingId: headingId,
        jump: headingId == null ? state.jump : state.jump + 1,
      ),
    );
  }

  /// Scrolls the open page to [headingId].
  void goToHeading(String headingId) {
    emit(
      DocsNavigationState(
        versionId: state.versionId,
        pageSlug: state.pageSlug,
        headingId: headingId,
        jump: state.jump + 1,
      ),
    );
  }

  /// Switches version, keeping the page if the new version has it.
  void selectVersion(String versionId) {
    if (versionId == state.versionId) return;
    emit(
      DocsNavigationState(
        versionId: versionId,
        pageSlug: state.pageSlug,
        jump: state.jump,
      ),
    );
  }

  /// Jumps to [location], for example from a router.
  void go(DocsLocation location) {
    if (location == state.location) return;
    emit(
      DocsNavigationState(
        versionId: location.versionId,
        pageSlug: location.pageSlug,
        headingId: location.headingId,
        jump: location.headingId == null ? state.jump : state.jump + 1,
      ),
    );
  }
}
