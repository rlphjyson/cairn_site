# Notices and third-party attribution

`cairn_site` is released under the MIT Licence; see [LICENSE](LICENSE).

## What this repository is

The marketing and documentation site for
[Cairn UI](https://github.com/rlphjyson/cairn_ui), built as a Flutter web app
**with Cairn UI itself**. It is an independent project and is not affiliated
with, sponsored by or endorsed by shadcn/ui, Radix UI or Vercel.

## Design inspiration

- **[shadcn/ui](https://ui.shadcn.com)** by [shadcn](https://github.com/shadcn)
  — this site's information architecture follows shadcn/ui's own site: the same
  seven top-level sections, the preview/code pattern on every example, the docs
  sidebar plus "On this page" rail. **All prose, code and layout here is
  original**; what was taken is the structure and the interaction patterns, not
  the content.
- **[Radix UI](https://www.radix-ui.com)** — the accessibility behaviour
  documented on the Accessibility page, which Cairn reproduces in Flutter.

## Bundled assets

- **[Geist](https://vercel.com/font)**, Copyright (c) 2023 Vercel, Inc.
  The four static faces under `fonts/` are the same files Cairn UI bundles for
  its golden tests. Licensed under the SIL Open Font License 1.1 — full text at
  [`fonts/OFL.txt`](fonts/OFL.txt).

## Redrawn artwork

- **[Lucide](https://lucide.dev)** — the icons in
  `lib/src/widgets/site_icons.dart` are drawn with a `CustomPainter` following
  Lucide's geometry (24×24 grid, 2px stroke, round caps and joins). No Lucide
  files are included. Lucide is ISC licensed.

## Dependencies

| Package | Licence | Why |
| --- | --- | --- |
| [cairn_ui](https://github.com/rlphjyson/cairn_ui) | MIT | The library this site documents, and the library this site is built with |
| [go_router](https://pub.dev/packages/go_router) | BSD-3-Clause | URL-based routing, so every section is a real, shareable link |
| [fl_chart](https://pub.dev/packages/fl_chart) | MIT | The Charts page. Cairn ships no chart widgets — see `lib/src/charts/chart_theme.dart` for the reasoning |
| [url_launcher](https://pub.dev/packages/url_launcher) | BSD-3-Clause | Off-site links |
