/// Badge, Alert, Accordion (native `<details>`), Skeleton.
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../theme/tokens.dart';
import 'html.dart';
import 'icons.dart';

enum BadgeVariant { primary, secondary, outline, destructive, success }

/// Meaning is always in the text, never colour alone.
class Badge extends StatelessComponent {
  const Badge(this.label, {this.variant = BadgeVariant.secondary, super.key});
  final String label;
  final BadgeVariant variant;

  @override
  Component build(BuildContext context) => span(classes: 'badge badge--${variant.name}', [Component.text(label)]);
}

enum AlertVariant { info, destructive, success }

class Alert extends StatelessComponent {
  const Alert({
    required this.children,
    this.title,
    this.variant = AlertVariant.info,
    this.id,
    this.live = false,
    super.key,
  });

  final String? title;
  final List<Component> children;
  final AlertVariant variant;
  final String? id;

  /// `role=alert` for errors that appear after a submit.
  final bool live;

  @override
  Component build(BuildContext context) {
    return div(
      id: id,
      classes: 'alert alert--${variant.name}',
      attributes: {if (live) 'role': variant == AlertVariant.destructive ? 'alert' : 'status'},
      [
        variant == AlertVariant.destructive
            ? Icons.alert()
            : (variant == AlertVariant.success ? Icons.check(size: 18) : Icons.info()),
        div(classes: 'alert__body', [
          if (title != null) p(classes: 'alert__title', [Component.text(title!)]),
          ...children,
        ]),
      ],
    );
  }
}

/// Native disclosure: works with JavaScript off, is keyboard accessible, and
/// its content is in the HTML for crawlers.
class Accordion extends StatelessComponent {
  const Accordion({required this.items, this.openFirst = false, super.key});

  /// title -> content
  final List<({String title, Component content})> items;
  final bool openFirst;

  @override
  Component build(BuildContext context) {
    return div(classes: 'accordion', [
      for (var i = 0; i < items.length; i++)
        details(open: openFirst && i == 0, classes: 'accordion__item', [
          summary(classes: 'accordion__trigger', [
            span([Component.text(items[i].title)]),
            Icons.chevronDown(),
          ]),
          div(classes: 'accordion__content', [items[i].content]),
        ]),
    ]);
  }
}

/// A shimmering placeholder. Used inside islands for the moment before their
/// data arrives; reduced-motion users get a static block.
class Skeleton extends StatelessComponent {
  const Skeleton({this.width = '100%', this.height = '1rem', this.classes, super.key});
  final String width;
  final String height;
  final String? classes;

  @override
  Component build(BuildContext context) => span(
    classes: cx(['skeleton', classes]),
    attributes: {'aria-hidden': 'true', 'style': 'width:$width;height:$height'},
    const [],
  );
}

@css
List<StyleRule> get feedbackStyles => [
  rule('.badge', {
    'display': 'inline-flex',
    'align-items': 'center',
    'gap': Tok.space(1),
    'padding': '${Tok.space(0.5)} ${Tok.space(2)}',
    'border': '1px solid transparent',
    'border-radius': Tok.radiusMd,
    'font-size': 'var(--text-xs)',
    'font-weight': '500',
    'line-height': '1rem',
    'white-space': 'nowrap',
  }),
  rule('.badge--primary', {'background': Tok.primary, 'color': Tok.primaryForeground}),
  rule('.badge--secondary', {'background': Tok.secondary, 'color': Tok.foreground}),
  rule('.badge--outline', {'border-color': Tok.border, 'color': Tok.foreground, 'background': Tok.background}),
  rule('.badge--destructive', {'background': Tok.destructive, 'color': Tok.destructiveForeground}),
  rule('.badge--success', {'background': 'color-mix(in oklab, var(--success) 14%, transparent)', 'color': Tok.success}),
  rule('.alert', {
    'display': 'flex',
    'gap': Tok.space(3),
    'align-items': 'flex-start',
    'padding': '${Tok.space(3)} ${Tok.space(4)}',
    'border': '1px solid var(--border)',
    'border-radius': Tok.radiusLg,
    'background': Tok.card,
    'font-size': 'var(--text-sm)',
  }),
  rule('.alert .icon', {'flex': 'none', 'margin-top': '0.125rem'}),
  rule('.alert__title', {'font-weight': '500', 'line-height': '1.4'}),
  rule('.alert__body', {'display': 'flex', 'flex-direction': 'column', 'gap': Tok.space(1), 'min-width': '0'}),
  rule('.alert__body p:not(.alert__title)', {'color': Tok.mutedForeground}),
  rule('.alert--destructive', {
    'border-color': 'color-mix(in oklab, var(--destructive) 50%, transparent)',
    'color': Tok.destructive,
  }),
  rule('.alert--destructive .alert__body p:not(.alert__title)', {
    'color': 'color-mix(in oklab, var(--destructive) 90%, transparent)',
  }),
  rule('.alert--success', {
    'border-color': 'color-mix(in oklab, var(--success) 40%, transparent)',
    'color': Tok.success,
  }),
  rule('.alert--success .alert__body p:not(.alert__title)', {'color': Tok.foreground}),
  rule('.accordion', {'border-top': '1px solid var(--border)'}),
  rule('.accordion__item', {'border-bottom': '1px solid var(--border)'}),
  rule('.accordion__trigger', {
    'display': 'flex',
    'align-items': 'center',
    'justify-content': 'space-between',
    'gap': Tok.space(4),
    'padding': '${Tok.space(4)} 0',
    'font-size': 'var(--text-sm)',
    'font-weight': '500',
    'cursor': 'pointer',
    'list-style': 'none',
  }),
  rule('.accordion__trigger::-webkit-details-marker', {'display': 'none'}),
  rule('.accordion__trigger:hover', {'text-decoration': 'underline'}),
  rule('.accordion__trigger .chevron', {
    'color': Tok.mutedForeground,
    'transition': 'transform 200ms var(--ease)',
    'flex': 'none',
  }),
  rule('.accordion__item[open] .chevron', {'transform': 'rotate(180deg)'}),
  rule('.accordion__content', {
    'padding-bottom': Tok.space(4),
    'font-size': 'var(--text-sm)',
    'color': Tok.mutedForeground,
    'line-height': '1.65',
  }),
  rule('.skeleton', {
    'display': 'inline-block',
    'border-radius': Tok.radiusMd,
    'background': Tok.muted,
    'animation': 'skeleton-pulse 1.6s ease-in-out infinite',
  }),
  css.keyframes('skeleton-pulse', {
    '0%, 100%': Styles(raw: {'opacity': '1'}),
    '50%': Styles(raw: {'opacity': '0.45'}),
  }),
];
