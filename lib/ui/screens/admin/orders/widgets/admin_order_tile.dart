import 'package:ecommerce_frontend/core/constants/app_colors.dart';
import 'package:ecommerce_frontend/core/utils/price_formatter.dart';
import 'package:ecommerce_frontend/models/order_model.dart';
import 'package:ecommerce_frontend/ui/screens/widgets/order_status_badge.dart';
import 'package:flutter/material.dart';

/// Admin list row — order id, customer email, item count, total, and
/// status badge. Tap to open OrderDetailScreen for status updates.
class AdminOrderTile extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const AdminOrderTile({super.key, required this.order, required this.onTap});

  String get _shortId {
    final id = order.id;
    return id.length > 8
        ? '#${id.substring(id.length - 8).toUpperCase()}'
        : '#$id';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _shortId,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(width: 8),
                      OrderStatusBadge(status: order.status, fontSize: 10),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (order.userEmail != null)
                    Text(
                      order.userEmail!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    '${order.orderItems.length} ${order.orderItems.length == 1 ? 'item' : 'items'}  ·  ${PriceFormatter.format(order.totalPrice)}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
