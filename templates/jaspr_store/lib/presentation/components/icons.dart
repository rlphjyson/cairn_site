/// Inline SVG icons (Lucide-style, 24px grid, 2px stroke). Inline because an
/// icon font or sprite is an extra request on every page; these cost a few
/// hundred bytes each and inherit `currentColor`.
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import 'html.dart';

Component _icon(String paths, {int size = 20, String? classes}) => el(
  'svg',
  classes: cx(['icon', classes]),
  attrs: {
    'xmlns': 'http://www.w3.org/2000/svg',
    'width': '$size',
    'height': '$size',
    'viewBox': '0 0 24 24',
    'fill': 'none',
    'stroke': 'currentColor',
    'stroke-width': '2',
    'stroke-linecap': 'round',
    'stroke-linejoin': 'round',
    'aria-hidden': 'true',
    'focusable': 'false',
  },
  // The path data is a static constant; `RawText` keeps it unescaped.
  children: [RawText(paths)],
);

abstract final class Icons {
  static Component cart({int size = 20}) => _icon(
    '<circle cx="8" cy="21" r="1"/><circle cx="19" cy="21" r="1"/><path d="M2.05 2.05h2l2.66 12.42a2 2 0 0 0 2 1.58h9.78a2 2 0 0 0 1.95-1.57l1.65-7.43H5.12"/>',
    size: size,
  );
  static Component search({int size = 18}) =>
      _icon('<circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/>', size: size);
  static Component menu({int size = 22}) => _icon('<path d="M4 6h16M4 12h16M4 18h16"/>', size: size);
  static Component close({int size = 22}) => _icon('<path d="M18 6 6 18M6 6l12 12"/>', size: size);
  static Component check({int size = 16}) => _icon('<path d="M20 6 9 17l-5-5"/>', size: size);
  static Component chevronDown({int size = 18}) => _icon('<path d="m6 9 6 6 6-6"/>', size: size, classes: 'chevron');
  static Component chevronRight({int size = 16}) => _icon('<path d="m9 18 6-6-6-6"/>', size: size);
  static Component chevronLeft({int size = 16}) => _icon('<path d="m15 18-6-6 6-6"/>', size: size);
  static Component truck({int size = 22}) => _icon(
    '<path d="M14 18V6a2 2 0 0 0-2-2H4a2 2 0 0 0-2 2v11a1 1 0 0 0 1 1h2"/><path d="M15 18H9"/><path d="M19 18h2a1 1 0 0 0 1-1v-3.65a1 1 0 0 0-.22-.624l-3.48-4.35A1 1 0 0 0 17.52 8H14"/><circle cx="17" cy="18" r="2"/><circle cx="7" cy="18" r="2"/>',
    size: size,
  );
  static Component refresh({int size = 22}) => _icon(
    '<path d="M3 12a9 9 0 0 1 9-9 9.75 9.75 0 0 1 6.74 2.74L21 8"/><path d="M21 3v5h-5"/><path d="M21 12a9 9 0 0 1-9 9 9.75 9.75 0 0 1-6.74-2.74L3 16"/><path d="M8 16H3v5"/>',
    size: size,
  );
  static Component shield({int size = 22}) => _icon(
    '<path d="M20 13c0 5-3.5 7.5-7.66 8.95a1 1 0 0 1-.67-.01C7.5 20.5 4 18 4 13V6a1 1 0 0 1 1-1c2 0 4.5-1.2 6.24-2.72a1.17 1.17 0 0 1 1.52 0C14.51 3.81 17 5 19 5a1 1 0 0 1 1 1z"/><path d="m9 12 2 2 4-4"/>',
    size: size,
  );
  static Component leaf({int size = 22}) => _icon(
    '<path d="M11 20A7 7 0 0 1 9.8 6.1C15.5 5 17 4.48 19 2c1 2 2 4.18 2 8 0 5.5-4.78 10-10 10Z"/><path d="M2 21c0-3 1.85-5.36 5.08-6C9.5 14.52 12 13 13 12"/>',
    size: size,
  );
  static Component sun({int size = 18}) => _icon(
    '<circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2m-7.07-17.07 1.41 1.41m11.32 11.32 1.41 1.41M2 12h2m16 0h2M4.93 19.07l1.41-1.41m11.32-11.32 1.41-1.41"/>',
    size: size,
  );
  static Component moon({int size = 18}) => _icon('<path d="M12 3a6 6 0 0 0 9 9 9 9 0 1 1-9-9Z"/>', size: size);
  static Component trash({int size = 16}) => _icon(
    '<path d="M3 6h18M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/>',
    size: size,
  );
  static Component info({int size = 18}) =>
      _icon('<circle cx="12" cy="12" r="10"/><path d="M12 16v-4M12 8h.01"/>', size: size);
  static Component alert({int size = 18}) => _icon(
    '<circle cx="12" cy="12" r="10"/><path d="M12 8v4M12 16h.01"/>',
    size: size,
  );
}

/// The Northgate mark: three stacked stones.
Component brandMark({int size = 28}) => el(
  'svg',
  classes: 'brand-mark',
  attrs: {
    'xmlns': 'http://www.w3.org/2000/svg',
    'width': '$size',
    'height': '$size',
    'viewBox': '0 0 64 64',
    'aria-hidden': 'true',
    'focusable': 'false',
  },
  children: [
    RawText(
      '<rect width="64" height="64" rx="14" fill="currentColor"/>'
      '<ellipse cx="32" cy="46" rx="18" ry="7.5" style="fill:var(--background)"/>'
      '<ellipse cx="32" cy="32" rx="13" ry="6.5" style="fill:var(--background);opacity:.75"/>'
      '<ellipse cx="32" cy="19.5" rx="8" ry="5.5" style="fill:var(--background);opacity:.5"/>',
    ),
  ],
);
