import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Which sidebar sections the reader has collapsed.
class SidebarState extends Equatable {
  /// Creates a state.
  const SidebarState({this.collapsed = const <String>{}});

  /// Ids of the collapsed sections. Everything is open by default.
  final Set<String> collapsed;

  /// Whether [sectionId] is open.
  bool isOpen(String sectionId) => !collapsed.contains(sectionId);

  @override
  List<Object?> get props => <Object?>[collapsed];
}

/// Session cubit shared by the desktop sidebar and the mobile drawer, so a
/// section collapsed in one stays collapsed in the other.
class SidebarCubit extends Cubit<SidebarState> {
  /// Creates the cubit.
  SidebarCubit() : super(const SidebarState());

  /// Opens a closed section, or closes an open one.
  void toggle(String sectionId) {
    final Set<String> next = <String>{...state.collapsed};
    if (!next.remove(sectionId)) next.add(sectionId);
    emit(SidebarState(collapsed: next));
  }

  /// Opens [sectionId] if it is closed (used when navigating into it).
  void reveal(String sectionId) {
    if (state.isOpen(sectionId)) return;
    emit(
      SidebarState(collapsed: <String>{...state.collapsed}..remove(sectionId)),
    );
  }
}
