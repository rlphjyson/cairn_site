# Notices and third-party attribution

`cairn_site` is released under the MIT Licence; see [LICENSE](LICENSE).

## What this repository is

The marketing and documentation site for
[Cairn UI](https://github.com/rlphjyson/cairn_ui), built as a Flutter web app
**with Cairn UI itself**. It is an independent open-source project and is not
affiliated with, sponsored by or endorsed by Vercel or Lucide.

## Bundled assets

- **[Geist](https://vercel.com/font)**, Copyright (c) 2023 Vercel, Inc.
  The four static faces under `fonts/` are the same files Cairn UI bundles for
  its golden tests. Licensed under the SIL Open Font License 1.1 — full text at
  [`fonts/OFL.txt`](fonts/OFL.txt).

- **Photographs** under `assets/images/`, used by the e-commerce template, are
  from [Pexels](https://www.pexels.com) and used under the
  [Pexels licence](https://www.pexels.com/license/) (free for commercial use,
  no attribution required). They are product shots of sneakers, headphones,
  watches and eyewear; any brand marks visible in them belong to their owners.

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
