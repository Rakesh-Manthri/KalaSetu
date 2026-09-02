import 'dart:io';
import 'package:flutter/foundation.dart';

/// API configuration for KalaSetu Backend & AI Vision Studio
class ApiConstants {
  /// Render production live backend URL
  static const String productionUrl = 'https://kalasetu-wvjk.onrender.com';

  // Default base URL dynamically resolved per host platform
  static String get defaultBaseUrl {
    // Production Render deployment URL as primary default
    return productionUrl;
  }

  // Active base URL
  static String baseUrl = productionUrl;

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
