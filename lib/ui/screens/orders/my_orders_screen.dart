import 'package:ecommerce_frontend/core/constants/app_colors.dart';
import 'package:ecommerce_frontend/models/order_model.dart';
import 'package:ecommerce_frontend/services/order_service.dart';
import 'package:ecommerce_frontend/shared/widgets/app_states.dart';
import 'package:ecommerce_frontend/ui/screens/orders/order_detail_screen.dart';
import 'package:ecommerce_frontend/ui/screens/orders/widgets/order_card.dart';
import 'package:flutter/material.dart';

/// Lists the logged-in user's own orders (most recent first as
/// returned by the API), newest on top. Pull to refresh.
class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final _orderService = OrderService();
  late Future<List<OrderModel>> _futureOrders;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _futureOrders = _orderService.getMyOrders();
  }

  Future<void> _refresh() async {
    setState(_load);
    await _futureOrders;
  }

  Future<void> _openOrder(OrderModel order) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order)),
    );
    if (updated == true) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: const Text(
          'My Orders',
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
              message: "You haven't placed any orders yet",
              icon: Icons.receipt_long_outlined,
            );
          }

          final orders = snapshot.data!;

          return RefreshIndicator(
            color: AppColors.accent,
            backgroundColor: AppColors.surface,
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: orders.length,
              itemBuilder: (context, i) => OrderCard(
                order: orders[i],
                onTap: () => _openOrder(orders[i]),
              ),
            ),
          );
        },
      ),
    );
  }
}
