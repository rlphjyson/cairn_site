import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/app_landing_text.dart';
import '../../../core/presentation/content_cubit.dart';
import '../../../core/presentation/layout.dart';
import '../../../core/presentation/mock/mock_phone.dart';
import '../../../core/presentation/view_model.dart';
import '../../../core/presentation/widgets/reveal.dart';
import '../../../core/presentation/widgets/section_frame.dart';
import '../../../core/presentation/widgets/section_header.dart';
import '../../../domain/gallery/models/gallery_content.dart';
import '../bloc/gallery_cubit.dart';
import '../view_models/gallery_view_model.dart';

/// The screenshots gallery: a carousel of phone frames with captions.
///
/// The previous and next buttons are real buttons, so the carousel works from
/// the keyboard; the slides also drag with touch, trackpad or mouse.
class GalleryView extends StatelessWidget {
  /// Creates the view.
  const GalleryView({super.key});

  /// The height of the carousel strip: a phone, a heading and a caption.
  static const double stripHeight = 540;

  /// The width of the phone in each slide.
  static const double phoneWidth = 196;

  @override
  Widget build(BuildContext context) => ViewModelBuilder<GalleryViewModel>(
    onCreate: (BuildContext _, GalleryViewModel vm) => vm.cubit.load(),
    builder: (BuildContext context, GalleryViewModel vm) =>
        BlocBuilder<GalleryCubit, GalleryState>(
          bloc: vm.cubit,
          buildWhen: (GalleryState a, GalleryState b) =>
              a.status != b.status || a.page != b.page,
          builder: (BuildContext context, GalleryState state) {
            final GalleryContent? content = state.content;
            if (content == null || state.status != ContentStatus.loaded) {
              return const SizedBox(height: 860);
            }
            return _Gallery(
              content: content,
              page: state.page,
              onPage: vm.cubit.setPage,
            );
          },
        ),
  );
}

class _Gallery extends StatelessWidget {
  const _Gallery({
    required this.content,
    required this.page,
    required this.onPage,
  });

  final GalleryContent content;
  final int page;
  final ValueChanged<int> onPage;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final AppLandingViewport viewport = AppLandingViewport.of(context);
    final double fraction = switch (viewport.breakpoint) {
      AppLandingBreakpoint.compact => 1.0,
      AppLandingBreakpoint.medium => 0.5,
      AppLandingBreakpoint.expanded => 0.34,
    };
    final GallerySlide current =
        content.slides[page.clamp(0, content.slides.length - 1)];

    return SectionFrame(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Reveal(
            child: SectionHeader(
              eyebrow: content.eyebrow,
              title: content.title,
              subtitle: content.subtitle,
            ),
          ),
          SizedBox(height: viewport.isCompact ? 32 : 48),
          Reveal(
            delay: const Duration(milliseconds: 80),
            child: Semantics(
              container: true,
              label: 'Screenshots',
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: <PointerDeviceKind>{
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.trackpad,
                    PointerDeviceKind.stylus,
                  },
                ),
                child: CairnCarousel(
                  height: GalleryView.stripHeight,
                  viewportFraction: fraction,
                  onPageChanged: onPage,
                  items: <Widget>[
                    for (final GallerySlide slide in content.slides)
                      _Slide(slide: slide),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: CairnSpacing.s3),
          Semantics(
            liveRegion: true,
            child: Text(
              '${page + 1} of ${content.slides.length}: ${current.title}',
              textAlign: TextAlign.center,
              style: appLandingText(
                theme,
                CairnTypography.sm,
                color: theme.mutedForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({required this.slide});

  final GallerySlide slide;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth.clamp(
          120.0,
          GalleryView.phoneWidth,
        );
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(36),
                boxShadow: CairnShadows.md,
              ),
              child: MockPhone(screen: slide.screen, width: width),
            ),
            const SizedBox(height: CairnSpacing.s4),
            Text(
              slide.title,
              textAlign: TextAlign.center,
              style: appLandingText(
                theme,
                CairnTypography.base,
                weight: CairnTypography.semibold,
                height: 1.3,
              ),
            ),
            const SizedBox(height: CairnSpacing.s1),
            Text(
              slide.caption,
              textAlign: TextAlign.center,
              style: appLandingText(
                theme,
                CairnTypography.sm,
                color: theme.mutedForeground,
                height: 1.4,
              ),
            ),
          ],
        );
      },
    );
  }
}
