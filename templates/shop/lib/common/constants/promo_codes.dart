/// The promo codes the shop accepts, and what each is worth.
///
/// Codes are matched case-insensitively. In a real shop the backend owns this
/// table; keep it here only while the catalogue is local.
abstract final class PromoCodes {
  /// Percent off the subtotal, by upper-case code.
  static const Map<String, int> percentOff = <String, int>{'CAIRN10': 10};

  /// A code worth trying, shown as a hint in the cart.
  static const String hint = 'CAIRN10';
}
