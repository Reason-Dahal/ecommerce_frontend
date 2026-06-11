import 'package:ecommerce_frontend/core/constants/app_colors.dart';
import 'package:ecommerce_frontend/core/utils/price_formatter.dart';
import 'package:ecommerce_frontend/ui/screens/home/widgets/product_card.dart';
import 'package:ecommerce_frontend/models/product_model.dart';
import 'package:flutter/material.dart';

class ProductGrid extends StatelessWidget {
  final List<ProductModel> products;

  const ProductGrid({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const _NoResultsState();

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, i) => ProductCard(
            product: products[i],
            formatPrice: PriceFormatter.format,
          ),
          childCount: products.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.70,
        ),
      ),
    );
  }
}

class _NoResultsState extends StatelessWidget {
  const _NoResultsState();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 80),
          child: Column(
            children: [
              Icon(
                Icons.search_off,
                color: AppColors.textSecondary.withOpacity(0.3),
                size: 56,
              ),
              const SizedBox(height: 12),
              const Text(
                'No products match your filters',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
