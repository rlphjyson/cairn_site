/// The package that bundles the template's assets.
///
/// The template is typographic and currently ships no images. If you add some
/// under `assets/images/`, reference them with `package: DocsPackage.name`.
/// When you copy `lib/` and `assets/` into your own app, the images belong to
/// the host: pass `package: null` instead and declare them in your own
/// `pubspec.yaml`.
abstract final class DocsPackage {
  /// The asset package, or `null` when the assets belong to the host app.
  static const String name = 'cairn_template_docs';
}
