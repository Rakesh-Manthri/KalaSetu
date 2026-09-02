import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/api_constants.dart';
import '../core/models/enhance_result.dart';

/// Custom exception for structured AI Vision Studio errors.
class VisionStudioException implements Exception {
  final String code;
  final String userMessage;
  final int? statusCode;
  final dynamic details;

  VisionStudioException({
    required this.code,
    required this.userMessage,
    this.statusCode,
    this.details,
  });

  bool get isBlurry => code == 'IMAGE_TOO_BLURRY';

  @override
  String toString() => 'VisionStudioException(code: $code, message: $userMessage)';
}

/// HTTP API Client for KalaSetu AI Vision Studio service.
class VisionStudioClient {
  final Dio _dio;

  VisionStudioClient({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConstants.baseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 45),
                sendTimeout: const Duration(seconds: 30),
                headers: {
                  'Accept': 'application/json',
                },
              ),
            );

  /// Submits an artisan product photo to POST /api/v1/image/enhance via multipart/form-data.
  Future<EnhanceResult> uploadAndEnhance({
    required File imageFile,
    String quality = 'balanced',
    bool removeBackground = true,
    bool correctLighting = true,
    String backgroundColor = '#FFFFFF',
    ProgressCallback? onSendProgress,
  }) async {
    final fileName = imageFile.path.split(Platform.pathSeparator).last;

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
      ),
      'quality': quality,
      'remove_background': removeBackground.toString(),
      'correct_lighting': correctLighting.toString(),
      'background_color': backgroundColor,
    });

    try {
      final response = await _dio.post(
        ApiConstants.enhanceEndpoint,
        data: formData,
        onSendProgress: onSendProgress,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final Map<String, dynamic> responseData;
      if (response.data is Map<String, dynamic>) {
        responseData = response.data as Map<String, dynamic>;
      } else if (response.data is Map) {
        responseData = Map<String, dynamic>.from(response.data as Map);
      } else {
        throw VisionStudioException(
          code: 'UNEXPECTED_RESPONSE',
          userMessage: 'Unexpected server response format. Please try again.',
        );
      }

      // Handle HTTP 400 or server-reported error states
      if (response.statusCode == 400 || responseData['status'] == 'error' || responseData['success'] == false) {
        final errCode = responseData['error_code']?.toString() ?? 'STAGE_FAILED';
        String userMsg = responseData['user_message']?.toString() ??
            responseData['detail']?.toString() ??
            responseData['message']?.toString() ??
            'Image enhancement failed.';

        if (errCode == 'IMAGE_TOO_BLURRY') {
          userMsg = 'Photo is blurry. Please hold steady, tap the product to focus, and take another shot.';
        }

        throw VisionStudioException(
          code: errCode,
          userMessage: userMsg,
          statusCode: response.statusCode,
          details: responseData,
        );
      }

      return EnhanceResult.fromJson(responseData, localRawPath: imageFile.path);
    } on DioException catch (dioErr) {
      if (dioErr.response?.data is Map) {
        final Map errData = dioErr.response!.data as Map;
        final code = errData['error_code']?.toString() ?? 'NETWORK_ERROR';
        String msg = errData['user_message']?.toString() ??
            errData['detail']?.toString() ??
            'Connection issue with enhancement server.';
        if (code == 'IMAGE_TOO_BLURRY') {
          msg = 'Photo is blurry. Please hold steady, tap the product to focus, and take another shot.';
        }
        throw VisionStudioException(
          code: code,
          userMessage: msg,
          statusCode: dioErr.response?.statusCode,
          details: errData,
        );
      }

      if (dioErr.type == DioExceptionType.connectionTimeout ||
          dioErr.type == DioExceptionType.receiveTimeout ||
          dioErr.type == DioExceptionType.sendTimeout) {
        throw VisionStudioException(
          code: 'TIMEOUT',
          userMessage: 'Connection timed out. Please check your backend connection and try again.',
        );
      }

      throw VisionStudioException(
        code: 'NETWORK_ERROR',
        userMessage: 'Could not connect to KalaSetu server (${ApiConstants.baseUrl}). Make sure the backend is running.',
        details: dioErr.message,
      );
    } catch (e) {
      if (e is VisionStudioException) rethrow;
      throw VisionStudioException(
        code: 'UNKNOWN_ERROR',
        userMessage: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Health check probe
  Future<bool> checkHealth() async {
    try {
      final res = await _dio.get(
        ApiConstants.visionHealthEndpoint,
        options: Options(
          sendTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
        ),
      );
      return res.statusCode == 200 && res.data['status'] == 'healthy';
    } catch (_) {
      return false;
    }
  }
}

/// Global Riverpod provider for VisionStudioClient
final visionStudioClientProvider = Provider<VisionStudioClient>((ref) {
  return VisionStudioClient();
});
