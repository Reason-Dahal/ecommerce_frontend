import 'package:ecommerce_frontend/core/constants/app_colors.dart';
import 'package:ecommerce_frontend/models/product_model.dart';
import 'package:ecommerce_frontend/services/cart_service.dart';
import 'package:ecommerce_frontend/services/wishlist_service.dart';
import 'package:ecommerce_frontend/ui/screens/product_detail/product_detail_screen.dart';
import 'package:flutter/material.dart';
// import 'package:ecommerce_frontend/core/constants.dart';

class ProductCard extends StatefulWidget {
  final ProductModel product;
  final String Function(num) formatPrice;

  const ProductCard({
    super.key,
    required this.product,
    required this.formatPrice,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  // ignore: unused_field
  bool _inWishlist = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final result = await WishlistService.instance.isInWishlist(
      widget.product.id,
    );
    if (mounted) setState(() => _inWishlist = result);
  }

  // ignore: unused_element
  Future<void> _toggleWishlist() async {
    final isNow = await WishlistService.instance.toggle(widget.product);
    if (mounted) setState(() => _inWishlist = isNow);
  }

  // ignore: unused_element
  Color get _stockColor {
    if (widget.product.stock == 0) return Colors.red;
    if (widget.product.stock <= 3) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(productId: product.id),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 55, child: _buildImage(product)),
            Expanded(flex: 45, child: _buildInfo(product)),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(ProductModel product) {
    final imageUrl = product.url;

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: AppColors.imageShimmer,
            child: const Icon(
              Icons.broken_image,
              color: Color(0xFF444444),
              size: 32,
            ),
          ),
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return Container(
              color: AppColors.imageShimmer,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.accent,
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded /
                            progress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
        ),
        // ...rest of the Stack (gradient, stock badge, wishlist heart) stays unchanged
      ],
    );
  }

  Widget _buildInfo(ProductModel product) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.category.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.formatPrice(product.price),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              // Quick add-to-cart
              GestureDetector(
                onTap: () async {
                  await CartService.instance.addToCart(product);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} added to cart'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
