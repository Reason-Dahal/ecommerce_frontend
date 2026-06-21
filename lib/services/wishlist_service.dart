import 'dart:convert';
import 'package:ecommerce_frontend/models/product_model.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local wishlist backed by SharedPreferences.
///
/// [wishlistCount] is a global ValueNotifier for reactive UI updates.
/// Call [WishlistService.instance.init()] in main() after init.
class WishlistService {
  WishlistService._();
  static final WishlistService instance = WishlistService._();

  static const _key = 'local_wishlist';

  static final wishlistCount = ValueNotifier<int>(0);

  // ── Init ──────────────────────────────────────────────────────────────────────

  Future<void> init() async {
    final items = await getWishlist();
    wishlistCount.value = items.length;
  }

  // ── Read ──────────────────────────────────────────────────────────────────────

  Future<List<ProductModel>> getWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final List decoded = jsonDecode(raw);
      // Stored as flat product maps, not the API's nested shape
      return decoded.map((e) => ProductModel.fromCache(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> isInWishlist(String productId) async {
    final items = await getWishlist();
    return items.any((p) => p.id == productId);
  }

  /// Adds if not present, removes if present.
  /// Returns true if the product is now in the wishlist.
  Future<bool> toggle(ProductModel product) async {
    final items = await getWishlist();
    final exists = items.any((p) => p.id == product.id);
    if (exists) {
      items.removeWhere((p) => p.id == product.id);
    } else {
      items.add(product);
    }
    await _save(items);
    return !exists;
  }

  Future<void> remove(String productId) async {
    final items = await getWishlist();
    items.removeWhere((p) => p.id == productId);
    await _save(items);
  }

  // ── Internal ──────────────────────────────────────────────────────────────────

  Future<void> _save(List<ProductModel> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(items.map((p) => p.toCache()).toList()),
    );
    wishlistCount.value = items.length;
  }
}
