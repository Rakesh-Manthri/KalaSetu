import 'dart:io';
import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:kalasetu_app/core/models/enhanced_image_result.dart';
import 'package:kalasetu_app/core/models/transcription_result.dart';
import 'package:kalasetu_app/core/models/generated_listing.dart';
import 'package:kalasetu_app/core/models/pricing_suggestion.dart';
import 'package:kalasetu_app/core/models/publish_result.dart';
import 'package:kalasetu_app/core/models/product_listing.dart';
import 'package:kalasetu_app/core/models/craft_passport.dart';
import 'package:kalasetu_app/core/models/listing_status.dart';
import 'package:kalasetu_app/core/models/order.dart';
import 'package:kalasetu_app/services/api_client.dart';
import 'package:kalasetu_app/services/mock_data.dart';

class MockApiClient implements ApiClient {
  final Random _random = Random();
  final Uuid _uuid = const Uuid();

  Future<void> _simulateDelayAndOccasionalFailure() async {
    // Simulate 1-3 seconds network latency
    final delay = _random.nextInt(2000) + 1000;
    await Future.delayed(Duration(milliseconds: delay));

    // 10% chance of random failure
    if (_random.nextDouble() < 0.1) {
      throw Exception('Network timeout or mock server error. Please retry.');
    }
  }

  @override
  Future<EnhancedImageResult> enhanceImages(List<File> images) async {
    await _simulateDelayAndOccasionalFailure();
    if (images.isEmpty) {
      throw Exception('No images provided for enhancement');
    }
    return EnhancedImageResult(
      originalImagePath: images.first.path,
      enhancedImagePath: images.first.path,
      enhancementsApplied: const [
        'Background isolated & studio backdrop applied',
        'Lighting & shadows calibrated for e-commerce',
        '1:1 square canvas framing (1000x1000)',
        'Before/After comparison montage generated',
      ],
      blurScore: 85.0 + _random.nextDouble() * 50,
      metadata: const {'processing_time_ms': 1240, 'resolution': '1000x1000'},
    );
  }

  @override
  Future<TranscriptionResult> transcribeVoice(File audioFile, String languageCode) async {
    await _simulateDelayAndOccasionalFailure();
    return TranscriptionResult(
      originalText: 'Mock original transcription text',
      translatedText: 'Mock translated transcription text',
      detectedLanguage: languageCode,
      audioFilePath: audioFile.path,
    );
  }

  @override
  Future<GeneratedListing> generateListing({
    required List<String> imagePaths,
    required String audioPath,
    required String languageCode,
  }) async {
    await _simulateDelayAndOccasionalFailure();

    final String id = _uuid.v4();
    final String imagePath = imagePaths.isNotEmpty ? imagePaths.first : '';
    
    return GeneratedListing(
      id: id,
      title: 'Madhubani Painting - Fish Motif',
      descriptionEn: mockDescriptions['Madhubani Painting']?['en'] ?? '',
      descriptionHi: mockDescriptions['Madhubani Painting']?['hi'] ?? '',
      category: 'Paintings',
      subcategory: 'Madhubani',
      enhancedImage: EnhancedImageResult(
        originalImagePath: imagePath,
        enhancedImagePath: imagePath,
      ),
      transcription: TranscriptionResult(
        originalText: 'Mock original transcription text',
        translatedText: 'Mock translated transcription text',
        detectedLanguage: languageCode,
        audioFilePath: audioPath,
      ),
      pricing: mockPricingData['Madhubani Painting'] ??
        const PricingSuggestion(
          suggestedPrice: 1000.0,
          materialCost: 200.0,
          laborCost: 600.0,
          laborHours: 5,
          fairMargin: 200.0,
        ),
    );
  }

  @override
  Future<PricingSuggestion> getDynamicPrice(String category, String description) async {
    await _simulateDelayAndOccasionalFailure();
    return mockPricingData['Madhubani Painting'] ??
        const PricingSuggestion(
          suggestedPrice: 1000.0,
          materialCost: 200.0,
          laborCost: 600.0,
          laborHours: 5,
          fairMargin: 200.0,
        );
  }

  @override
  Future<PublishResult> publishToOndc(String listingId) async {
    await _simulateDelayAndOccasionalFailure();
    return PublishResult(
      success: true,
      ondcListingId: 'ONDC-${_uuid.v4().substring(0, 8)}',
      errorMessage: null,
    );
  }

  @override
  Future<List<ProductListing>> getMyListings({ListingStatus? filter}) async {
    await _simulateDelayAndOccasionalFailure();
    if (filter != null) {
      return mockProductListings.where((listing) => listing.status == filter).toList();
    }
    return mockProductListings;
  }

  @override
  Future<CraftPassport> getCraftPassport(String listingId) async {
    await _simulateDelayAndOccasionalFailure();
    return mockCraftPassports[listingId] ??
        CraftPassport(
          listingId: listingId,
          productName: 'Unknown Product',
          artisanName: 'Unknown Artisan',
          location: 'Unknown Location',
          giTag: null,
          materials: const ['Unknown'],
          techniques: const ['Unknown'],
          verificationUrl: 'https://verify.kalasetu.in/mock',
          imageUrl: 'unknown_image_url',
          createdAt: DateTime.now(),
        );
  }

  @override
  Future<List<OrderItem>> getOrders({OrderStatus? filter}) async {
    await _simulateDelayAndOccasionalFailure();
    if (filter != null) {
      return mockOrders.where((order) => order.status == filter).toList();
    }
    return mockOrders;
  }

  @override
  Future<void> acceptOrder(String orderId) async {
    await _simulateDelayAndOccasionalFailure();
    // In a mock scenario, we'd update the local list, but since it's immutable in constants, 
    // we just simulate a successful response for now.
    return;
  }
}
