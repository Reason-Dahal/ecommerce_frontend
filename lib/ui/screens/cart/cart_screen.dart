import 'package:ecommerce_frontend/core/constants/app_colors.dart';
import 'package:ecommerce_frontend/core/utils/price_formatter.dart';
import 'package:ecommerce_frontend/models/cart_item_model.dart';
import 'package:ecommerce_frontend/services/cart_service.dart';
import 'package:ecommerce_frontend/shared/widgets/app_states.dart';
import 'package:ecommerce_frontend/ui/screens/cart/widgets/cart_item_tile.dart';
import 'package:ecommerce_frontend/ui/screens/checkout/cart_checkout_screen.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _cart = CartService.instance;

  List<CartItemModel> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final items = await _cart.getCartItems();
    if (mounted)
      setState(() {
        _items = items;
        _loading = false;
      });
  }

  double get _total => _items.fold(0, (sum, i) => sum + i.total);

  Future<void> _updateQty(String productId, int qty) async {
    await _cart.updateQuantity(productId, qty);
    _loadCart();
  }

  Future<void> _remove(String productId) async {
    await _cart.removeFromCart(productId);
    _loadCart();
  }

  Future<void> _goToCheckout() async {
    if (_items.isEmpty) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CartCheckoutScreen(items: List.of(_items)),
      ),
    );

    // In case the user backs out without completing the order, refresh
    // the cart in case anything changed in the meantime.
    if (mounted) _loadCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: const Text(
          'My Cart',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          if (_items.isNotEmpty)
            TextButton(
              onPressed: () async {
                await _cart.clearCart();
                _loadCart();
              },
              child: const Text(
                'Clear',
                style: TextStyle(color: Colors.redAccent, fontSize: 13),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            )
          : _items.isEmpty
          ? const AppEmptyState(
              message: 'Your cart is empty',
              icon: Icons.shopping_cart_outlined,
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    itemCount: _items.length,
                    itemBuilder: (_, i) => CartItemTile(
                      item: _items[i],
                      onRemove: () => _remove(_items[i].productId),
                      onQuantityChanged: (q) =>
                          _updateQty(_items[i].productId, q),
                    ),
                  ),
                ),
                _CartSummary(
                  total: _total,
                  itemCount: _items.length,
                  onCheckout: _goToCheckout,
                ),
              ],
            ),
    );
  }
}

// ── Summary bar ──────────────────────────────────────────────────────────────

class _CartSummary extends StatelessWidget {
  final double total;
  final int itemCount;
  final VoidCallback onCheckout;

  const _CartSummary({
    required this.total,
    required this.itemCount,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              Text(
                PriceFormatter.format(total),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: onCheckout,
            child: Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text(
                  'Proceed to Checkout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
