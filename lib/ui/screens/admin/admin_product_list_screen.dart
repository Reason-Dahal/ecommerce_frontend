import 'package:ecommerce_frontend/core/constants/app_colors.dart';
import 'package:ecommerce_frontend/ui/screens/admin/add_edit_product_screen.dart';
import 'package:ecommerce_frontend/ui/screens/admin/widgets/admin_product_tile.dart';
import 'package:ecommerce_frontend/ui/screens/admin/widgets/delete_confirm_dialog.dart';
import 'package:ecommerce_frontend/ui/screens/widgets/app_drawer.dart';
import 'package:ecommerce_frontend/models/product_model.dart';
import 'package:ecommerce_frontend/services/product_service.dart';
import 'package:ecommerce_frontend/shared/widgets/app_states.dart';
import 'package:flutter/material.dart';

/// Admin dashboard — lists every product with edit/delete actions and a
/// FAB to add a new one. Pull-to-refresh + search included.
class AdminProductListScreen extends StatefulWidget {
  const AdminProductListScreen({super.key});

  @override
  State<AdminProductListScreen> createState() => _AdminProductListScreenState();
}

class _AdminProductListScreenState extends State<AdminProductListScreen> {
  final _productService = ProductService();
  late Future<List<ProductModel>> _futureProducts;

  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    _futureProducts = _productService.getAllProduct();
  }

  Future<void> _refresh() async {
    setState(_loadProducts);
    await _futureProducts;
  }

  Future<void> _goToAddProduct() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddEditProductScreen()),
    );
    if (result == true) _refresh();
  }

  Future<void> _goToEditProduct(ProductModel product) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditProductScreen(existingProduct: product),
      ),
    );
    if (result == true) _refresh();
  }

  Future<void> _handleDelete(ProductModel product) async {
    final confirmed = await showDeleteConfirmDialog(context, product.name);
    if (!confirmed) return;

    try {
      await _productService.deleteProduct(product.id);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('"${product.name}" deleted')));
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  List<ProductModel> _applySearch(List<ProductModel> products) {
    if (_query.isEmpty) return products;
    return products
        .where((p) => p.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: const Text(
          'Manage Products',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        onPressed: _goToAddProduct,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: FutureBuilder<List<ProductModel>>(
        future: _futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }
          if (snapshot.hasError) {
            return AppErrorState(error: snapshot.error.toString());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const AppEmptyState(
              message: 'No products yet — tap + to add one',
            );
          }

          final products = _applySearch(snapshot.data!);

          return RefreshIndicator(
            color: AppColors.accent,
            backgroundColor: AppColors.surface,
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                _SearchField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _query = v),
                ),
                const SizedBox(height: 8),
                Text(
                  '${products.length} ${products.length == 1 ? 'product' : 'products'}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                if (products.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: AppEmptyState(
                      message: 'No products match your search',
                    ),
                  )
                else
                  ...products.map(
                    (p) => AdminProductTile(
                      product: p,
                      onEdit: () => _goToEditProduct(p),
                      onDelete: () => _handleDelete(p),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        onChanged: onChanged,
        decoration: const InputDecoration(
          hintText: 'Search products...',
          hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.textSecondary,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }
}
