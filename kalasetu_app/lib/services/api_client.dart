import 'dart:io';
import 'package:kalasetu_app/core/models/enhanced_image_result.dart';
import 'package:kalasetu_app/core/models/transcription_result.dart';
import 'package:kalasetu_app/core/models/generated_listing.dart';
import 'package:kalasetu_app/core/models/pricing_suggestion.dart';
import 'package:kalasetu_app/core/models/publish_result.dart';
import 'package:kalasetu_app/core/models/product_listing.dart';
import 'package:kalasetu_app/core/models/craft_passport.dart';
import 'package:kalasetu_app/core/models/listing_status.dart';
import 'package:kalasetu_app/core/models/order.dart';

abstract class ApiClient {
  Future<EnhancedImageResult> enhanceImages(List<File> images);
  Future<TranscriptionResult> transcribeVoice(File audioFile, String languageCode);
  Future<GeneratedListing> generateListing({
    required List<String> imagePaths,
    required String audioPath,
    required String languageCode,
  });
  Future<PricingSuggestion> getDynamicPrice(String category, String description);
  Future<PublishResult> publishToOndc(String listingId);
  Future<List<ProductListing>> getMyListings({ListingStatus? filter});
  Future<CraftPassport> getCraftPassport(String listingId);
  Future<List<OrderItem>> getOrders({OrderStatus? filter});
  Future<void> acceptOrder(String orderId);
}
