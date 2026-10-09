/// The package that bundles the template's images.
///
/// When the template is used as a package (the default), images resolve as
/// `packages/cairn_template_shop/assets/images/...`. If you copy `lib/` and
/// `assets/` straight into your own app, set [name] to `null` and declare the
/// assets in your own `pubspec.yaml`.
abstract final class ShopPackage {
  /// The asset package. When the assets belong to the host app instead, change
  /// the value to `null`.
  // ignore: unnecessary_nullable_for_final_variable_declarations
  static const String? name = 'cairn_template_shop';
}
