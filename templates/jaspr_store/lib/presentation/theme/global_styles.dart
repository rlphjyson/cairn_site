/// Global stylesheet, authored in Dart.
///
/// Jaspr's `@css` annotation collects `List<StyleRule>` getters at build time
/// and emits real CSS into the served document's `<style>` block: one small
/// inline stylesheet, no request, no flash of unstyled content.
library;

import 'package:jaspr/dom.dart';

import '../components/html.dart';
import 'tokens.dart';

/// Theme resolution order, highest priority last:
///
/// 1. `:root` declares the light palette unconditionally.
/// 2. `prefers-color-scheme: dark` swaps it, unless `data-theme="light"`.
/// 3. `:root[data-theme="dark"]` wins outright.
///
/// `data-theme` is stamped onto `<html>` by the server from a cookie (or
/// `?theme=`), so a returning dark-mode visitor gets dark HTML in the first
/// byte, with no white flash.
@css
List<StyleRule> get themeStyles => [
  rule(':root', {...sharedTokens, ...lightTokens}),
  css.media(MediaQuery.raw('(prefers-color-scheme: dark)'), [rule(':root:not([data-theme="light"])', darkTokens)]),
  rule(':root[data-theme="dark"]', darkTokens),
];

@css
List<StyleRule> get resetStyles => [
  rule('*, *::before, *::after', {'box-sizing': 'border-box', 'border-color': Tok.border}),
  rule('html', {'-webkit-text-size-adjust': '100%', 'scroll-behavior': 'smooth', 'scroll-padding-top': '5rem'}),
  rule('body', {
    'margin': '0',
    'min-height': '100vh',
    'display': 'flex',
    'flex-direction': 'column',
    'font-family': 'var(--font-sans)',
    'font-size': 'var(--text-base)',
    'line-height': '1.5',
    'color': Tok.foreground,
    'background-color': Tok.background,
    '-webkit-font-smoothing': 'antialiased',
  }),
  rule('main', {'display': 'block', 'flex': '1 0 auto'}),
  rule('h1, h2, h3, h4', {
    'margin': '0',
    'font-weight': '600',
    'line-height': '1.2',
    'letter-spacing': '-0.025em',
    'text-wrap': 'balance',
  }),
  rule('h1', {'font-size': 'clamp(1.875rem, 1.4rem + 2vw, 2.5rem)'}),
  rule('h2', {'font-size': 'clamp(1.5rem, 1.25rem + 1vw, 1.875rem)'}),
  rule('h3', {'font-size': 'var(--text-lg)'}),
  rule('p', {'margin': '0', 'text-wrap': 'pretty'}),
  rule('ul, ol', {'margin': '0', 'padding': '0', 'list-style': 'none'}),
  rule('a', {'color': 'inherit', 'text-decoration': 'none'}),
  rule('img, picture, svg', {'display': 'block', 'max-width': '100%'}),
  rule('img', {'height': 'auto'}),
  rule('button, input, select, textarea', {'font': 'inherit', 'color': 'inherit', 'margin': '0'}),
  rule('button', {'cursor': 'pointer'}),
  rule('hr', {'border': '0', 'border-top': '1px solid var(--border)', 'margin': '0'}),
  rule('table', {'border-collapse': 'collapse', 'width': '100%'}),
  rule('::selection', {'background': Tok.primary, 'color': Tok.primaryForeground}),
  // Focus ring: 3px at 50% of --ring, the same recipe as Cairn's components.
  rule(':focus-visible', {
    'outline': '2px solid transparent',
    'box-shadow': '0 0 0 3px color-mix(in oklab, var(--ring) 50%, transparent)',
    'border-radius': Tok.radiusSm,
  }),
  rule('input:focus-visible, select:focus-visible, textarea:focus-visible, button:focus-visible', {
    'border-radius': Tok.radiusMd,
  }),
  // Respect "reduce motion" for every animation and transition.
  css.media(MediaQuery.raw('(prefers-reduced-motion: reduce)'), [
    rule('*, *::before, *::after', {
      'animation-duration': '0.01ms !important',
      'animation-iteration-count': '1 !important',
      'transition-duration': '0.01ms !important',
      'scroll-behavior': 'auto !important',
    }),
  ]),
];

@css
List<StyleRule> get layoutStyles => [
  rule('.container', {
    'width': '100%',
    'max-width': 'var(--container)',
    'margin-inline': 'auto',
    'padding-inline': Tok.space(4),
  }),
  atMin('40rem', [
    rule('.container', {'padding-inline': Tok.space(6)}),
  ]),
  atMin('64rem', [
    rule('.container', {'padding-inline': Tok.space(8)}),
  ]),
  rule('.sr-only', {
    'position': 'absolute',
    'width': '1px',
    'height': '1px',
    'padding': '0',
    'margin': '-1px',
    'overflow': 'hidden',
    'clip-path': 'inset(50%)',
    'white-space': 'nowrap',
    'border': '0',
  }),
  rule('.skip-link', {
    'position': 'absolute',
    'left': Tok.space(2),
    'top': '-4rem',
    'z-index': '100',
    'padding': '${Tok.space(2)} ${Tok.space(4)}',
    'border-radius': Tok.radiusMd,
    'background': Tok.primary,
    'color': Tok.primaryForeground,
    'font-weight': '500',
    'font-size': 'var(--text-sm)',
  }),
  rule('.skip-link:focus', {'top': Tok.space(2)}),
  rule('.section', {'padding-block': Tok.space(12)}),
  atMin('64rem', [
    rule('.section', {'padding-block': Tok.space(16)}),
  ]),
  rule('.section--muted', {'background': Tok.muted}),
  rule('.section-head', {
    'display': 'flex',
    'flex-wrap': 'wrap',
    'align-items': 'end',
    'justify-content': 'space-between',
    'gap': Tok.space(3),
    'margin-bottom': Tok.space(8),
  }),
  rule('.section-head p', {'color': Tok.mutedForeground, 'margin-top': Tok.space(1)}),
  rule('.eyebrow', {
    'font-size': 'var(--text-xs)',
    'text-transform': 'uppercase',
    'letter-spacing': '0.1em',
    'font-weight': '600',
    'color': Tok.mutedForeground,
  }),
  rule('.muted', {'color': Tok.mutedForeground}),
  rule('.text-sm', {'font-size': 'var(--text-sm)'}),
  rule('.stack', {'display': 'flex', 'flex-direction': 'column', 'gap': Tok.space(4)}),
  rule('.stack-sm', {'display': 'flex', 'flex-direction': 'column', 'gap': Tok.space(2)}),
  rule('.row', {'display': 'flex', 'align-items': 'center', 'gap': Tok.space(3), 'flex-wrap': 'wrap'}),
  rule('.page-head', {'padding-block': '${Tok.space(8)} ${Tok.space(6)}'}),
  rule('.page-head p', {'color': Tok.mutedForeground, 'margin-top': Tok.space(2), 'max-width': '42rem'}),
  rule('.prose', {'max-width': '42rem', 'display': 'flex', 'flex-direction': 'column', 'gap': Tok.space(4)}),
  rule('.prose h2', {'margin-top': Tok.space(4), 'font-size': 'var(--text-2xl)'}),
  rule('.prose p, .prose li', {
    'color': 'color-mix(in oklab, var(--foreground) 85%, transparent)',
    'line-height': '1.7',
  }),
  rule('.prose ul', {
    'list-style': 'disc',
    'padding-left': Tok.space(6),
    'display': 'flex',
    'flex-direction': 'column',
    'gap': Tok.space(2),
  }),
  rule('.prose a', {'text-decoration': 'underline', 'text-underline-offset': '3px'}),
];
