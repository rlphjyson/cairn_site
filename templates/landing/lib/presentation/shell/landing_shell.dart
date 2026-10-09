import 'dart:async';

import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/constants/section_ids.dart';
import '../../core/presentation/content_cubit.dart';
import '../../core/presentation/landing_actions.dart';
import '../../core/presentation/layout.dart';
import '../../core/presentation/navigation/landing_navigation_cubit.dart';
import '../../domain/site/models/site_info.dart';
import 'landing_navbar.dart';
import 'landing_page.dart';

/// The frame of the page: toasts, the sticky navbar and the scrolling body.
///
/// It owns the scroll controller and one [GlobalKey] per section, performs the
/// scrolls that [LandingNavigationCubit] requests, and reports which section
/// is at the top back to it.
class LandingShell extends StatefulWidget {
  /// Creates the shell.
  const LandingShell({
    super.key,
    this.onLink,
    this.initialSection,
    this.onSectionChanged,
  });

  /// Receives every content link that is not a `#` anchor.
  final ValueChanged<String>? onLink;

  /// A section to scroll to once the page has had time to load.
  final String? initialSection;

  /// Told when the section at the top of the viewport changes.
  final ValueChanged<String>? onSectionChanged;

  @override
  State<LandingShell> createState() => _LandingShellState();
}

class _LandingShellState extends State<LandingShell> {
  /// How far below the top of the viewport a section counts as active.
  static const double _activationOffset = 120;

  /// How long to wait for the sections to load before an initial scroll.
  static const Duration _initialScrollDelay = Duration(milliseconds: 600);

  Timer? _initialScroll;
  final ScrollController _scroll = ScrollController();
  final GlobalKey _viewportKey = GlobalKey(debugLabel: 'landing-viewport');
  final Map<String, GlobalKey> _sectionKeys = <String, GlobalKey>{
    for (final String id in SectionIds.all) id: GlobalKey(debugLabel: id),
  };

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_syncActiveSection);
    unawaited(context.read<ContentCubit<SiteInfo>>().load());
    final String? initial = widget.initialSection;
    if (initial != null) {
      _initialScroll = Timer(_initialScrollDelay, () {
        if (mounted) context.read<LandingNavigationCubit>().goTo(initial);
      });
    }
  }

  @override
  void dispose() {
    _initialScroll?.cancel();
    _scroll
      ..removeListener(_syncActiveSection)
      ..dispose();
    super.dispose();
  }

  void _open(String href) {
    if (href.startsWith('#')) {
      context.read<LandingNavigationCubit>().goTo(href.substring(1));
    } else {
      widget.onLink?.call(href);
    }
  }

  void _scrollTo(String id) {
    final BuildContext? target = _sectionKeys[id]?.currentContext;
    if (target == null) return;
    final bool reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    Scrollable.ensureVisible(
      target,
      duration: reduced ? Duration.zero : CairnMotion.d500,
      curve: CairnMotion.standard,
    );
  }

  void _syncActiveSection() {
    final RenderObject? viewport = _viewportKey.currentContext
        ?.findRenderObject();
    if (viewport is! RenderBox || !viewport.attached) return;
    final double top = viewport.localToGlobal(Offset.zero).dy;
    String? active;
    for (final String id in SectionIds.all) {
      final RenderObject? box = _sectionKeys[id]?.currentContext
          ?.findRenderObject();
      if (box is! RenderBox || !box.attached) continue;
      final double offset = box.localToGlobal(Offset.zero).dy - top;
      if (offset <= _activationOffset) active = id;
    }
    if (active != null) context.read<LandingNavigationCubit>().activate(active);
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return DefaultTextStyle(
      style: theme.defaultTextStyle,
      child: ColoredBox(
        color: theme.background,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) =>
              LandingViewport(
                width: constraints.maxWidth,
                child: LandingActions(
                  open: _open,
                  child: CairnToaster(
                    child: SizedBox.expand(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          const LandingNavbar(),
                          Expanded(
                            child:
                                BlocListener<
                                  LandingNavigationCubit,
                                  LandingNavigationState
                                >(
                                  listenWhen:
                                      (
                                        LandingNavigationState a,
                                        LandingNavigationState b,
                                      ) => a.activeId != b.activeId,
                                  listener:
                                      (
                                        BuildContext context,
                                        LandingNavigationState state,
                                      ) => widget.onSectionChanged?.call(
                                        state.activeId,
                                      ),
                                  child:
                                      BlocListener<
                                        LandingNavigationCubit,
                                        LandingNavigationState
                                      >(
                                        listenWhen:
                                            (
                                              LandingNavigationState a,
                                              LandingNavigationState b,
                                            ) => a.requests != b.requests,
                                        listener:
                                            (
                                              BuildContext context,
                                              LandingNavigationState state,
                                            ) {
                                              final String? id =
                                                  state.requestedId;
                                              if (id != null) _scrollTo(id);
                                            },
                                        child: SingleChildScrollView(
                                          key: _viewportKey,
                                          controller: _scroll,
                                          child: LandingPage(
                                            sectionKeys: _sectionKeys,
                                          ),
                                        ),
                                      ),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
        ),
      ),
    );
  }
}
