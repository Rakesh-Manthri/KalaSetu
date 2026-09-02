import 'dart:io';
import 'package:flutter/foundation.dart';

/// API configuration for KalaSetu Backend & AI Vision Studio
class ApiConstants {
  // Default base URL dynamically resolved per host platform
  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }
    if (Platform.isAndroid) {
      // 10.0.2.2 maps to the host machine's localhost in the Android emulator
      return 'http://10.0.2.2:8000';
    }
    // iOS simulator / Windows Desktop / macOS / Linux
    return 'http://127.0.0.1:8000';
  }

  // Active base URL (modifiable at runtime for live physical device WiFi testing)
  static String baseUrl = defaultBaseUrl;

  // Endpoint routes
  static const String enhanceEndpoint = '/api/v1/image/enhance';
  static const String visionHealthEndpoint = '/api/v1/image/health';
  static const String staticOutputsPrefix = '/outputs';

  /// Converts a relative `/outputs/...` URI into a full fetchable HTTP URL.
  static String resolveImageUrl(String relativePathOrUrl) {
    if (relativePathOrUrl.startsWith('http://') || relativePathOrUrl.startsWith('https://')) {
      return relativePathOrUrl;
    }
    final cleanPath = relativePathOrUrl.startsWith('/') ? relativePathOrUrl : '/$relativePathOrUrl';
    return '$baseUrl$cleanPath';
  }
}
