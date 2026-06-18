import 'package:ecommerce_frontend/core/constants/app_colors.dart';
import 'package:ecommerce_frontend/core/utils/price_formatter.dart';
import 'package:ecommerce_frontend/models/cart_item_model.dart';
import 'package:ecommerce_frontend/services/cart_service.dart';
import 'package:ecommerce_frontend/services/order_service.dart';
import 'package:ecommerce_frontend/shared/widgets/app_states.dart';
import 'package:ecommerce_frontend/ui/screens/cart/widgets/cart_item_tile.dart';
import 'package:ecommerce_frontend/ui/screens/orders/my_orders_screen.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _cart = CartService.instance;
  final _orderService = OrderService();

  List<CartItemModel> _items = [];
  bool _loading = true;
  bool _placingOrder = false;

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

  Future<void> _placeOrder() async {
    if (_items.isEmpty) return;
    setState(() => _placingOrder = true);

    try {
      // Collect shipping info via a dialog before placing order.
      final shipping = await _showShippingDialog();
      if (shipping == null) {
        setState(() => _placingOrder = false);
        return;
      }

      await _orderService.createOrder(
        orderItems: _items
            .map(
              (i) => {
                'name': i.name,
                'quantity': i.quantity,
                'price': i.price,
                'productRef': i.productId,
              },
            )
            .toList(),
        city: shipping['city']!,
        postalCode: int.parse(shipping['postalCode']!),
        phone: int.parse(shipping['phone']!),
        totalPrice: _total,
      );

      await _cart.clearCart();
      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _SuccessDialog(
          onDone: () {
            Navigator.pop(context); // close dialog
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
            );
          },
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _placingOrder = false);
    }
  }

  /// Shows a simple dialog to collect city / postal code / phone.
  Future<Map<String, String>?> _showShippingDialog() async {
    final cityCtrl = TextEditingController();
    final postalCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Shipping Details',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DialogField(
                label: 'City',
                controller: cityCtrl,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              _DialogField(
                label: 'Postal Code',
                controller: postalCtrl,
                type: TextInputType.number,
                validator: (v) => (v!.isEmpty || int.tryParse(v) == null)
                    ? 'Enter valid postal code'
                    : null,
              ),
              const SizedBox(height: 12),
              _DialogField(
                label: 'Phone',
                controller: phoneCtrl,
                type: TextInputType.phone,
                validator: (v) => (v!.isEmpty || int.tryParse(v) == null)
                    ? 'Enter valid phone'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, {
                  'city': cityCtrl.text.trim(),
                  'postalCode': postalCtrl.text.trim(),
                  'phone': phoneCtrl.text.trim(),
                });
              }
            },
            child: const Text(
              'Confirm',
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    cityCtrl.dispose();
    postalCtrl.dispose();
    phoneCtrl.dispose();

    return result;
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
                  isLoading: _placingOrder,
                  onCheckout: _placeOrder,
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
  final bool isLoading;
  final VoidCallback onCheckout;

  const _CartSummary({
    required this.total,
    required this.itemCount,
    required this.isLoading,
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
            onTap: isLoading ? null : onCheckout,
            child: Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
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

// ── Dialog helpers ────────────────────────────────────────────────────────────

class _DialogField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType type;
  final String? Function(String?)? validator;

  const _DialogField({
    required this.label,
    required this.controller,
    this.type = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      validator: validator,
      decoration: InputDecoration(
        hintText: label,
        hintStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        filled: true,
        fillColor: AppColors.bg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}

class _SuccessDialog extends StatelessWidget {
  final VoidCallback onDone;
  const _SuccessDialog({required this.onDone});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 52),
          const SizedBox(height: 14),
          const Text(
            'Order Placed!',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your order has been placed successfully.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onDone,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'View My Orders',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
