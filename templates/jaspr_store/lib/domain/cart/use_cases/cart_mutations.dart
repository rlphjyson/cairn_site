library;

import '../../../common/constants.dart';
import '../../../core/config/store_config.dart';
import '../../../core/result.dart';
import '../../catalog/catalog_repository.dart';
import '../cart_repository.dart';
import '../models/cart.dart';

/// Result of a cart mutation. [adjusted] is true when the requested quantity
/// had to be clamped (stock or per-line maximum) so the UI can say so.
class CartChange {
  const CartChange(this.cart, {this.adjusted = false});
  final Cart cart;
  final bool adjusted;
}

/// Cart lookup. GET pages only ever [find] (a visitor browsing the catalogue
/// must not cost the server a cart); mutations use [findOrCreate]. When the
/// returned cart's id differs from [cartId], the caller issues a new cookie.
class LoadCart {
  const LoadCart(this._carts);
  final CartRepository _carts;

  Future<Cart?> find(String? cartId) async => cartId == null ? null : _carts.find(cartId);

  Future<Cart> findOrCreate(String? cartId) async => (await find(cartId)) ?? await _carts.create();
}

class AddToCart {
  const AddToCart(this._catalog, this._carts);
  final CatalogRepository _catalog;
  final CartRepository _carts;

  Future<Result<CartChange>> call(
    Cart cart, {
    required String productId,
    required String variantId,
    int quantity = 1,
  }) async {
    final product = await _catalog.productById(productId);
    if (product == null) return const Result.err(Failure('unknown_product', 'That product is no longer available.'));
    final variant = product.variantById(variantId);
    if (variant == null) return const Result.err(Failure('unknown_variant', 'Please choose an available option.'));
    if (!variant.inStock) return const Result.err(Failure('out_of_stock', 'Sorry, that option is sold out.'));
    if (quantity < 1) return const Result.err(Failure('bad_quantity', 'Quantity must be at least 1.'));

    final lines = [...cart.lines];
    final index = lines.indexWhere((l) => l.variantId == variantId);
    final existing = index >= 0 ? lines[index].quantity : 0;
    if (index < 0 && lines.length >= kMaxCartLines) {
      return const Result.err(Failure('cart_full', 'Your cart is full.'));
    }
    final limit = _limit(variant.stock);
    final wanted = existing + quantity;
    final finalQty = wanted > limit ? limit : wanted;
    final adjusted = wanted > limit;
    if (index >= 0) {
      lines[index] = lines[index].withQuantity(finalQty);
    } else {
      lines.add(CartLine(productId: productId, variantId: variantId, quantity: finalQty));
    }
    final saved = cart.copyWith(lines: lines, updatedAt: DateTime.now().toUtc());
    await _carts.save(saved);
    return Result.ok(CartChange(saved, adjusted: adjusted));
  }
}

int _limit(int stock) => stock < kMaxLineQuantity ? stock : kMaxLineQuantity;

class UpdateLineQuantity {
  const UpdateLineQuantity(this._catalog, this._carts);
  final CatalogRepository _catalog;
  final CartRepository _carts;

  /// A quantity of 0 (or less) removes the line.
  Future<Result<CartChange>> call(Cart cart, {required String variantId, required int quantity}) async {
    final index = cart.lines.indexWhere((l) => l.variantId == variantId);
    if (index < 0) return const Result.err(Failure('not_in_cart', 'That item is not in your cart.'));
    final lines = [...cart.lines];
    var adjusted = false;
    if (quantity <= 0) {
      lines.removeAt(index);
    } else {
      final product = await _catalog.productById(lines[index].productId);
      final variant = product?.variantById(variantId);
      final limit = variant == null ? kMaxLineQuantity : _limit(variant.stock);
      var q = quantity;
      if (q > limit) {
        q = limit;
        adjusted = true;
      }
      if (q <= 0) {
        lines.removeAt(index);
      } else {
        lines[index] = lines[index].withQuantity(q);
      }
    }
    final saved = cart.copyWith(lines: lines, updatedAt: DateTime.now().toUtc());
    await _carts.save(saved);
    return Result.ok(CartChange(saved, adjusted: adjusted));
  }
}

class RemoveFromCart {
  const RemoveFromCart(this._carts);
  final CartRepository _carts;

  Future<Cart> call(Cart cart, String variantId) async {
    final saved = cart.copyWith(
      lines: cart.lines.where((l) => l.variantId != variantId).toList(),
      updatedAt: DateTime.now().toUtc(),
    );
    await _carts.save(saved);
    return saved;
  }
}

class ApplyPromo {
  const ApplyPromo(this._config, this._carts);
  final StoreConfig _config;
  final CartRepository _carts;

  Future<Result<Cart>> call(Cart cart, String code) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty) return const Result.err(Failure('empty_promo', 'Enter a promo code.'));
    final promo = _config.findPromo(trimmed);
    if (promo == null) return const Result.err(Failure('invalid_promo', "That code isn't valid."));
    final saved = cart.copyWith(promoCode: promo.code, updatedAt: DateTime.now().toUtc());
    await _carts.save(saved);
    return Result.ok(saved);
  }

  Future<Cart> clear(Cart cart) async {
    final saved = cart.copyWith(clearPromo: true, updatedAt: DateTime.now().toUtc());
    await _carts.save(saved);
    return saved;
  }
}

class ClearCart {
  const ClearCart(this._carts);
  final CartRepository _carts;

  Future<void> call(Cart cart) => _carts.delete(cart.id);
}
