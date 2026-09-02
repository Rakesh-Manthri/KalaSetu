import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/models/enhance_result.dart';
import '../listing_preview/studio_preview_screen.dart';
import 'capture_controller.dart';

/// Interactive Camera / "Click a Pic" capture screen for rural artisans.
class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  File? _selectedLocalImage;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  /// Triggers photo enhancement and handles blur / success states
  Future<void> _processImage(File imageFile) async {
    final controller = ref.read(captureControllerProvider.notifier);
    final result = await controller.processCapturedImage(imageFile);

    if (!mounted) return;

    final state = ref.read(captureControllerProvider);

    // 1. Actionable Blur / Error Handling
    if (state.isBlurry || state.errorMessage != null) {
      HapticFeedback.heavyImpact();
      _showBlurryOrErrorDialog(
        title: state.isBlurry ? 'Photo is Blurry' : 'Enhancement Notice',
        message: state.errorMessage ??
            'Photo is blurry. Please hold steady, tap the product to focus, and take another shot.',
        isBlurry: state.isBlurry,
      );
      return;
    }

    // 2. Success: navigate to Studio Preview container
    if (result != null && (result.success || result.status == 'success')) {
      HapticFeedback.lightImpact();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => StudioPreviewScreen(result: result),
        ),
      );
    }
  }

  void _showBlurryOrErrorDialog({
    required String title,
    required String message,
    required bool isBlurry,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isBlurry ? AppColors.warningAmber.withOpacity(0.15) : AppColors.errorRed.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isBlurry ? Icons.blur_on_rounded : Icons.info_outline_rounded,
                color: isBlurry ? AppColors.warningAmber : AppColors.errorRed,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: AppColors.slateDark,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
                color: AppColors.grey800,
              ),
            ),
            if (isBlurry) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.studioBackdrop,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.grey200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.tips_and_updates_outlined, color: AppColors.terracotta, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tip: Place your craft near a window and hold your phone with both hands.',
                        style: TextStyle(fontSize: 12, color: AppColors.grey800),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(ctx).pop();
                ref.read(captureControllerProvider.notifier).reset();
              },
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: const Text(
                'Retake Photo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.terracotta,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Fallback demo/sample generator for testing without physical camera
  Future<void> _useFixtureImage() async {
    // Check if valid sample exists in backend fixtures or create a quick test image
    final sampleCandidates = [
      '../ai-vision-studio/tests/fixtures/valid_sample.jpg',
      'ai-vision-studio/tests/fixtures/valid_sample.jpg',
      '../../ai-vision-studio/tests/fixtures/valid_sample.jpg',
    ];
    for (final p in sampleCandidates) {
      final f = File(p);
      if (f.existsSync()) {
        setState(() => _selectedLocalImage = f);
        await _processImage(f);
        return;
      }
    }
    // If not found, notify user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sample fixture not found. Connect camera or upload an image.'),
        backgroundColor: AppColors.slateDark,
      ),
    );
  }

  /// Simulate blurry capture to test blur rejection feedback
  Future<void> _simulateBlurryCapture() async {
    // Test blurry error feedback directly
    final controller = ref.read(captureControllerProvider.notifier);
    stateNotifierBlurrySim();
  }

  void stateNotifierBlurrySim() {
    _showBlurryOrErrorDialog(
      title: 'Photo is Blurry',
      message: 'Photo is blurry. Please hold steady, tap the product to focus, and take another shot.',
      isBlurry: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final captureState = ref.watch(captureControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.slateDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Vision Studio',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              'Offline 5-Stage Enhancement (SIH PS 26090)',
              style: TextStyle(fontSize: 11, color: AppColors.grey300),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.terracotta.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.terracotta.withOpacity(0.5)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt, color: AppColors.terracotta, size: 16),
                SizedBox(width: 4),
                Text(
                  '100% OFFLINE CPU',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.terracotta),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. Camera Viewfinder Area
          Column(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.grey600.withOpacity(0.3), width: 1.5),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Viewfinder Grid & Corner Focus Reticles
                      CustomPaint(
                        size: Size.infinite,
                        painter: _ViewfinderOverlayPainter(),
                      ),

                      // Guide Hint
                      Positioned(
                        top: 24,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.crop_free, color: Colors.white70, size: 16),
                              SizedBox(width: 8),
                              Text(
                                'Center your craft item inside the box',
                                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Selected image preview if captured/selected
                      if (_selectedLocalImage != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(
                            _selectedLocalImage!,
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // 2. Enhancement Settings Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFeatureChip(
                      label: 'Background Removal',
                      icon: Icons.layers_outlined,
                      isActive: captureState.removeBackground,
                      onTap: () => ref
                          .read(captureControllerProvider.notifier)
                          .toggleRemoveBackground(!captureState.removeBackground),
                    ),
                    const SizedBox(width: 10),
                    _buildFeatureChip(
                      label: 'Lighting Balance',
                      icon: Icons.wb_sunny_outlined,
                      isActive: captureState.correctLighting,
                      onTap: () => ref
                          .read(captureControllerProvider.notifier)
                          .toggleCorrectLighting(!captureState.correctLighting),
                    ),
                  ],
                ),
              ),

              // 3. Shutter & Action Bar (Large 56dp+ touch target for rural artisans)
              Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                decoration: const BoxDecoration(
                  color: Color(0xFF131B26),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Secondary action: Sample Craft Photo
                        IconButton(
                          iconSize: 32,
                          tooltip: 'Load Sample Craft Fixture',
                          icon: const Icon(Icons.photo_library_outlined, color: Colors.white70),
                          onPressed: captureState.isProcessing ? null : _useFixtureImage,
                        ),

                        // Master "Click a Pic" / Camera Capture Button
                        GestureDetector(
                          onTap: captureState.isProcessing ? null : _useFixtureImage,
                          child: ScaleTransition(
                            scale: _pulseAnimation,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.terracotta,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.terracotta.withOpacity(0.45),
                                    blurRadius: 18,
                                    spreadRadius: 3,
                                  ),
                                ],
                                border: Border.all(color: Colors.white, width: 4),
                              ),
                              child: const Center(
                                child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 36),
                              ),
                            ),
                          ),
                        ),

                        // Test Action: Test Blurry Alert
                        IconButton(
                          iconSize: 28,
                          tooltip: 'Simulate Blurry Shot',
                          icon: const Icon(Icons.blur_linear_rounded, color: Colors.white70),
                          onPressed: captureState.isProcessing ? null : _simulateBlurryCapture,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Click a Pic',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 4. Processing Overlay with Spinner & Status Text
          if (captureState.isProcessing)
            Container(
              color: Colors.black.withOpacity(0.75),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 20, spreadRadius: 4),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 54,
                        height: 54,
                        child: CircularProgressIndicator(
                          strokeWidth: 4.5,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.terracotta),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        captureState.statusText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.slateDark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Removing background, calibrating warm studio lighting & creating 1:1 e-commerce canvas...',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: AppColors.grey600, height: 1.35),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.terracotta.withOpacity(0.18) : Colors.white10,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.terracotta : Colors.white24,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isActive ? AppColors.terracotta : Colors.white70),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? AppColors.terracotta : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter rendering the framing overlay with corner focus brackets
class _ViewfinderOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.78,
      height: size.width * 0.78, // 1:1 square guide
    );

    const cornerLength = 26.0;

    // Top-Left
    canvas.drawLine(rect.topLeft, Offset(rect.left + cornerLength, rect.top), paint);
    canvas.drawLine(rect.topLeft, Offset(rect.left, rect.top + cornerLength), paint);

    // Top-Right
    canvas.drawLine(rect.topRight, Offset(rect.right - cornerLength, rect.top), paint);
    canvas.drawLine(rect.topRight, Offset(rect.right, rect.top + cornerLength), paint);

    // Bottom-Left
    canvas.drawLine(rect.bottomLeft, Offset(rect.left + cornerLength, rect.bottom), paint);
    canvas.drawLine(rect.bottomLeft, Offset(rect.left, rect.bottom - cornerLength), paint);

    // Bottom-Right
    canvas.drawLine(rect.bottomRight, Offset(rect.right - cornerLength, rect.bottom), paint);
    canvas.drawLine(rect.bottomRight, Offset(rect.right, rect.bottom - cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
