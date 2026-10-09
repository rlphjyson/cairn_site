# Cairn Site

[![CI](https://github.com/rlphjyson/cairn_site/actions/workflows/ci.yml/badge.svg)](https://github.com/rlphjyson/cairn_site/actions/workflows/ci.yml)
[![Deploy](https://github.com/rlphjyson/cairn_site/actions/workflows/deploy.yml/badge.svg)](https://github.com/rlphjyson/cairn_site/actions/workflows/deploy.yml)
[![Licence: MIT](https://img.shields.io/badge/licence-MIT-blue.svg)](LICENSE)

The marketing and documentation site for
[Cairn UI](https://github.com/rlphjyson/cairn_ui) — built as a Flutter web app,
**with Cairn UI itself**.

**Live: <https://rlphjyson.github.io/cairn_site/>**

---

## The point

A component library that only ever shows its components in isolation has not
proved very much. A grid of buttons on a grey background tells you the buttons
render; it tells you nothing about whether the library composes, whether its
tokens hold up across a whole screen, or whether its overlays survive being
mounted fifty at a time and then navigated away from.

So this repository adds `cairn_ui` as a dependency and builds its own chrome out
of it:

| Cairn widget | What it does here |
| --- | --- |
| `CairnButton` | Every nav link, CTA, toolbar control and pagination arrow |
| `CairnTabs` | The Preview / Code toggle on every example, and the category filter on `/components` |
| `CairnCommand` | The Ctrl+K palette, wired to the real routes |
| `CairnSheet` | The navigation drawer below 1024px |
| `CairnDialog` | The snippet viewer behind each catalogue card's **Code** button |
| `CairnToast` | The confirmation after a code block is copied |
| `CairnTooltip` | The theme toggle, the copy button and the pinned-commit badge |
| `CairnScrollArea` | Every page scroller, the docs sidebar and the "On this page" rail |
| `CairnDataTable` | The `/directory` index — sorting, filtering and pagination for free |
| `CairnBreadcrumb` | Docs and component detail pages |
| `CairnAlert` | Every callout in the documentation prose |
| `CairnCard`, `CairnBadge`, `CairnInput`, `CairnSelect`, `CairnSeparator` | Everywhere |

If a component regresses upstream, this site breaks. That is the point, and it
is why the dependency is pinned to the `^0.2.0` release line rather than a branch.

It has already paid for itself once: mounting the whole catalogue on one page and
navigating away surfaced a latent crash in `CairnContextMenu`, which is now
fixed upstream with a regression test.

## Sections

| Route | What it is |
| --- | --- |
| `/` | Landing page: hero, a bento grid of live component previews, the four design decisions, the dogfooding story, a live block |
| `/docs/*` | Eight documentation pages with a sticky sidebar, an "On this page" rail with working anchors, and copyable code blocks |
| `/components` | All 65 component modules — 70 cards, because five widgets ship inside a sibling's file — each a live, interactive preview |
| `/components/:slug` | One component: a preview where **every rendered instance is clickable** and reveals its own exact snippet, the quick-start example, the design note, prev/next |
| `/blocks` | Five composed screens: login, dashboard shell, settings, pricing, team roster |
| `/templates`, `/templates/:slug` | Five live, clickable whole-app templates — an e-commerce app (phone frame), a dashboard, a blog, a documentation site and a SaaS landing page (browser frame) — each with screenshots, architecture notes and a link to its HTML tutorial, plus the roadmap |
| `/template-docs/*` | The HTML documentation for each template (static files copied from `templates/<name>/doc/`) |
| `/charts` | Seven chart shapes on Cairn's token palette, and an honest note about why they are not Cairn components |
| `/directory` | Every module, widget, block and doc page in one sortable table |
| `/typeset` | The type scale as a live style guide, with three rhythm knobs over a prose specimen |

## Running it

```bash
flutter pub get
flutter test
flutter analyze --fatal-infos --fatal-warnings

# Debug mode is slow for a component-heavy page; build once and serve the
# static output instead.
flutter build web --release
cd build/web && python -m http.server 8000
```

To reproduce the deployed build exactly, add `--base-href /cairn_site/` and
serve from a parent directory whose `cairn_site/` folder is the output, with
`404.html` copied from `index.html`.

## How it is put together

```
lib/
  main.dart                    usePathUrlStrategy + runApp
  src/
    app/       app, router, routes, theme controller, page titles, links
    shell/     the header, the footer, the default page wrapper
    pages/     one file per route
    data/      the component, block and docs catalogues, and their previews
    widgets/   code block, syntax highlighter, preview pane, bento grid, icons
    charts/    the fl_chart adapter that speaks Cairn tokens
```

The catalogues in `lib/src/data/` are plain `const` lists. Every page, the
command palette, the directory table and the footer all read from them, so a
new component is one list entry rather than six edits — and
`test/catalog_test.dart` asserts that nothing in them points at a route the
router does not serve.

## Notable decisions

**Nobody should have to read the source.** A detail page used to render several
configurations of a component and then show one generic snippet underneath, so
a visitor who wanted the small destructive button had to reverse-engineer it.
Every preview is now a `VariantSet` (`lib/src/data/variant_sample.dart`): a list
of `VariantSample`s, each pairing a live widget with the complete, standalone
code that reproduces *that* instance. Clicking a rendered widget rings it and
opens its snippet in place, under the preview — 100 snippets across the 50
catalogue entries, all of them written against the real public API rather than
paraphrased.

Two details in there are load-bearing. The selection wrapper uses a `Listener`
rather than a `GestureDetector`, because a gesture detector would enter the
arena and fight every component it wraps — a Slider drag, a Carousel swipe, a
Tabs tap would each have to win against it; a listener only observes the pointer
stream, so the wrapped widget behaves exactly as it does anywhere else. And the
snippet opens *under* the preview instead of switching to the Code tab, because
switching would throw away whatever the visitor was in the middle of doing to
the live widget.

**Dark by default.** `SiteThemeController` starts at `ThemeMode.dark`, not
`ThemeMode.system`, and the toggle only ever moves between the two explicit
modes so it is never a no-op. The crossfade between them is free:
`CairnTheme` implements `ThemeExtension.lerp`, and `MaterialApp` wraps the tree
in an `AnimatedTheme`.

**Real URLs.** `go_router` with `usePathUrlStrategy()`, so `/components/switch`
and `/docs/theming` are shareable and survive a refresh. GitHub Pages has no SPA
rewrite, so the deploy workflow copies `index.html` to `404.html`; Pages serves
that for unmatched paths, the `<base href>` resolves the assets, and the router
reads the real pathname.

**Charts are fl_chart, restyled.** Charting is a large problem in its own right
— axes, ticks, curve interpolation, hit-testing, tooltips — and Flutter already
has a mature package that solves it. What a design system usefully adds is a
consistent skin, not a second implementation, and hand-painting one inside a
library whose contract is "no runtime dependencies beyond Flutter" would mean
carrying golden sheets for it forever. `lib/src/charts/chart_theme.dart` is the
adapter, and the Charts page says all of this out loud.

**No icon font.** The glyphs the site needs that the library does not ship are
drawn with a `CustomPainter` on Lucide's 24×24 grid, matching what Cairn does
internally. The site ships no image assets at all.

## Templates

`templates/` holds five standalone Flutter packages, each with its own
`pubspec.yaml`, `assets/`, `test/`, `README.md` and `doc/index.html` tutorial:

| Package | Template |
| --- | --- |
| `templates/shop` | Mobile e-commerce: storefront, product pages, cart, checkout, orders |
| `templates/dashboard` | Analytics dashboard with charts and an orders table |
| `templates/blog` | Blog with search, categories, rich posts and a newsletter |
| `templates/docs` | Documentation site with versions, a search palette and typed blocks |
| `templates/landing` | SaaS landing page with pricing and a waitlist |

All five use clean architecture with the layers at the top of `lib/`
(`core`, `common`, `data/<feature>`, `domain/<feature>`,
`presentation/<feature>`), `flutter_bloc` and `get_it`, and need nothing but
`cairn_ui` (the dashboard adds `fl_chart`). The site mounts them by path
dependency. The root analyzer skips `templates/`; each package is analysed and
tested on its own (CI loops over them).

```bash
for t in templates/*/; do (cd "$t" && flutter pub get && flutter analyze && flutter test); done

# After editing a template's doc/ folder:
./tool/sync_template_docs.sh

# After changing how a template looks, regenerate the gallery screenshots:
CAPTURE_SCREENSHOTS=1 FLUTTER_ROOT=<flutter sdk> \
  flutter test test/capture_template_screenshots_test.dart
```

## Licence

MIT — see [LICENSE](LICENSE). Third-party attribution is in
[NOTICE.md](NOTICE.md).

## Roadmap

Planned, not built. Nothing in the `cairn_ui` package depends on any of it.

- **More templates** — authentication screens, a chat app, onboarding and
  settings, alongside the five that exist today.
- **Paid templates** — Cairn Site will sell its templates. Payments, licensing
  and delivery are to be set up later; the e-commerce template is a free
  preview until then.
- **A Cairn MCP server** — an MCP server for `cairn_ui`, so an AI assistant can
  look up components, tokens and exact snippets instead of guessing the API.

Template photographs are from [Pexels](https://www.pexels.com); see
[NOTICE.md](NOTICE.md).
