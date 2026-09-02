import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/product_listing.dart';

/// In-memory & cache catalog state for artisan craft listings
class CatalogNotifier extends StateNotifier<List<ProductListing>> {
  CatalogNotifier() : super(_initialMockListings);

  static final List<ProductListing> _initialMockListings = [
    ProductListing(
      id: 'KS-1001',
      title: 'Handloom Pochampally Ikat Silk Saree',
      craftCategory: 'Handloom Textiles',
      price: 4850.0,
      imageUrl: 'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=600&auto=format&fit=crop&q=80',
      description: 'Authentic double-ikat weave crafted with natural dyes and geometric silk motifs.',
      isGiCertified: true,
      artisanName: 'Lakshmi Bai',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    ProductListing(
      id: 'KS-1002',
      title: 'Traditional Terracotta Water Pitcher (Kooja)',
      craftCategory: 'Clay & Pottery',
      price: 650.0,
      imageUrl: 'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?w=600&auto=format&fit=crop&q=80',
      description: 'Hand-thrown porous red terracotta pitcher naturally cooling water with rustic charcoal burnishing.',
      isGiCertified: false,
      artisanName: 'Ramu Kumhar',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  void addListing(ProductListing listing) {
    state = [listing, ...state];
  }

  void removeListing(String id) {
    state = state.where((item) => item.id != id).toList();
  }
}

final catalogListingsProvider =
    StateNotifierProvider<CatalogNotifier, List<ProductListing>>((ref) {
  return CatalogNotifier();
});
