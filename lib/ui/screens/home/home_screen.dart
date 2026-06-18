import 'package:ecommerce_frontend/core/constants/app_colors.dart';
import 'package:ecommerce_frontend/ui/screens/home/widgets/category_filter_row.dart';
import 'package:ecommerce_frontend/ui/screens/home/widgets/home_app_bar.dart';
import 'package:ecommerce_frontend/ui/screens/home/widgets/home_bottom_nav.dart';
import 'package:ecommerce_frontend/ui/screens/home/widgets/home_search_bar.dart';
import 'package:ecommerce_frontend/ui/screens/home/widgets/product_grid.dart';
import 'package:ecommerce_frontend/ui/screens/widgets/app_drawer.dart';
import 'package:ecommerce_frontend/models/product_model.dart';
import 'package:ecommerce_frontend/services/product_service.dart';
import 'package:ecommerce_frontend/shared/widgets/app_states.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _productService = ProductService();
  late final Future<List<ProductModel>> _futureProducts;

  String _selectedCategory = 'All';
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _futureProducts = _productService.getAllProduct();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Filtering ─────────────────────────────────────────────────────────────────

  List<String> _buildCategories(List<ProductModel> products) {
    final seen = <String>{};
    return [
      'All',
      ...products.map((p) => _capitalize(p.category)).where(seen.add),
    ];
  }

  List<ProductModel> _applyFilters(List<ProductModel> products) {
    return products.where((p) {
      final matchCategory =
          _selectedCategory == 'All' ||
          p.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchSearch = p.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      return matchCategory && matchSearch;
    }).toList();
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      drawer: const AppDrawer(),
      bottomNavigationBar: const HomeBottomNav(),
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
            return const AppEmptyState();
          }

          final filtered = _applyFilters(snapshot.data!);
          final categories = _buildCategories(snapshot.data!);

          return CustomScrollView(
            slivers: [
              const HomeAppBar(),
              HomeSearchBar(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
              CategoryFilterRow(
                categories: categories,
                selectedCategory: _selectedCategory,
                onSelect: (cat) => setState(() => _selectedCategory = cat),
              ),
              _ResultCountHeader(count: filtered.length),
              ProductGrid(products: filtered),
              const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
            ],
          );
        },
      ),
    );
  }
}

// ── Small local widget (too trivial to extract into its own file) ──────────────

class _ResultCountHeader extends StatelessWidget {
  final int count;
  const _ResultCountHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Text(
          '$count ${count == 1 ? 'product' : 'products'} found',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ),
    );
  }
}
