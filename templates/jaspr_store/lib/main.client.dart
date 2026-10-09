/// The **client** entrypoint. It hydrates only the `@client` islands:
/// `ThemeToggle`, `CartLink` and `AddToCartButton`. Everything else on every
/// page is static HTML that needed no JavaScript to be useful.
///
/// Nothing reachable from this file may import `dart:io`.
library;

import 'package:jaspr/client.dart';

import 'main.client.options.dart';

void main() {
  Jaspr.initializeApp(options: defaultClientOptions);
  runApp(const ClientApp());
}
