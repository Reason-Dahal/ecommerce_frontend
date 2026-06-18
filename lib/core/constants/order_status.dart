import 'package:flutter/material.dart';

/// Central definition of every order status the app understands —
/// label, color, and icon for each, plus the full list for admin
/// status-change pickers.
abstract final class OrderStatus {
  static const pending = 'pending';
  static const processing = 'processing';
  static const shipped = 'shipped';
  static const delivered = 'delivered';
  static const cancelled = 'cancelled';

  /// Order matters — used for the admin status picker.
  static const all = [pending, processing, shipped, delivered, cancelled];

  static Color colorOf(String status) {
    switch (status.toLowerCase()) {
      case pending:
        return const Color(0xFFFFA726); // orange
      case processing:
        return const Color(0xFF42A5F5); // blue
      case shipped:
        return const Color(0xFF6C63FF); // accent purple
      case delivered:
        return const Color(0xFF66BB6A); // green
      case cancelled:
        return const Color(0xFFEF5350); // red
      default:
        return const Color(0xFF9E9E9E); // grey fallback
    }
  }

  static IconData iconOf(String status) {
    switch (status.toLowerCase()) {
      case pending:
        return Icons.access_time_rounded;
      case processing:
        return Icons.autorenew_rounded;
      case shipped:
        return Icons.local_shipping_outlined;
      case delivered:
        return Icons.check_circle_outline_rounded;
      case cancelled:
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline_rounded;
    }
  }

  static String label(String status) {
    if (status.isEmpty) return 'Unknown';
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }
}
