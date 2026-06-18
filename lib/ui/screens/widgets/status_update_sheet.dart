import 'package:ecommerce_frontend/core/constants/app_colors.dart';
import 'package:ecommerce_frontend/core/constants/order_status.dart';
import 'package:flutter/material.dart';

/// Bottom sheet listing every available order status. Returns the
/// selected status string, or null if the user dismissed it / picked
/// the status that was already active.
Future<String?> showStatusUpdateSheet(
  BuildContext context, {
  required String currentStatus,
}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Update Order Status',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            ...OrderStatus.all.map((status) {
              final isSelected = status == currentStatus;
              final color = OrderStatus.colorOf(status);

              return ListTile(
                onTap: () => Navigator.pop(context, status),
                leading: Icon(OrderStatus.iconOf(status), color: color),
                title: Text(
                  OrderStatus.label(status),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check, color: AppColors.accent)
                    : null,
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}
