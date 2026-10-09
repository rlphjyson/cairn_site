/// Breadcrumb and Pagination: plain links, no JavaScript.
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../theme/tokens.dart';
import 'html.dart';
import 'icons.dart';

class Crumb {
  const Crumb(this.label, [this.path]);
  final String label;

  /// Site-relative path; `null` marks the current page (not a link).
  final String? path;
}

class Breadcrumb extends StatelessComponent {
  const Breadcrumb(this.crumbs, {super.key});
  final List<Crumb> crumbs;

  @override
  Component build(BuildContext context) {
    return nav(
      classes: 'breadcrumb',
      attributes: const {'aria-label': 'Breadcrumb'},
      [
        ol(classes: 'breadcrumb__list', [
          for (var i = 0; i < crumbs.length; i++)
            li(classes: 'breadcrumb__item', [
              if (crumbs[i].path != null && i != crumbs.length - 1)
                a(href: crumbs[i].path!, [Component.text(crumbs[i].label)])
              else
                span(attributes: const {'aria-current': 'page'}, [Component.text(crumbs[i].label)]),
              if (i != crumbs.length - 1)
                span(
                  classes: 'breadcrumb__sep',
                  attributes: const {'aria-hidden': 'true'},
                  [Icons.chevronRight(size: 14)],
                ),
            ]),
        ]),
      ],
    );
  }
}

class Pagination extends StatelessComponent {
  const Pagination({required this.page, required this.pageCount, required this.hrefFor, super.key});

  final int page;
  final int pageCount;

  /// Builds the URL of a page. Page 1 must map to the bare URL (no `?page=1`).
  final String Function(int page) hrefFor;

  /// Windowed page list: always first and last, two either side of the current
  /// page, `null` for an ellipsis.
  static List<int?> window(int page, int count) {
    final shown = <int>{
      1,
      count,
      for (var i = page - 1; i <= page + 1; i++)
        if (i >= 1 && i <= count) i,
    };
    final sorted = shown.toList()..sort();
    final out = <int?>[];
    for (var i = 0; i < sorted.length; i++) {
      if (i > 0 && sorted[i] - sorted[i - 1] > 1) out.add(null);
      out.add(sorted[i]);
    }
    return out;
  }

  @override
  Component build(BuildContext context) {
    if (pageCount <= 1) return const Component.fragment([]);
    return nav(
      classes: 'pagination',
      attributes: const {'aria-label': 'Pagination'},
      [
        ul(classes: 'pagination__list', [
          li([
            if (page > 1)
              a(
                href: hrefFor(page - 1),
                classes: 'pagination__link pagination__link--step',
                attributes: const {'rel': 'prev'},
                [
                  Icons.chevronLeft(),
                  span([Component.text('Previous')]),
                ],
              )
            else
              span(
                classes: 'pagination__link pagination__link--step is-disabled',
                attributes: const {'aria-disabled': 'true'},
                [
                  Icons.chevronLeft(),
                  span([Component.text('Previous')]),
                ],
              ),
          ]),
          for (final p in window(page, pageCount))
            li(classes: 'pagination__num', [
              if (p == null)
                span(classes: 'pagination__ellipsis', attributes: const {'aria-hidden': 'true'}, [Component.text('…')])
              else if (p == page)
                span(
                  classes: 'pagination__link is-current',
                  attributes: {'aria-current': 'page', 'aria-label': 'Page $p, current page'},
                  [Component.text('$p')],
                )
              else
                a(
                  href: hrefFor(p),
                  classes: 'pagination__link',
                  attributes: {'aria-label': 'Page $p'},
                  [Component.text('$p')],
                ),
            ]),
          li([
            if (page < pageCount)
              a(
                href: hrefFor(page + 1),
                classes: 'pagination__link pagination__link--step',
                attributes: const {'rel': 'next'},
                [
                  span([Component.text('Next')]),
                  Icons.chevronRight(),
                ],
              )
            else
              span(
                classes: 'pagination__link pagination__link--step is-disabled',
                attributes: const {'aria-disabled': 'true'},
                [
                  span([Component.text('Next')]),
                  Icons.chevronRight(),
                ],
              ),
          ]),
        ]),
      ],
    );
  }
}

@css
List<StyleRule> get navigationStyles => [
  rule('.breadcrumb', {'font-size': 'var(--text-sm)', 'color': Tok.mutedForeground}),
  rule('.breadcrumb__list', {'display': 'flex', 'flex-wrap': 'wrap', 'align-items': 'center', 'gap': Tok.space(1.5)}),
  rule('.breadcrumb__item', {'display': 'inline-flex', 'align-items': 'center', 'gap': Tok.space(1.5)}),
  rule('.breadcrumb a:hover', {'color': Tok.foreground}),
  rule('.breadcrumb [aria-current="page"]', {'color': Tok.foreground, 'font-weight': '500'}),
  rule('.breadcrumb__sep', {'display': 'inline-flex'}),
  rule('.pagination', {'margin-top': Tok.space(10)}),
  rule('.pagination__list', {
    'display': 'flex',
    'flex-wrap': 'wrap',
    'justify-content': 'center',
    'align-items': 'center',
    'gap': Tok.space(1),
  }),
  rule('.pagination__link', {
    'display': 'inline-flex',
    'align-items': 'center',
    'justify-content': 'center',
    'gap': Tok.space(1),
    'min-width': '2.25rem',
    'height': '2.25rem',
    'padding': '0 ${Tok.space(3)}',
    'border': '1px solid transparent',
    'border-radius': Tok.radiusMd,
    'font-size': 'var(--text-sm)',
    'font-weight': '500',
  }),
  rule('a.pagination__link:hover', {'background': Tok.accent}),
  rule('.pagination__link.is-current', {
    'border-color': Tok.input,
    'background': Tok.background,
    'box-shadow': Tok.shadowXs,
  }),
  rule('.pagination__link.is-disabled', {'opacity': '0.5'}),
  rule('.pagination__ellipsis', {
    'display': 'inline-flex',
    'width': '2.25rem',
    'justify-content': 'center',
    'color': Tok.mutedForeground,
  }),
  atMax('39.99rem', [
    rule('.pagination__num', {'display': 'none'}),
    rule('.pagination__num:has(.is-current)', {'display': 'list-item'}),
    rule('.pagination__list', {'gap': Tok.space(2)}),
  ]),
];
