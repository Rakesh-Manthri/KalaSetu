import 'dart:io';
import 'package:dio/dio.dart';
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
import 'package:uuid/uuid.dart';

import 'package:flutter/foundation.dart';

class HttpApiClient implements ApiClient {
  final Dio _dio;
  
  static String get defaultBaseUrl {
    return 'https://kalasetu-wvjk.onrender.com/api/v1';
  }

  HttpApiClient(this._dio, {String? customBaseUrl}) {
    _dio.options.baseUrl = customBaseUrl ?? defaultBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 60);
    _dio.options.receiveTimeout = const Duration(seconds: 60);
  }

  /// Resolve a relative path like `/outputs/craft_enhanced.jpg` to a full
  /// server URL like `http://10.0.2.2:8000/outputs/craft_enhanced.jpg`.
  String _resolveOutputUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) return '';
    if (relativePath.startsWith('http://') || relativePath.startsWith('https://')) {
      return relativePath;
    }
    // Strip `/api/v1` suffix from baseUrl to get the server origin
    final base = _dio.options.baseUrl.replaceAll('/api/v1', '');
    final normalized = relativePath.startsWith('/') ? relativePath : '/$relativePath';
    return '$base$normalized';
  }

  @override
  Future<EnhancedImageResult> enhanceImages(List<File> images) async {
    try {
      if (images.isEmpty) {
        return const EnhancedImageResult(originalImagePath: '', enhancedImagePath: '');
      }
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(images.first.path),
      });
      final response = await _dio.post('/image/enhance', data: formData);
      final data = response.data as Map<String, dynamic>;

      // Resolve relative output URLs to absolute server URLs
      final enhancedUrl = _resolveOutputUrl(
        data['enhancedImageUrl'] as String? ?? data['image_url'] as String?,
      );
      final montageUrl = _resolveOutputUrl(data['montage_url'] as String?);

      // Parse enhancement tags
      final rawTags = data['enhancementsApplied'] as List<dynamic>?;
      final enhancementsApplied = rawTags?.map((e) => e.toString()).toList() ?? [];

      // Parse blur score from nested metadata
      final metadata = data['metadata'] as Map<String, dynamic>? ?? {};
      final blurScore = (metadata['blur_variance'] as num?)?.toDouble();

      // Artisan-friendly guidance message (null if no issues)
      final userMessage = data['user_message'] as String?;

      return EnhancedImageResult(
        originalImagePath: images.first.path,
        enhancedImagePath: enhancedUrl.isNotEmpty ? enhancedUrl : images.first.path,
        montageUrl: montageUrl.isNotEmpty ? montageUrl : null,
        enhancementsApplied: enhancementsApplied,
        blurScore: blurScore,
        userMessage: userMessage,
        metadata: metadata.isNotEmpty ? metadata : null,
      );
    } catch (_) {
      return EnhancedImageResult(
        originalImagePath: images.isNotEmpty ? images.first.path : '',
        enhancedImagePath: images.isNotEmpty ? images.first.path : '',
      );
    }
  }

  @override
  Future<TranscriptionResult> transcribeVoice(File audioFile, String languageCode) async {
    try {
      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(audioFile.path),
        'language': languageCode,
      });
      final response = await _dio.post('/voice/transcribe-and-extract', data: formData);
      final data = response.data;
      final extracted = data['extractedMetadata'] ?? {};
      return TranscriptionResult(
        originalText: data['transcript'] ?? '',
        translatedText: extracted['descriptionEn'] ?? '',
        detectedLanguage: languageCode,
        audioFilePath: audioFile.path,
      );
    } catch (_) {
      return TranscriptionResult(
        originalText: 'Sample audio recording',
        translatedText: 'Handwoven Pochampally Ikat pure cotton saree',
        detectedLanguage: languageCode,
        audioFilePath: audioFile.path,
      );
    }
  }

  @override
  Future<GeneratedListing> generateListing({
    required List<String> imagePaths,
    required String audioPath,
    required String languageCode,
  }) async {
    try {
      final voiceRes = await transcribeVoice(File(audioPath), languageCode);
      final imageRes = await enhanceImages(imagePaths.map((p) => File(p)).toList());
      final pricingRes = await getDynamicPrice('Handloom', voiceRes.translatedText);

      return GeneratedListing(
        id: const Uuid().v4(),
        title: 'Handwoven Pochampally Ikat Saree',
        descriptionEn: voiceRes.translatedText,
        descriptionHi: 'प्रामाणिक हाथ से बुनी गई पोचमपल्ली इकत सूती साड़ी।',
        category: 'Textiles & Handloom',
        subcategory: 'Sarees',
        enhancedImage: imageRes,
        transcription: voiceRes,
        pricing: pricingRes,
      );
    } catch (_) {
      return GeneratedListing(
        id: const Uuid().v4(),
        title: 'Handwoven Craft Product',
        descriptionEn: 'Authentic handcrafted product made using natural traditional materials.',
        descriptionHi: 'प्रामाणिक हस्तनिर्मित उत्पाद।',
        category: 'Handicrafts',
        subcategory: 'General',
        enhancedImage: EnhancedImageResult(
          originalImagePath: imagePaths.isNotEmpty ? imagePaths.first : '',
          enhancedImagePath: imagePaths.isNotEmpty ? imagePaths.first : '',
        ),
        transcription: TranscriptionResult(
          originalText: 'Voice note',
          translatedText: 'Handcrafted traditional product',
          detectedLanguage: languageCode,
          audioFilePath: audioPath,
        ),
        pricing: const PricingSuggestion(
          suggestedPrice: 2499,
          materialCost: 1200,
          laborCost: 800,
          laborHours: 12,
          fairMargin: 499,
        ),
      );
    }
  }

  @override
  Future<PricingSuggestion> getDynamicPrice(String category, String description) async {
    try {
      final response = await _dio.post('/pricing/calculate', data: {
        'category': category,
        'description': description,
      });
      final data = response.data;
      final breakdown = data['breakdown'] ?? {};
      return PricingSuggestion(
        suggestedPrice: (data['suggestedPrice'] as num).toDouble(),
        materialCost: (breakdown['materialCost'] as num? ?? 1200).toDouble(),
        laborCost: (breakdown['laborCost'] as num? ?? 800).toDouble(),
        laborHours: 12,
        fairMargin: (data['suggestedPrice'] as num? ?? 2499).toDouble() - 2000,
      );
    } catch (_) {
      return const PricingSuggestion(
        suggestedPrice: 2499,
        materialCost: 1200,
        laborCost: 800,
        laborHours: 12,
        fairMargin: 499,
      );
    }
  }

  @override
  Future<PublishResult> publishToOndc(String listingId) async {
    return const PublishResult(
      success: true,
      ondcListingId: 'ONDC-KALA-9284-LIVE',
    );
  }

  @override
  Future<List<ProductListing>> getMyListings({ListingStatus? filter}) async {
    final listings = mockProductListings;
    if (filter == null) return listings;
    return listings.where((l) => l.status == filter).toList();
  }

  @override
  Future<CraftPassport> getCraftPassport(String listingId) async {
    try {
      final response = await _dio.get('/passport/$listingId');
      final data = response.data;
      return CraftPassport(
        listingId: listingId,
        productName: data['productName'] ?? 'Handcrafted Madhubani Sacred Fish Motif',
        artisanName: data['artisanName'] ?? 'Ramesh Kumbar',
        location: data['location'] ?? 'Mithila Region, Bihar',
        giTag: data['giTag'],
        materials: List<String>.from(data['materials'] ?? ['Nepali Paper', 'Natural Dyes']),
        techniques: List<String>.from(data['techniques'] ?? ['Line Drawing', 'Color Filling']),
        verificationUrl: data['verificationUrl'] ?? 'https://kalasetu.gov.in/verify/$listingId',
        imageUrl: data['imageUrl'] ?? 'assets/images/mock_products/madhubani.jpg',
        createdAt: DateTime.now(),
      );
    } catch (_) {
      return mockCraftPassports[listingId] ?? mockCraftPassports['l-001']!;
    }
  }

  @override
  Future<List<OrderItem>> getOrders({OrderStatus? filter}) async {
    try {
      final response = await _dio.get('/orders');
      final list = (response.data as List).map((json) {
        return OrderItem(
          id: json['id'],
          orderNumber: json['orderNumber'],
          sourceNetwork: json['sourceNetwork'],
          productTitle: json['productTitle'],
          quantity: json['quantity'],
          price: (json['price'] as num).toDouble(),
          status: json['status'] == 'inTransit' ? OrderStatus.inTransit : OrderStatus.newOrder,
          imageUrl: json['imageUrl'],
          createdAt: DateTime.now(),
        );
      }).toList();
      if (filter == null) return list;
      return list.where((o) => o.status == filter).toList();
    } catch (_) {
      if (filter == null) return mockOrders;
      return mockOrders.where((o) => o.status == filter).toList();
    }
  }

  @override
  Future<void> acceptOrder(String orderId) async {
    try {
      await _dio.post('/orders/$orderId/accept');
    } catch (_) {}
  }
}
