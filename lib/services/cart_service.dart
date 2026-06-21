import 'dart:convert';
import 'package:ecommerce_frontend/models/cart_item_model.dart';
import 'package:ecommerce_frontend/models/product_model.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local cart backed by SharedPreferences.
///
/// [itemCount] is a global ValueNotifier — listen to it in the app bar
/// to reactively update the badge without rebuilding the whole tree.
///
/// Call [CartService.instance.init()] in main() after WidgetsFlutterBinding
/// is initialized so the badge count is correct on first load.
class CartService {
  CartService._();
  static final CartService instance = CartService._();

  static const _key = 'local_cart';

  /// Total number of *units* (not distinct products) in the cart.
  static final itemCount = ValueNotifier<int>(0);

  // ── Init ─────────────────────────────────────────────────────────────────────

  Future<void> init() async {
    final items = await getCartItems();
    itemCount.value = _totalUnits(items);
  }

  // ── Read ─────────────────────────────────────────────────────────────────────

  Future<List<CartItemModel>> getCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final List decoded = jsonDecode(raw);
      return decoded.map((e) => CartItemModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> isInCart(String productId) async {
    final items = await getCartItems();
    return items.any((i) => i.productId == productId);
  }

  // ── Write ─────────────────────────────────────────────────────────────────────

  /// Adds [product] to cart. If it already exists, increments quantity.
  Future<void> addToCart(ProductModel product, {int quantity = 1}) async {
    final items = await getCartItems();
    final index = items.indexWhere((i) => i.productId == product.id);

    if (index >= 0) {
      items[index] = items[index].copyWith(
        quantity: items[index].quantity + quantity,
      );
    } else {
      items.add(CartItemModel.fromProduct(product, quantity: quantity));
    }

    await _save(items);
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(productId);
      return;
    }
    final items = await getCartItems();
    final index = items.indexWhere((i) => i.productId == productId);
    if (index >= 0) {
      items[index] = items[index].copyWith(quantity: quantity);
      await _save(items);
    }
  }

  Future<void> removeFromCart(String productId) async {
    final items = await getCartItems();
    items.removeWhere((i) => i.productId == productId);
    await _save(items);
  }

  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    itemCount.value = 0;
  }

  // ── Internal ─────────────────────────────────────────────────────────────────

  Future<void> _save(List<CartItemModel> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
    itemCount.value = _totalUnits(items);
  }

  int _totalUnits(List<CartItemModel> items) =>
      items.fold(0, (sum, i) => sum + i.quantity);
}
