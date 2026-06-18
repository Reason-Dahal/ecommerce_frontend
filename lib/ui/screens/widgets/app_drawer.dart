import 'package:ecommerce_frontend/core/constants/app_colors.dart';
import 'package:ecommerce_frontend/services/auth_service.dart';
import 'package:ecommerce_frontend/ui/screens/admin/admin_product_list_screen.dart';
import 'package:ecommerce_frontend/ui/screens/admin/orders/admin_orders_screen.dart';
import 'package:ecommerce_frontend/ui/screens/cart/cart_screen.dart';
import 'package:ecommerce_frontend/ui/screens/home/home_screen.dart';
import 'package:ecommerce_frontend/ui/screens/orders/my_orders_screen.dart';
import 'package:ecommerce_frontend/ui/screens/settings/settings_screen.dart';
import 'package:ecommerce_frontend/ui/screens/wishlist/wishlist_screen.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _navigate(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _logout(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(
          'Are you sure you want to logout from your account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await AuthService().logout();

    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.bg,
      child: SafeArea(
        child: FutureBuilder(
          future: AuthService().getCurrentUser(),
          builder: (context, snapshot) {
            final user = snapshot.data;
            final isAdmin = user?.isAdmin == true;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DrawerHeader(name: user?.name, email: user?.email),
                const Divider(color: AppColors.surface, height: 1),
                const SizedBox(height: 8),

                _DrawerItem(
                  icon: Icons.home_outlined,
                  label: 'Home',
                  onTap: () => _navigate(context, const HomeScreen()),
                ),

                if (!isAdmin) ...[
                  _DrawerItem(
                    icon: Icons.shopping_bag_outlined,
                    label: 'My Orders',
                    onTap: () => _navigate(context, const MyOrdersScreen()),
                  ),
                  _DrawerItem(
                    icon: Icons.shopping_cart_outlined,
                    label: 'Cart',
                    onTap: () => _navigate(context, const CartScreen()),
                  ),
                  _DrawerItem(
                    icon: Icons.favorite_border,
                    label: 'Wishlist',
                    onTap: () => _navigate(context, const WishlistScreen()),
                  ),
                ],

                if (isAdmin) ...[
                  _DrawerItem(
                    icon: Icons.dashboard_customize_outlined,
                    label: 'Manage Products',
                    onTap: () =>
                        _navigate(context, const AdminProductListScreen()),
                  ),
                  _DrawerItem(
                    icon: Icons.receipt_long_outlined,
                    label: 'All Orders',
                    onTap: () => _navigate(context, const AdminOrdersScreen()),
                  ),
                ],

                _DrawerItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  onTap: () => _navigate(context, const SettingsScreen()),
                ),

                const Spacer(),
                const Divider(color: AppColors.surface, height: 1),
                _DrawerItem(
                  icon: Icons.logout,
                  label: 'Logout',
                  iconColor: Colors.redAccent,
                  labelColor: Colors.redAccent,
                  onTap: () => _logout(context),
                ),
                const SizedBox(height: 8),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  final String? name;
  final String? email;
  const _DrawerHeader({this.name, this.email});

  @override
  Widget build(BuildContext context) {
    final displayName = (name == null || name!.isEmpty) ? 'Guest User' : name!;
    final initial = displayName[0].toUpperCase();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.accent.withOpacity(0.15),
            child: Text(
              initial,
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (email != null && email!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    email!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? labelColor;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: iconColor ?? AppColors.textSecondary,
        size: 22,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: labelColor ?? AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
