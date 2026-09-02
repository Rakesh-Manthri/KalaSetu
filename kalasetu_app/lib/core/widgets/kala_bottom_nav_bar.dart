import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kalasetu_app/core/constants/app_colors.dart';
import 'package:kalasetu_app/l10n/app_localizations.dart';

class KalaBottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const KalaBottomNavBar({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final homeLabel = l10n?.navHome ?? 'Home';
    final productsLabel = l10n?.navProducts ?? 'Products';
    final ordersLabel = l10n?.navOrders ?? 'Orders';
    final profileLabel = l10n?.navProfile ?? 'Profile';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, index: 0, icon: Icons.home_rounded, label: homeLabel, route: '/'),
          _buildNavItem(context, index: 1, icon: Icons.inventory_2_rounded, label: productsLabel, route: '/listings'),
          _buildFabItem(context),
          _buildNavItem(context, index: 3, icon: Icons.shopping_bag_rounded, label: ordersLabel, route: '/orders'),
          _buildNavItem(context, index: 4, icon: Icons.person_rounded, label: profileLabel, route: '/profile'),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, {required int index, required IconData icon, required String label, required String route}) {
    final isSelected = selectedIndex == index;
    return InkWell(
      onTap: () {
        if (!isSelected) context.go(route);
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isSelected ? AppColors.secondary : AppColors.onSurfaceVariant,
                  size: 24,
                ),
                if (index == 3)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.secondary : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFabItem(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -12),
      child: GestureDetector(
        onTap: () => context.push('/camera'),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 12,
                spreadRadius: 2,
              )
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
