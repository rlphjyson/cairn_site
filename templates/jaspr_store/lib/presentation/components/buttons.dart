/// Buttons, mirroring Cairn's `CairnButton`: `h-9`, `rounded-md`, `text-sm`,
/// `font-medium`, `shadow-xs` on the filled variants.
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../theme/tokens.dart';
import 'html.dart';

enum ButtonVariant { primary, secondary, outline, ghost, destructive, link }

enum ButtonSize { sm, md, lg }

String buttonClasses(ButtonVariant variant, ButtonSize size, {bool block = false, String? extra}) =>
    cx(['btn', 'btn--${variant.name}', 'btn--${size.name}', if (block) 'btn--block', extra]);

/// A real anchor styled as a button: crawlable, middle-clickable, no JS.
class ButtonLink extends StatelessComponent {
  const ButtonLink({
    required this.href,
    required this.label,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.md,
    this.block = false,
    this.icon,
    this.classes,
    super.key,
  });

  final String href;
  final String label;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool block;
  final Component? icon;
  final String? classes;

  @override
  Component build(BuildContext context) {
    return a(
      href: href,
      classes: buttonClasses(variant, size, block: block, extra: classes),
      [if (icon != null) icon!, Component.text(label)],
    );
  }
}

/// A `<button type="submit">` for plain HTML forms. Works with JS disabled.
class SubmitButton extends StatelessComponent {
  const SubmitButton({
    required this.label,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.md,
    this.block = false,
    this.name,
    this.value,
    this.disabled = false,
    this.ariaLabel,
    this.icon,
    this.classes,
    super.key,
  });

  final String label;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool block;
  final String? name;
  final String? value;
  final bool disabled;
  final String? ariaLabel;
  final Component? icon;
  final String? classes;

  @override
  Component build(BuildContext context) {
    return el(
      'button',
      classes: buttonClasses(variant, size, block: block, extra: classes),
      attrs: {
        'type': 'submit',
        'name': ?name,
        'value': ?value,
        if (disabled) 'disabled': '',
        'aria-label': ?ariaLabel,
      },
      children: [if (icon != null) icon!, Component.text(label)],
    );
  }
}

@css
List<StyleRule> get buttonStyles => [
  rule('.btn', {
    'display': 'inline-flex',
    'align-items': 'center',
    'justify-content': 'center',
    'gap': Tok.space(2),
    'white-space': 'nowrap',
    'height': '2.25rem',
    'padding': '0 ${Tok.space(4)}',
    'border': '1px solid transparent',
    'border-radius': Tok.radiusMd,
    'font-size': 'var(--text-sm)',
    'font-weight': '500',
    'line-height': '1',
    'cursor': 'pointer',
    'transition': 'background-color 150ms var(--ease), color 150ms var(--ease), border-color 150ms var(--ease)',
    'text-decoration': 'none',
  }),
  rule('.btn--sm', {'height': '2rem', 'padding': '0 ${Tok.space(3)}', 'border-radius': Tok.radiusMd}),
  rule('.btn--lg', {'height': '2.5rem', 'padding': '0 ${Tok.space(6)}'}),
  rule('.btn--block', {'width': '100%'}),
  rule('.btn--primary', {'background': Tok.primary, 'color': Tok.primaryForeground, 'box-shadow': Tok.shadowXs}),
  rule('.btn--primary:hover', {'background': 'color-mix(in oklab, var(--primary) 90%, transparent)'}),
  rule('.btn--secondary', {'background': Tok.secondary, 'color': Tok.foreground, 'box-shadow': Tok.shadowXs}),
  rule('.btn--secondary:hover', {'background': 'color-mix(in oklab, var(--secondary) 80%, var(--foreground) 6%)'}),
  rule('.btn--outline', {
    'background': Tok.background,
    'border-color': Tok.input,
    'color': Tok.foreground,
    'box-shadow': Tok.shadowXs,
  }),
  rule('.btn--outline:hover', {'background': Tok.accent}),
  rule('.btn--ghost', {'background': 'transparent', 'color': Tok.foreground}),
  rule('.btn--ghost:hover', {'background': Tok.accent}),
  rule('.btn--destructive', {
    'background': Tok.destructive,
    'color': Tok.destructiveForeground,
    'box-shadow': Tok.shadowXs,
  }),
  rule('.btn--destructive:hover', {'background': 'color-mix(in oklab, var(--destructive) 90%, transparent)'}),
  rule('.btn--link', {
    'background': 'transparent',
    'color': Tok.foreground,
    'text-decoration': 'underline',
    'text-underline-offset': '4px',
    'padding': '0',
  }),
  rule('.btn[disabled], .btn[aria-disabled="true"]', {'opacity': '0.5', 'pointer-events': 'none'}),
  rule('.btn.is-busy', {'opacity': '0.7', 'pointer-events': 'none'}),
  rule('.btn .icon', {'flex': 'none'}),
];
