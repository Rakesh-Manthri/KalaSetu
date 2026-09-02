import 'package:kalasetu_app/core/models/enhanced_image_result.dart';
import 'package:kalasetu_app/core/models/pricing_suggestion.dart';
import 'package:kalasetu_app/core/models/transcription_result.dart';

class GeneratedListing {
  final String id;
  final String title;
  final String descriptionEn;
  final String descriptionHi;
  final String category;
  final String subcategory;
  final EnhancedImageResult enhancedImage;
  final TranscriptionResult transcription;
  final PricingSuggestion pricing;

  const GeneratedListing({
    required this.id,
    required this.title,
    required this.descriptionEn,
    required this.descriptionHi,
    required this.category,
    required this.subcategory,
    required this.enhancedImage,
    required this.transcription,
    required this.pricing,
  });
}
