import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/constants/section_ids.dart';

/// Which section is active and which one the visitor asked to scroll to.
class AppLandingNavigationState extends Equatable {
  /// Creates a state.
  const AppLandingNavigationState({
    this.activeId = SectionIds.hero,
    this.requestedId,
    this.requests = 0,
  });

  /// The section currently at the top of the viewport.
  final String activeId;

  /// The section the last navigation asked for, or `null` before any.
  final String? requestedId;

  /// How many navigations were requested; lets the shell react to a repeat
  /// request for the same section.
  final int requests;

  /// A copy with the given fields replaced.
  AppLandingNavigationState copyWith({
    String? activeId,
    String? requestedId,
    int? requests,
  }) => AppLandingNavigationState(
    activeId: activeId ?? this.activeId,
    requestedId: requestedId ?? this.requestedId,
    requests: requests ?? this.requests,
  );

  @override
  List<Object?> get props => <Object?>[activeId, requestedId, requests];
}

/// Scroll navigation for the one-page template.
///
/// The cubit holds intent only: [goTo] records a request, and the shell, which
/// owns the scroll controller and the section keys, performs it and reports
/// the section in view back through [activate]. It has no Flutter dependency,
/// so it runs in any host app and is easy to test. In an app with a router,
/// replace it and keep the sections.
class AppLandingNavigationCubit extends Cubit<AppLandingNavigationState> {
  /// Creates the cubit.
  AppLandingNavigationCubit() : super(const AppLandingNavigationState());

  /// Asks the page to scroll to the section with [sectionId].
  void goTo(String sectionId) => emit(
    state.copyWith(requestedId: sectionId, requests: state.requests + 1),
  );

  /// Records that [sectionId] is now at the top of the viewport.
  void activate(String sectionId) => emit(state.copyWith(activeId: sectionId));
}
