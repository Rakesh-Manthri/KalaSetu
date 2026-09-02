/// Result of the AI Vision Studio image enhancement pipeline.
///
/// Maps to the backend's `EnhanceResponse` contract from the
/// `ai-vision-studio` module (5-stage CPU pipeline).
class EnhancedImageResult {
  /// Path or URL to the original artisan photo.
  final String originalImagePath;

  /// Path or URL to the AI-enhanced studio photo (1000×1000, clean backdrop).
  final String enhancedImagePath;

  /// URL to the side-by-side Before/After pitch montage (if generated).
  final String? montageUrl;

  /// URL to the transparent PNG cutout (background removed).
  final String? transparentCutoutUrl;

  /// Human-readable list of enhancements applied by Vision Studio.
  /// Example: ["Background isolated & studio backdrop applied",
  ///           "Lighting & shadows calibrated for e-commerce",
  ///           "1:1 square canvas framing (1000x1000)"]
  final List<String> enhancementsApplied;

  /// Laplacian variance blur score from validation stage.
  /// Higher = sharper. Null if not computed.
  final double? blurScore;

  /// Artisan-friendly guidance message from Vision Studio.
  /// Non-null when a quality issue was detected but the image was still processed
  /// (e.g. mild blur, lighting correction applied).
  final String? userMessage;

  /// Raw metadata from the Vision Studio pipeline (processing time, resolution, etc.).
  final Map<String, dynamic>? metadata;

  const EnhancedImageResult({
    required this.originalImagePath,
    required this.enhancedImagePath,
    this.montageUrl,
    this.transparentCutoutUrl,
    this.enhancementsApplied = const [],
    this.blurScore,
    this.userMessage,
    this.metadata,
  });
}
