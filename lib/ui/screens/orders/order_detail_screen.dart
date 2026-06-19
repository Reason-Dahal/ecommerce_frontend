// import 'package:ecommerce_frontend/core/constants.dart';
import 'package:ecommerce_frontend/core/constants/app_colors.dart';
import 'package:ecommerce_frontend/core/utils/price_formatter.dart';
import 'package:ecommerce_frontend/models/order_item_model.dart';
import 'package:ecommerce_frontend/models/order_model.dart';
import 'package:ecommerce_frontend/services/order_service.dart';
import 'package:ecommerce_frontend/ui/screens/orders/widgets/order_item_tile.dart';
import 'package:ecommerce_frontend/ui/screens/orders/widgets/shipping_address_card.dart';
import 'package:ecommerce_frontend/ui/screens/widgets/order_status_badge.dart';
import 'package:ecommerce_frontend/ui/screens/widgets/status_update_sheet.dart';
import 'package:flutter/material.dart';

/// Shows everything about a single order: items, shipping address,
/// and total. When [isAdmin] is true, tapping the status badge opens
/// a picker to change the order's status, the customer's name/email
/// is shown, and a larger product preview row helps the admin
/// quickly identify what was ordered.
class OrderDetailScreen extends StatefulWidget {
  final OrderModel order;
  final bool isAdmin;

  const OrderDetailScreen({
    super.key,
    required this.order,
    this.isAdmin = false,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final _orderService = OrderService();
  late OrderModel _order;
  bool _isUpdating = false;

  /// True once the status has actually changed — tells the previous
  /// screen to refresh its list on pop.
  bool _wasUpdated = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  Future<void> _changeStatus() async {
    final newStatus = await showStatusUpdateSheet(
      context,
      currentStatus: _order.status,
    );

    if (newStatus == null || newStatus == _order.status) return;

    setState(() => _isUpdating = true);

    try {
      final updated = await _orderService.updateOrderStatus(
        orderId: _order.id,
        status: newStatus,
      );

      setState(() {
        _order = updated;
        _wasUpdated = true;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  String get _shortId {
    final id = _order.id;
    return id.length > 8
        ? '#${id.substring(id.length - 8).toUpperCase()}'
        : '#$id';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _wasUpdated);
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          backgroundColor: AppColors.bg,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
          title: Text(
            'Order $_shortId',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            onPressed: () => Navigator.pop(context, _wasUpdated),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _StatusSection(
              order: _order,
              isAdmin: widget.isAdmin,
              isUpdating: _isUpdating,
              onTapChange: _changeStatus,
            ),
            const SizedBox(height: 16),
            if (widget.isAdmin) ...[
              if (_order.userEmail != null || _order.userName != null) ...[
                _AdminCustomerCard(
                  name: _order.userName,
                  email: _order.userEmail,
                ),
                const SizedBox(height: 16),
              ],
              const _SectionTitle(title: 'Product Preview'),
              const SizedBox(height: 8),
              _ProductPreviewSection(items: _order.orderItems),
              const SizedBox(height: 16),
            ],
            ShippingAddressCard(address: _order.shippingAddress),
            const SizedBox(height: 16),
            const _SectionTitle(title: 'Items'),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < _order.orderItems.length; i++) ...[
                    OrderItemTile(item: _order.orderItems[i]),
                    if (i != _order.orderItems.length - 1)
                      const Divider(color: AppColors.bg, height: 1),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            _TotalRow(total: _order.totalPrice),
          ],
        ),
      ),
    );
  }
}

// ── Sections ─────────────────────────────────────────────────────────────────

class _StatusSection extends StatelessWidget {
  final OrderModel order;
  final bool isAdmin;
  final bool isUpdating;
  final VoidCallback onTapChange;

  const _StatusSection({
    required this.order,
    required this.isAdmin,
    required this.isUpdating,
    required this.onTapChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Order Status',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (isAdmin)
            GestureDetector(
              onTap: isUpdating ? null : onTapChange,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OrderStatusBadge(status: order.status),
                  const SizedBox(width: 6),
                  isUpdating
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.accent,
                          ),
                        )
                      : const Icon(
                          Icons.edit_outlined,
                          color: AppColors.textSecondary,
                          size: 16,
                        ),
                ],
              ),
            )
          else
            OrderStatusBadge(status: order.status),
        ],
      ),
    );
  }
}

/// Customer info row — shows the orderer's name where the static
/// "Customer" label used to be, with their email alongside it on
/// the right. Falls back to "Customer" if no name was returned.
class _AdminCustomerCard extends StatelessWidget {
  final String? name;
  final String? email;

  const _AdminCustomerCard({this.name, this.email});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_outline, color: AppColors.accent, size: 18),
          const SizedBox(width: 8),
          Text(
            (name != null && name!.isNotEmpty) ? name! : 'Customer',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          if (email != null && email!.isNotEmpty)
            Text(
              email!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Horizontal row of larger product images (one per order item) so
/// an admin can identify what was ordered at a glance, without
/// needing to read the smaller line-item list below.
class _ProductPreviewSection extends StatelessWidget {
  final List<OrderItemModel> items;
  const _ProductPreviewSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) => _ProductPreviewCard(item: items[i]),
      ),
    );
  }
}

class _ProductPreviewCard extends StatelessWidget {
  final OrderItemModel item;
  const _ProductPreviewCard({required this.item});

  Widget _placeholder() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(
        Icons.inventory_2_outlined,
        color: AppColors.textSecondary,
        size: 32,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productUrl = item.product?.url;
    final imageUrl = (productUrl != null && productUrl.isNotEmpty)
        ? productUrl
        : null;

    return SizedBox(
      width: 120,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: imageUrl != null
                ? Image.network(
                    imageUrl,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),
          const SizedBox(height: 6),
          Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final double total;
  const _TotalRow({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accent.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            PriceFormatter.format(total),
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
