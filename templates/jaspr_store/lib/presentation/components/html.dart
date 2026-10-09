/// Tiny helpers over Jaspr's DOM so components read like markup.
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// Generic element builder for tags/attributes the typed helpers do not model
/// (e.g. `<picture>`, `<input>` with arbitrary attributes, `srcset`).
Component el(
  String tag, {
  String? classes,
  String? id,
  Map<String, String>? attrs,
  Map<String, EventCallback>? events,
  List<Component> children = const [],
}) => Component.element(tag: tag, id: id, classes: classes, attributes: attrs, events: events, children: children);

Component t(String text) => Component.text(text);

/// A `StyleRule` from a selector and a property map. Values reference
/// design tokens (`Tok.*`), so colours never appear as literals here.
StyleRule rule(String selector, Map<String, String> props) => css(selector).styles(raw: props);

/// A rule inside `@media (min-width: ...)`.
StyleRule atMin(String width, List<StyleRule> rules) => css.media(MediaQuery.raw('(min-width: $width)'), rules);

StyleRule atMax(String width, List<StyleRule> rules) => css.media(MediaQuery.raw('(max-width: $width)'), rules);

/// Joins non-empty class names.
String cx(List<String?> names) => names.where((n) => n != null && n.isNotEmpty).join(' ');
