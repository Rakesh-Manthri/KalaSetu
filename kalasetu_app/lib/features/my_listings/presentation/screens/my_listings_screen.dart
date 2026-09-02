import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalasetu_app/core/constants/app_colors.dart';
import 'package:kalasetu_app/core/widgets/kala_bottom_nav_bar.dart';
import 'package:kalasetu_app/core/widgets/language_selector_button.dart';
import 'package:go_router/go_router.dart';
import 'package:kalasetu_app/l10n/app_localizations.dart';

class MyListingsScreen extends ConsumerWidget {
  const MyListingsScreen({super.key});

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
            _buildFilters(l10n),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(20),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.72,
                children: [
                  _buildProductCard(
                    context: context,
                    l10n: l10n,
                    title: 'Handwoven Pochampally Ikat Saree',
                    category: 'Handloom',
                    price: '₹2,799',
                    stock: 8,
                    status: l10n?.statusPublished ?? 'Live',
                    statusColor: AppColors.success,
                    hasQr: true,
                    imageUrl: 'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=600&auto=format&fit=crop&q=80',
                    passportId: 'prod_001',
                  ),
                  _buildProductCard(
                    context: context,
                    l10n: l10n,
                    title: 'Jaipur Blue Pottery Floral Vase',
                    category: 'Pottery',
                    price: '₹1,850',
                    stock: 3,
                    status: l10n?.statusPublished ?? 'Live',
                    statusColor: AppColors.success,
                    hasQr: true,
                    imageUrl: 'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?w=600&auto=format&fit=crop&q=80',
                    passportId: 'prod_002',
                  ),
                  _buildProductCard(
                    context: context,
                    l10n: l10n,
                    title: 'Channapatna Wooden Toy',
                    category: 'Woodcraft',
                    price: '₹950',
                    stock: 15,
                    status: l10n?.statusPublished ?? 'Live',
                    statusColor: AppColors.success,
                    hasQr: true,
                    imageUrl: 'https://images.unsplash.com/photo-1596461404969-9ae70f2830c1?w=600&auto=format&fit=crop&q=80',
                    passportId: 'prod_001',
                  ),
                  _buildProductCard(
                    context: context,
                    l10n: l10n,
                    title: 'Dhokra Peacock Oil Lamp',
                    category: 'Metalcraft',
                    price: '₹3,200',
                    stock: null,
                    status: l10n?.filterUnderReview ?? 'Under Review',
                    statusColor: AppColors.warning,
                    hasQr: false,
                    imageUrl: 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600&auto=format&fit=crop&q=80',
                  ),
                  _buildProductCard(
                    context: context,
                    l10n: l10n,
                    title: 'Madhubani Fish Painting',
                    category: 'Paintings',
                    price: '₹2,500',
                    stock: null,
                    status: l10n?.statusDraft ?? 'Draft',
                    statusColor: AppColors.statusDraft,
                    hasQr: false,
                    imageUrl: 'https://images.unsplash.com/photo-1579783902614-a3fb3927b675?w=600&auto=format&fit=crop&q=80',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const KalaBottomNavBar(selectedIndex: 1),
      extendBody: true,
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'KalaSetu',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const LanguageSelectorButton(),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations? l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Text(
            l10n?.myListingsTitle ?? 'My Products',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '12 Total',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(AppLocalizations? l10n) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip(l10n?.filterAll ?? 'All Products', true),
          const SizedBox(width: 8),
          _buildFilterChip(l10n?.filterPublished ?? 'Live on ONDC', false),
          const SizedBox(width: 8),
          _buildFilterChip(l10n?.filterDraft ?? 'Drafts', false),
          const SizedBox(width: 8),
          _buildFilterChip(l10n?.filterUnderReview ?? 'Under Review', false),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.textPrimary : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.textPrimary : AppColors.textSecondary.withValues(alpha: 0.2),
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

  Widget _buildProductCard({
    required BuildContext context,
    required AppLocalizations? l10n,
    required String title,
    required String category,
    required String price,
    required int? stock,
    required String status,
    required Color statusColor,
    required bool hasQr,
    String? imageUrl,
    String? passportId,
  }) {
    return GestureDetector(
      onTap: () {
        if (passportId != null) {
          context.push('/passport/$passportId');
        }
      },
      child: Container(
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
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                color: AppColors.surfaceVariant,
                width: double.infinity,
                child: Stack(
                  children: [
                    if (imageUrl != null)
                      Positioned.fill(
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Icon(Icons.image_outlined, color: AppColors.textSecondary, size: 40),
                          ),
                        ),
                      )
                    else
                      const Center(
                        child: Icon(Icons.image_outlined, color: AppColors.textSecondary, size: 40),
                      ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            status,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            price,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (stock != null)
                            Text(
                              l10n?.stockUnits(stock) ?? 'Stock: $stock units',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                      if (hasQr)
                        InkWell(
                          onTap: () => context.push('/passport/1'),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.qr_code_scanner, color: AppColors.primary, size: 20),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}
