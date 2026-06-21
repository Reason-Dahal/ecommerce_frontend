import 'package:ecommerce_frontend/core/constants/app_colors.dart';
import 'package:ecommerce_frontend/core/utils/price_formatter.dart';
import 'package:ecommerce_frontend/models/product_model.dart';
import 'package:ecommerce_frontend/services/cart_service.dart';
import 'package:ecommerce_frontend/services/wishlist_service.dart';
import 'package:ecommerce_frontend/ui/screens/checkout/checkout_screen.dart';
import 'package:flutter/material.dart';

class ProductInfoPanel extends StatefulWidget {
  final ProductModel product;
  const ProductInfoPanel({super.key, required this.product});

  @override
  State<ProductInfoPanel> createState() => _ProductInfoPanelState();
}

class _ProductInfoPanelState extends State<ProductInfoPanel> {
  int _quantity = 1;
  bool _inWishlist = false;
  bool _wishlistLoading = false;

  ProductModel get p => widget.product;

  @override
  void initState() {
    super.initState();
    _checkWishlist();
  }

  Future<void> _checkWishlist() async {
    final result = await WishlistService.instance.isInWishlist(p.id);
    if (mounted) setState(() => _inWishlist = result);
  }

  Future<void> _toggleWishlist() async {
    setState(() => _wishlistLoading = true);
    final isNowInWishlist = await WishlistService.instance.toggle(p);
    if (mounted) {
      setState(() {
        _inWishlist = isNowInWishlist;
        _wishlistLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isNowInWishlist ? 'Added to wishlist' : 'Removed from wishlist',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _addToCart() async {
    await CartService.instance.addToCart(p, quantity: _quantity);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${p.name} added to cart'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _buyNow() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(product: p, quantity: _quantity),
      ),
    );
  }

  void _increment() {
    if (_quantity < p.stock) setState(() => _quantity++);
  }

  void _decrement() {
    if (_quantity > 1) setState(() => _quantity--);
  }

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = p.stock == 0;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category + wishlist row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  p.category.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                _WishlistButton(
                  isInWishlist: _inWishlist,
                  isLoading: _wishlistLoading,
                  onTap: _toggleWishlist,
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Name
            Text(
              p.name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w700,
                height: 1.2,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 14),
            // Price + stock
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  PriceFormatter.format(p.price),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                _StockIndicator(stock: p.stock),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: AppColors.surface, thickness: 1.2),
            const SizedBox(height: 16),
            // Quantity
            if (!isOutOfStock) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Quantity',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  _QuantitySelector(
                    quantity: _quantity,
                    onIncrement: _increment,
                    onDecrement: _decrement,
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
            // CTAs
            _ActionButtons(
              isOutOfStock: isOutOfStock,
              onAddToCart: _addToCart,
              onBuyNow: _buyNow,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Wishlist button ───────────────────────────────────────────────────────────

class _WishlistButton extends StatelessWidget {
  final bool isInWishlist;
  final bool isLoading;
  final VoidCallback onTap;

  const _WishlistButton({
    required this.isInWishlist,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isInWishlist
              ? Colors.redAccent.withOpacity(0.12)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: isLoading
            ? const Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.redAccent,
                  ),
                ),
              )
            : Icon(
                isInWishlist ? Icons.favorite : Icons.favorite_border,
                color: isInWishlist
                    ? Colors.redAccent
                    : AppColors.textSecondary,
                size: 18,
              ),
      ),
    );
  }
}

// ── Stock indicator ───────────────────────────────────────────────────────────

class _StockIndicator extends StatelessWidget {
  final int stock;
  const _StockIndicator({required this.stock});

  Color get _color {
    if (stock == 0) return Colors.red;
    if (stock <= 3) return Colors.orange;
    return Colors.green;
  }

  String get _label {
    if (stock == 0) return 'Out of stock';
    if (stock <= 3) return 'Only $stock left';
    return 'In stock';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          _label,
          style: TextStyle(
            color: _color,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ── Quantity selector ─────────────────────────────────────────────────────────

class _QuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _QuantitySelector({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _QtyBtn(icon: Icons.remove, onTap: onDecrement),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              '$quantity',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _QtyBtn(icon: Icons.add, onTap: onIncrement),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 18),
      ),
    );
  }
}

// ── Action buttons ────────────────────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  final bool isOutOfStock;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;

  const _ActionButtons({
    required this.isOutOfStock,
    required this.onAddToCart,
    required this.onBuyNow,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutOfStock) {
      return Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.remove_shopping_cart_outlined,
                color: AppColors.textSecondary,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'Out of Stock',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onAddToCart,
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.accent.withOpacity(0.4)),
              ),
              child: const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      color: AppColors.accent,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Add to Cart',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: onBuyNow,
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text(
                  'Buy Now',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
