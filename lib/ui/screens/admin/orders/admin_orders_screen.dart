import 'package:ecommerce_frontend/core/constants/app_colors.dart';
import 'package:ecommerce_frontend/core/constants/order_status.dart';
import 'package:ecommerce_frontend/models/order_model.dart';
import 'package:ecommerce_frontend/services/order_service.dart';
import 'package:ecommerce_frontend/shared/widgets/app_states.dart';
import 'package:ecommerce_frontend/ui/screens/admin/orders/widgets/admin_order_tile.dart';
import 'package:ecommerce_frontend/ui/screens/orders/order_detail_screen.dart';
import 'package:flutter/material.dart';

/// Admin view of every order in the system, with a status filter row
/// and pull-to-refresh. Tapping an order opens OrderDetailScreen in
/// admin mode, where the status can be changed.
class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final _orderService = OrderService();
  late Future<List<OrderModel>> _futureOrders;

  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _futureOrders = _orderService.getAllOrders();
  }

  Future<void> _refresh() async {
    setState(_load);
    await _futureOrders;
  }

  Future<void> _openOrder(OrderModel order) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => OrderDetailScreen(order: order, isAdmin: true),
      ),
    );
    if (updated == true) _refresh();
  }

  List<OrderModel> _applyFilter(List<OrderModel> orders) {
    if (_selectedFilter == 'All') return orders;
    return orders
        .where((o) => o.status.toLowerCase() == _selectedFilter.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: const Text(
          'All Orders',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: FutureBuilder<List<OrderModel>>(
        future: _futureOrders,
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
              message: 'No orders have been placed yet',
              icon: Icons.receipt_long_outlined,
            );
          }

          final filtered = _applyFilter(snapshot.data!);

          return RefreshIndicator(
            color: AppColors.accent,
            backgroundColor: AppColors.surface,
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _StatusFilterRow(
                  selected: _selectedFilter,
                  onSelect: (f) => setState(() => _selectedFilter = f),
                ),
                const SizedBox(height: 8),
                Text(
                  '${filtered.length} ${filtered.length == 1 ? 'order' : 'orders'}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                if (filtered.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: AppEmptyState(message: 'No orders with this status'),
                  )
                else
                  ...filtered.map(
                    (order) => AdminOrderTile(
                      order: order,
                      onTap: () => _openOrder(order),
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

// ── Status filter chips ─────────────────────────────────────────────────────────

class _StatusFilterRow extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;

  const _StatusFilterRow({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final filters = ['All', ...OrderStatus.all];

    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, i) {
          final filter = filters[i];
          final isSelected = filter == selected;
          final color = filter == 'All'
              ? AppColors.accent
              : OrderStatus.colorOf(filter);

          return GestureDetector(
            onTap: () => onSelect(filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? color : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                filter == 'All' ? 'All' : OrderStatus.label(filter),
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
