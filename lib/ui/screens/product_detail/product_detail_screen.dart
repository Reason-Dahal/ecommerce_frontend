import 'package:ecommerce_frontend/core/constants/app_colors.dart';
import 'package:ecommerce_frontend/ui/screens/product_detail/widgets/product_hero_image.dart';
import 'package:ecommerce_frontend/ui/screens/product_detail/widgets/product_info_panel.dart';
import 'package:ecommerce_frontend/ui/screens/product_detail/widgets/related_products_section.dart';
import 'package:ecommerce_frontend/models/product_model.dart';
import 'package:ecommerce_frontend/services/product_service.dart';
import 'package:ecommerce_frontend/shared/widgets/app_states.dart';
import 'package:flutter/material.dart';

/// Shows a single product (top ~45% image + details) followed by a
/// horizontal "related products" list pulled from getAllProduct().
class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _productService = ProductService();

  late Future<ProductModel> _futureProduct;
  late Future<List<ProductModel>> _futureAllProducts;

  @override
  void initState() {
    super.initState();
    _futureProduct = _productService.getProductById(widget.productId);
    _futureAllProducts = _productService.getAllProduct();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: FutureBuilder<ProductModel>(
        future: _futureProduct,
        builder: (context, productSnapshot) {
          if (productSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }
          if (productSnapshot.hasError) {
            return AppErrorState(error: productSnapshot.error.toString());
          }
          if (!productSnapshot.hasData) {
            return const AppEmptyState(message: 'Product not found');
          }

          final product = productSnapshot.data!;

          return CustomScrollView(
            slivers: [
              ProductHeroImage(product: product),
              ProductInfoPanel(product: product),
              _RelatedProductsLoader(
                futureAllProducts: _futureAllProducts,
                currentProductId: product.id,
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
            ],
          );
        },
      ),
    );
  }
}

/// Wraps RelatedProductsSection in its own FutureBuilder so a slow/failed
/// "all products" call never blocks the main product detail from rendering.
class _RelatedProductsLoader extends StatelessWidget {
  final Future<List<ProductModel>> futureAllProducts;
  final String currentProductId;

  const _RelatedProductsLoader({
    required this.futureAllProducts,
    required this.currentProductId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProductModel>>(
      future: futureAllProducts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
        return RelatedProductsSection(
          allProducts: snapshot.data!,
          currentProductId: currentProductId,
        );
      },
    );
  }
}
