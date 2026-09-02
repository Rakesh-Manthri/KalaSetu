import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/constants/app_colors.dart';
import '../../core/models/product_listing.dart';
import '../capture/camera_screen.dart';
import 'catalog_controller.dart';

/// Bento-grid artisan catalog screen displaying published listings
class CatalogScreen extends ConsumerWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listings = ref.watch(catalogListingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Artisan Catalog',
              style: TextStyle(color: AppColors.slateDark, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'ONDC-Connected E-Commerce Listings',
              style: TextStyle(color: AppColors.grey600, fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_a_photo_rounded, color: AppColors.terracotta),
            tooltip: 'Click a Pic',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CameraScreen()),
              );
            },
          ),
        ],
      ),
      body: listings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.storefront_outlined, size: 64, color: AppColors.grey400),
                  const SizedBox(height: 16),
                  const Text(
                    'Your catalog is empty',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.slateDark),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Snap a photo with AI Vision Studio to create your first listing.',
                    style: TextStyle(color: AppColors.grey600),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CameraScreen()),
                      );
                    },
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    label: const Text('Click a Pic', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.terracotta),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.72,
              ),
              itemCount: listings.length,
              itemBuilder: (context, index) {
                final item = listings[index];
                return _buildProductCard(context, item);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.terracotta,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CameraScreen()),
          );
        },
        icon: const Icon(Icons.camera_alt_rounded, color: Colors.white),
        label: const Text(
          'Click a Pic',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductListing item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image Container
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: AppColors.studioBackdrop,
                    child: CachedNetworkImage(
                      imageUrl: item.imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => const Center(
                        child: Icon(Icons.inventory_2_outlined, color: AppColors.grey400, size: 36),
                      ),
                    ),
                  ),
                  if (item.isGiCertified)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.trustBlue,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified, color: Colors.white, size: 10),
                            SizedBox(width: 3),
                            Text(
                              'GI TAG',
                              style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.successGreen,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'STUDIO READY',
                        style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Product Details
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.craftCategory.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: AppColors.terracotta,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slateDark,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹${item.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.slateDark,
                      ),
                    ),
                    const Row(
                      children: [
                        Icon(Icons.store_mall_directory_outlined, size: 12, color: AppColors.trustBlue),
                        SizedBox(width: 3),
                        Text(
                          'ONDC',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.trustBlue),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
