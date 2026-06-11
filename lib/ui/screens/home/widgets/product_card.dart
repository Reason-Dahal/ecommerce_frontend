import 'package:ecommerce_frontend/core/constants/app_colors.dart';
import 'package:ecommerce_frontend/models/product_model.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final String Function(num) formatPrice;

  const ProductCard({
    super.key,
    required this.product,
    required this.formatPrice,
  });

  Color get _stockColor {
    if (product.stock == 0) return Colors.red;
    if (product.stock <= 3) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigator.push to ProductDetailScreen
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 55,
              child: _ProductImage(product: product, stockColor: _stockColor),
            ),
            Expanded(
              flex: 45,
              child: _ProductInfo(product: product, formatPrice: formatPrice),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Private sub-widgets ────────────────────────────────────────────────────────

class _ProductImage extends StatelessWidget {
  final ProductModel product;
  final Color stockColor;

  const _ProductImage({required this.product, required this.stockColor});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _NetworkImage(url: product.url),
        _BottomGradient(),
        _StockBadge(stock: product.stock, color: stockColor),
        const _WishlistButton(),
      ],
    );
  }
}

class _NetworkImage extends StatelessWidget {
  final String url;
  const _NetworkImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
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
    );
  }
}

class _BottomGradient extends StatelessWidget {
  const _BottomGradient();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, AppColors.surface.withOpacity(0.9)],
          ),
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
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          stock == 0 ? 'Out' : '$stock left',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _WishlistButton extends StatelessWidget {
  const _WishlistButton();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 4,
      left: 4,
      child: IconButton(
        onPressed: () {},
        icon: const Icon(
          Icons.favorite_border,
          color: Colors.white70,
          size: 18,
        ),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }
}

class _ProductInfo extends StatelessWidget {
  final ProductModel product;
  final String Function(num) formatPrice;

  const _ProductInfo({required this.product, required this.formatPrice});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CategoryAndName(product: product),
          _PriceRow(price: product.price, formatPrice: formatPrice),
        ],
      ),
    );
  }
}

class _CategoryAndName extends StatelessWidget {
  final ProductModel product;
  const _CategoryAndName({required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}

class _PriceRow extends StatelessWidget {
  final num price;
  final String Function(num) formatPrice;

  const _PriceRow({required this.price, required this.formatPrice});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          formatPrice(price),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        GestureDetector(
          onTap: () {
            // TODO: Add to cart
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
    );
  }
}
