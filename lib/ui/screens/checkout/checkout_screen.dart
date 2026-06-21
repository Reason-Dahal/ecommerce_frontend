import 'package:ecommerce_frontend/core/constants/app_colors.dart';
import 'package:ecommerce_frontend/core/utils/price_formatter.dart';
import 'package:ecommerce_frontend/models/product_model.dart';
import 'package:ecommerce_frontend/services/order_service.dart';
import 'package:ecommerce_frontend/ui/screens/checkout/widgets/checkout_item_summary.dart';
import 'package:ecommerce_frontend/ui/screens/orders/my_orders_screen.dart';
import 'package:ecommerce_frontend/ui/screens/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:ecommerce_frontend/core/constants.dart';

/// "Buy Now" checkout — single product, quantity chosen on the
/// product detail screen. Collects shipping info and calls
/// OrderService.createOrder().
class CheckoutScreen extends StatefulWidget {
  final ProductModel product;
  final int quantity;

  const CheckoutScreen({
    super.key,
    required this.product,
    required this.quantity,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _orderService = OrderService();

  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isPlacingOrder = false;

  double get _total => (widget.product.price * widget.quantity).toDouble();

  @override
  void dispose() {
    _cityController.dispose();
    _postalCodeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isPlacingOrder = true);

    try {
      await _orderService.createOrder(
        orderItems: [
          {
            "name": widget.product.name,
            "quantity": widget.quantity,
            "price": widget.product.price,
            "productRef": widget.product.id,
          },
        ],
        city: _cityController.text.trim(),
        postalCode: int.parse(_postalCodeController.text.trim()),
        phone: int.parse(_phoneController.text.trim()),
        totalPrice: _total,
      );

      if (!mounted) return;

      // Show confirmation, then send the user to their order list.
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _OrderSuccessDialog(
          onDone: () {
            Navigator.pop(context); // close dialog
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
              (route) => route.isFirst,
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
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: const Text(
          'Checkout',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const _SectionLabel(text: 'Order Summary'),
            const SizedBox(height: 10),
            CheckoutItemSummary(
              productName: widget.product.name,
              imageUrl: widget.product.url,
              quantity: widget.quantity,
              unitPrice: (widget.product.price.toDouble()),
            ),
            const SizedBox(height: 24),
            const _SectionLabel(text: 'Shipping Details'),
            const SizedBox(height: 10),
            AppTextField(
              label: 'City',
              controller: _cityController,
              inputFormatters: [LengthLimitingTextInputFormatter(50)],
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'City is required' : null,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Postal Code',
              controller: _postalCodeController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              validator: (v) {
                if (v == null || v.trim().isEmpty)
                  return 'Postal code is required';
                if (int.tryParse(v.trim()) == null)
                  return 'Enter a valid postal code';
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Phone Number',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              validator: (v) {
                if (v == null || v.trim().isEmpty)
                  return 'Phone number is required';
                if (v.trim().length != 10)
                  return 'Phone number must be exactly 10 digits';
                return null;
              },
            ),
            const SizedBox(height: 28),
            _TotalRow(total: _total),
            const SizedBox(height: 20),
            _PlaceOrderButton(isLoading: _isPlacingOrder, onTap: _placeOrder),
          ],
        ),
      ),
    );
  }
}

// ── Small private widgets ───────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final double total;
  const _TotalRow({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accent.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            PriceFormatter.format(total),
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceOrderButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _PlaceOrderButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
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
                  'Place Order',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}

class _OrderSuccessDialog extends StatelessWidget {
  final VoidCallback onDone;

  const _OrderSuccessDialog({required this.onDone});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 48),
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
