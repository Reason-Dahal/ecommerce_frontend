import 'package:ecommerce_frontend/core/constants/order_status.dart';
import 'package:flutter/material.dart';

/// Small pill showing an order's current status with a matching icon
/// and color. Used in order lists, detail screens, and admin tiles.
class OrderStatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;

  const OrderStatusBadge({super.key, required this.status, this.fontSize = 11});

  @override
  Widget build(BuildContext context) {
    final color = OrderStatus.colorOf(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(OrderStatus.iconOf(status), size: fontSize + 2, color: color),
          const SizedBox(width: 5),
          Text(
            OrderStatus.label(status),
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
