import '../mappers/cart_mapper.dart';
import '../models/promo_code.dart';
import '../repositories/cart_repository.dart';

/// Validates a typed code and, when it is good, applies it to the cart.
class ApplyPromoCode {
  /// Creates the use case.
  const ApplyPromoCode(this._repository);

  final CartRepository _repository;

  /// Runs it. Returns the applied code, or `null` when [input] is not valid
  /// (in which case the cart is left as it was).
  Future<PromoCode?> call(String input) async {
    final PromoCode? promo = CartMapper.promoFromCode(input);
    if (promo == null) return null;
    await _repository.setPromo(promo);
    return promo;
  }
}
