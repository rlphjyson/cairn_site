import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'src/app/app.dart';

void main() {
  // Clean `/components/button` URLs instead of `/#/components/button`.
  //
  // GitHub Pages has no SPA rewrite rule, so a hard refresh on a deep path
  // would normally 404. The deploy workflow copies `index.html` to `404.html`,
  // which Pages serves for any unmatched path; because that document carries
  // the same `<base href>`, the app boots, reads `window.location.pathname`,
  // and routes to the requested page. See .github/workflows/deploy.yml.
  usePathUrlStrategy();
  runApp(const CairnSiteApp());
}
