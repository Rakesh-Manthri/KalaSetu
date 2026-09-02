import '../constants/api_constants.dart';

/// Structured response container for the AI Vision Studio pipeline.
class EnhanceResult {
  final bool success;
  final String status;
  final String? imageUrl;
  final String? montageUrl;
  final String? fullImageUrl;
  final String? fullMontageUrl;
  final String? rawImagePath;
  final String? errorCode;
  final String? userMessage;
  final List<String> enhancementsApplied;
  final Map<String, dynamic> metadata;
  final List<dynamic> errors;

  EnhanceResult({
    required this.success,
    required this.status,
    this.imageUrl,
    this.montageUrl,
    this.fullImageUrl,
    this.fullMontageUrl,
    this.rawImagePath,
    this.errorCode,
    this.userMessage,
    this.enhancementsApplied = const [],
    this.metadata = const {},
    this.errors = const [],
  });

  bool get isBlurry => errorCode == 'IMAGE_TOO_BLURRY';

  factory EnhanceResult.fromJson(Map<String, dynamic> json, {String? localRawPath}) {
    final status = json['status']?.toString() ?? (json['success'] == true ? 'success' : 'error');
    final isSuccess = json['success'] == true || status == 'success' || status == 'partial';

    final rawImageUrl = json['image_url']?.toString() ?? json['enhancedImageUrl']?.toString();
    final rawMontageUrl = json['montage_url']?.toString();

    final List<String> enhancements = [];
    if (json['enhancementsApplied'] is List) {
      for (final item in json['enhancementsApplied']) {
        enhancements.add(item.toString());
      }
    }

    // Extract error code and user message if present
    String? errCode = json['error_code']?.toString();
    String? usrMsg = json['user_message']?.toString() ?? json['detail']?.toString() ?? json['message']?.toString();

    final errorsList = json['errors'] is List ? (json['errors'] as List) : [];
    if (errorsList.isNotEmpty && errCode == null) {
      final first = errorsList.first;
      if (first is Map) {
        errCode = first['code']?.toString();
        usrMsg ??= first['message']?.toString();
      }
    }

    if (errCode == 'IMAGE_TOO_BLURRY') {
      usrMsg = 'Photo is blurry. Please hold steady, tap the product to focus, and take another shot.';
    }

    return EnhanceResult(
      success: isSuccess,
      status: status,
      imageUrl: rawImageUrl,
      montageUrl: rawMontageUrl,
      fullImageUrl: rawImageUrl != null ? ApiConstants.resolveImageUrl(rawImageUrl) : null,
      fullMontageUrl: rawMontageUrl != null ? ApiConstants.resolveImageUrl(rawMontageUrl) : null,
      rawImagePath: localRawPath,
      errorCode: errCode,
      userMessage: usrMsg,
      enhancementsApplied: enhancements,
      metadata: json['metadata'] is Map ? (json['metadata'] as Map<String, dynamic>) : {},
      errors: errorsList,
    );
  }

  factory EnhanceResult.blurryFailure({String? localRawPath}) {
    return EnhanceResult(
      success: false,
      status: 'error',
      rawImagePath: localRawPath,
      errorCode: 'IMAGE_TOO_BLURRY',
      userMessage: 'Photo is blurry. Please hold steady, tap the product to focus, and take another shot.',
      errors: [
        {'code': 'IMAGE_TOO_BLURRY', 'message': 'Blur check failed'}
      ],
    );
  }
}
