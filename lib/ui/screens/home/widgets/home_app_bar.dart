import 'package:ecommerce_frontend/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.bg,
      floating: true,
      pinned: true,
      elevation: 0,
      toolbarHeight: 64,
      title: const _Title(),
      actions: const [_NotificationBell(), _Avatar()],
    );
  }
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DISCOVER',
          style: TextStyle(
            color: AppColors.accent,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
          ),
        ),
        SizedBox(height: 2),
        Text(
          'Products',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {},
      icon: Stack(
        children: [
          const Icon(
            Icons.notifications_outlined,
            color: AppColors.textSecondary,
            size: 24,
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {},
        child: CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.accent.withOpacity(0.15),
          child: const Text(
            'U',
            style: TextStyle(
              color: AppColors.accent,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
