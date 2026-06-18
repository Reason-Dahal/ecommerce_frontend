import 'package:ecommerce_frontend/core/constants/app_colors.dart';
import 'package:ecommerce_frontend/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_frontend/core/constants.dart';

/// Takes up 45 % of screen height. Renders the product image full-bleed
/// with a back button, stock badge, and a gradient fade into the bg colour.
class ProductHeroImage extends StatelessWidget {
  final ProductModel product;

  const ProductHeroImage({super.key, required this.product});

  Color get _stockColor {
    if (product.stock == 0) return Colors.red;
    if (product.stock <= 3) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final imageHeight = MediaQuery.of(context).size.height * 0.45;

    return SliverToBoxAdapter(
      child: SizedBox(
        height: imageHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              "${ApiConstants.imageUrl}/${product.url}",
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.imageShimmer,
                child: const Icon(
                  Icons.broken_image,
                  color: Color(0xFF444444),
                  size: 48,
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

            // ── Bottom gradient: image fades into page background ───────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 120,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, AppColors.bg],
                  ),
                ),
              ),
            ),

            // ── Back button ─────────────────────────────────────────────────
            Positioned(top: topPad + 10, left: 14, child: _BackButton()),

            // ── Stock badge ─────────────────────────────────────────────────
            Positioned(
              top: topPad + 10,
              right: 14,
              child: _StockBadge(stock: product.stock, color: _stockColor),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Private widgets ───────────────────────────────────────────────────────────

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.55),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  final int stock;
  final Color color;

  const _StockBadge({required this.stock, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.88),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        stock == 0 ? 'Out of stock' : '$stock in stock',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
