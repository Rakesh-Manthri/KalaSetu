import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/constants/app_colors.dart';
import '../../core/models/enhance_result.dart';
import '../../core/models/product_listing.dart';
import '../my_listings/catalog_controller.dart';
import '../my_listings/catalog_screen.dart';

/// Studio Preview Screen displaying the enhanced product and Before/After comparison.
class StudioPreviewScreen extends ConsumerStatefulWidget {
  final EnhanceResult result;

  const StudioPreviewScreen({super.key, required this.result});

  @override
  ConsumerState<StudioPreviewScreen> createState() => _StudioPreviewScreenState();
}

class _StudioPreviewScreenState extends ConsumerState<StudioPreviewScreen> {
  // Toggle between 'Enhanced Studio' (0), 'Before / After Montage' (1), and 'Original Raw' (2)
  int _viewMode = 0;

  final TextEditingController _titleController = TextEditingController(text: 'Handcrafted Ceramic Tea Cup Set');
  final TextEditingController _priceController = TextEditingController(text: '850');
  String _selectedCategory = 'Clay & Pottery';

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _saveToCatalog() {
    final enhancedUrl = widget.result.fullImageUrl ?? widget.result.imageUrl ?? '';
    final montageUrl = widget.result.fullMontageUrl ?? widget.result.montageUrl;
    final price = double.tryParse(_priceController.text) ?? 850.0;

    final newProduct = ProductListing(
      id: 'KS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      title: _titleController.text.trim().isEmpty ? 'Artisan Craft Product' : _titleController.text.trim(),
      craftCategory: _selectedCategory,
      price: price,
      imageUrl: enhancedUrl,
      localRawImagePath: widget.result.rawImagePath,
      montageUrl: montageUrl,
      description: 'Studio-enhanced artisan craft with pure white backdrop, calibrated lighting, and 1:1 e-commerce framing.',
      isGiCertified: true,
      artisanName: 'Verified Artisan',
    );

    ref.read(catalogListingsProvider.notifier).addListing(newProduct);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Product saved to Catalog with Studio-Ready photo!',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );

    // Navigate to Catalog screen
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const CatalogScreen()),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final res = widget.result;
    final fullEnhancedUrl = res.fullImageUrl ?? res.imageUrl;
    final fullMontageUrl = res.fullMontageUrl ?? res.montageUrl;
    final rawLocalPath = res.rawImagePath;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.slateDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Studio Output Review',
          style: TextStyle(color: AppColors.slateDark, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.terracotta),
            tooltip: 'Retake Photo',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Interactive View Mode Selector (Before / After / Studio)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.grey200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildTabButton(index: 0, label: '✨ Studio Ready'),
                  if (fullMontageUrl != null) ...[
                    _buildTabButton(index: 1, label: '↔️ Before / After'),
                  ],
                  if (rawLocalPath != null) ...[
                    _buildTabButton(index: 2, label: '📷 Original Raw'),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Main Studio Preview Container
            Container(
              height: 340,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.grey200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image display based on active view mode
                    if (_viewMode == 0 && fullEnhancedUrl != null)
                      _buildNetworkOrFallbackImage(fullEnhancedUrl)
                    else if (_viewMode == 1 && fullMontageUrl != null)
                      _buildNetworkOrFallbackImage(fullMontageUrl)
                    else if (_viewMode == 2 && rawLocalPath != null)
                      Image.file(File(rawLocalPath), fit: BoxFit.contain)
                    else
                      const Center(
                        child: Text(
                          'No preview image available',
                          style: TextStyle(color: AppColors.grey600),
                        ),
                      ),

                    // Top Studio Badge
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.slateDark.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified, color: AppColors.successGreen, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              _viewMode == 0 ? '1000x1000 Studio Ready' : (_viewMode == 1 ? 'Montage Verification' : 'Raw Capture'),
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 3. Applied Enhancements Chips
            const Text(
              'Enhancements Applied',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.slateDark),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildBadge(Icons.auto_fix_high, 'Background Isolated & Cleaned'),
                _buildBadge(Icons.light_mode_outlined, 'Lighting & Shadow Balanced'),
                _buildBadge(Icons.aspect_ratio, '1:1 Square Canvas Framing'),
                _buildBadge(Icons.offline_bolt_outlined, '100% Offline CPU Processed'),
              ],
            ),
            const SizedBox(height: 20),

            // 4. Product Listing Form Integration
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.grey200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Catalog Entry',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.slateDark),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Product Title',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Price (₹)',
                            prefixText: '₹ ',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: InputDecoration(
                            labelText: 'Craft Category',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Clay & Pottery', child: Text('Clay & Pottery')),
                            DropdownMenuItem(value: 'Handloom Textiles', child: Text('Handloom Textiles')),
                            DropdownMenuItem(value: 'Woodcraft', child: Text('Woodcraft')),
                            DropdownMenuItem(value: 'Metal & Brass', child: Text('Metal & Brass')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedCategory = val);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // 5. Action Button: Proceed to Catalog (Large 56dp+ accessible target)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _saveToCatalog,
                icon: const Icon(Icons.add_shopping_cart_rounded, color: Colors.white, size: 22),
                label: const Text(
                  'Add to Catalog & Proceed',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.terracotta,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkOrFallbackImage(String url) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.contain,
      placeholder: (context, _) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.terracotta),
        ),
      ),
      errorWidget: (context, error, stackTrace) => Container(
        color: AppColors.studioBackdrop,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image_outlined, size: 48, color: AppColors.grey400),
            const SizedBox(height: 8),
            Text(
              'Fetching studio output...\n($url)',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.grey600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton({required int index, required String label}) {
    final isSelected = _viewMode == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _viewMode = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.terracotta : AppColors.grey600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.terracotta),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontSize: 12, color: AppColors.grey800, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
