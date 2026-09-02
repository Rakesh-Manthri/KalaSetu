import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalasetu_app/core/constants/app_colors.dart';
import 'package:kalasetu_app/core/widgets/kala_bottom_nav_bar.dart';
import 'package:kalasetu_app/core/widgets/language_selector_button.dart';
import 'package:kalasetu_app/l10n/app_localizations.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildHeader(l10n),
            _buildTabs(l10n),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildOrderCard(
                    badgeText: 'Via ONDC · Taj Heritage Hotels',
                    orderId: '#ORD-9843',
                    title: 'Bell Metal Dhokra Peacock Oil Lamp',
                    qty: 5,
                    price: '₹16,000',
                    actionLabel: l10n?.acceptOrder ?? 'Accept Order',
                    isPrimaryAction: true,
                    imageUrl: 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=120&auto=format&fit=crop&q=80',
                  ),
                  const SizedBox(height: 16),
                  _buildOrderCard(
                    badgeText: 'Via ONDC · Sanya Malhotra',
                    orderId: '#ORD-9844',
                    title: 'Handcrafted Jaipur Blue Pottery Floral Vase',
                    qty: 1,
                    price: '₹1,850',
                    actionLabel: l10n?.acceptOrder ?? 'Accept Order',
                    isPrimaryAction: true,
                    imageUrl: 'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?w=120&auto=format&fit=crop&q=80',
                  ),
                  const SizedBox(height: 16),
                  _buildOrderCard(
                    badgeText: 'Via Craftsvilla Boutique',
                    orderId: '#ORD-9842',
                    title: 'Handwoven Pochampally Ikat Pure Cotton Saree',
                    qty: 3,
                    price: '₹8,397',
                    actionLabel: l10n?.packAndShip ?? 'Pack & Ship',
                    isPrimaryAction: false,
                    imageUrl: 'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=120&auto=format&fit=crop&q=80',
                  ),
                  const SizedBox(height: 16),
                  _buildOrderCard(
                    badgeText: 'Via Hastkala Export Traders',
                    orderId: '#ORD-9841',
                    title: 'Channapatna Wooden Toys Stacking Set',
                    qty: 20,
                    price: '₹19,000',
                    actionLabel: 'Completed',
                    isPrimaryAction: false,
                    imageUrl: 'https://images.unsplash.com/photo-1596461404969-9ae70f2830c1?w=120&auto=format&fit=crop&q=80',
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const KalaBottomNavBar(selectedIndex: 3),
      extendBody: true,
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.surfaceVariant,
                child: Icon(Icons.person, size: 20, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 12),
              const Text(
                'KalaSetu',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const LanguageSelectorButton(),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations? l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          l10n?.ordersHub ?? 'Orders Hub',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildTabs(AppLocalizations? l10n) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          _buildTab(l10n?.newOrdersTab(3) ?? 'New Orders (3)', true),
          const SizedBox(width: 8),
          _buildTab(l10n?.inTransitTab(5) ?? 'In Transit (5)', false),
          const SizedBox(width: 8),
          _buildTab(l10n?.completedTab ?? 'Completed', false),
        ],
      ),
    );
  }

  Widget _buildTab(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.textSecondary.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildOrderCard({
    required String badgeText,
    required String orderId,
    required String title,
    required int qty,
    required String price,
    required String actionLabel,
    required bool isPrimaryAction,
    String? imageUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Text(
                orderId,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 60,
                          height: 60,
                          color: AppColors.surfaceVariant,
                          child: const Icon(Icons.image_outlined, color: AppColors.textSecondary),
                        ),
                      )
                    : Container(
                        width: 60,
                        height: 60,
                        color: AppColors.surfaceVariant,
                        child: const Icon(Icons.image_outlined, color: AppColors.textSecondary),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Qty: $qty',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.surfaceVariant),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPrimaryAction ? AppColors.success : AppColors.surface,
                  foregroundColor: isPrimaryAction ? Colors.white : AppColors.textPrimary,
                  side: isPrimaryAction ? null : BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.3)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: Text(
                  actionLabel,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
