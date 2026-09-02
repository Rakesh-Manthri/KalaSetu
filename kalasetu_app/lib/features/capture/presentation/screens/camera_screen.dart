import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import 'package:kalasetu_app/core/constants/app_colors.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  final List<String> capturedImages = [];
  int currentAngleIndex = 0;
  bool _isInitialized = false;

  final List<String> angles = [
    'Front View',
    'Detail / Texture',
    'Craft in Progress'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _controller = CameraController(
          _cameras.first,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _controller!.initialize();
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final XFile picture = await _controller!.takePicture();
      setState(() {
        capturedImages.add(picture.path);
        if (currentAngleIndex < 2) {
          currentAngleIndex++;
        }
      });
    } catch (e) {
      debugPrint('Error taking picture: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('Step ${capturedImages.length + 1} of 3'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_controller != null) CameraPreview(_controller!),
                Positioned(
                  top: 24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      currentAngleIndex < 3 ? angles[currentAngleIndex] : 'All Captured',
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.black,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  height: 64,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      final hasImage = index < capturedImages.length;
                      return Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(8),
                          image: hasImage
                              ? DecorationImage(
                                  image: FileImage(File(capturedImages[index])),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: hasImage
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : null,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: angles
                      .map((angle) => Text(
                            angle,
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: capturedImages.isNotEmpty
                          ? () {
                              setState(() {
                                capturedImages.removeLast();
                                if (currentAngleIndex > 0) currentAngleIndex--;
                              });
                            }
                          : null,
                      child: const Text('Retake', style: TextStyle(color: Colors.white)),
                    ),
                    GestureDetector(
                      onTap: capturedImages.length < 3 ? _takePicture : null,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          color: capturedImages.length < 3 ? AppColors.primary : Colors.grey,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: capturedImages.isNotEmpty
                          ? () {
                              context.go('/voice', extra: capturedImages);
                            }
                          : null,
                      child: Text(
                        'Next →',
                        style: TextStyle(
                            color: capturedImages.isNotEmpty ? Colors.white : Colors.grey),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
