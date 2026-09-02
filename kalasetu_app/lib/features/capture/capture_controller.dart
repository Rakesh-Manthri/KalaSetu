import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/enhance_result.dart';
import '../../services/vision_studio_client.dart';

/// State of the photo capture and AI enhancement process
class CaptureState {
  final bool isProcessing;
  final String statusText;
  final String? localCapturedPath;
  final EnhanceResult? result;
  final String? errorMessage;
  final bool isBlurry;
  final String quality;
  final bool removeBackground;
  final bool correctLighting;

  const CaptureState({
    this.isProcessing = false,
    this.statusText = 'Ready to capture',
    this.localCapturedPath,
    this.result,
    this.errorMessage,
    this.isBlurry = false,
    this.quality = 'balanced',
    this.removeBackground = true,
    this.correctLighting = true,
  });

  CaptureState copyWith({
    bool? isProcessing,
    String? statusText,
    String? localCapturedPath,
    EnhanceResult? result,
    String? errorMessage,
    bool? isBlurry,
    String? quality,
    bool? removeBackground,
    bool? correctLighting,
  }) {
    return CaptureState(
      isProcessing: isProcessing ?? this.isProcessing,
      statusText: statusText ?? this.statusText,
      localCapturedPath: localCapturedPath ?? this.localCapturedPath,
      result: result ?? this.result,
      errorMessage: errorMessage,
      isBlurry: isBlurry ?? this.isBlurry,
      quality: quality ?? this.quality,
      removeBackground: removeBackground ?? this.removeBackground,
      correctLighting: correctLighting ?? this.correctLighting,
    );
  }
}

/// Riverpod StateNotifier managing the camera capture & studio enhancement lifecycle
class CaptureController extends StateNotifier<CaptureState> {
  final VisionStudioClient _client;

  CaptureController(this._client) : super(const CaptureState());

  void setQuality(String quality) {
    state = state.copyWith(quality: quality);
  }

  void toggleRemoveBackground(bool value) {
    state = state.copyWith(removeBackground: value);
  }

  void toggleCorrectLighting(bool value) {
    state = state.copyWith(correctLighting: value);
  }

  void reset() {
    state = const CaptureState();
  }

  /// Initiates upload and offline CPU AI enhancement for a captured or picked photo
  Future<EnhanceResult?> processCapturedImage(File imageFile) async {
    state = state.copyWith(
      isProcessing: true,
      statusText: 'Enhancing photo & balancing lighting...',
      localCapturedPath: imageFile.path,
      errorMessage: null,
      isBlurry: false,
    );

    try {
      final res = await _client.uploadAndEnhance(
        imageFile: imageFile,
        quality: state.quality,
        removeBackground: state.removeBackground,
        correctLighting: state.correctLighting,
      );

      state = state.copyWith(
        isProcessing: false,
        statusText: 'Enhancement complete!',
        result: res,
        isBlurry: false,
      );

      return res;
    } on VisionStudioException catch (e) {
      state = state.copyWith(
        isProcessing: false,
        statusText: 'Enhancement paused',
        errorMessage: e.userMessage,
        isBlurry: e.isBlurry,
      );
      return null;
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        statusText: 'Processing error',
        errorMessage: 'Unable to enhance image: $e',
        isBlurry: false,
      );
      return null;
    }
  }
}

/// Global provider for CaptureController
final captureControllerProvider =
    StateNotifierProvider<CaptureController, CaptureState>((ref) {
  final client = ref.watch(visionStudioClientProvider);
  return CaptureController(client);
});
