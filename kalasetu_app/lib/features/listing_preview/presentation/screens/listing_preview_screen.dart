import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:kalasetu_app/core/constants/app_colors.dart';
import 'package:kalasetu_app/core/models/generated_listing.dart';
import 'package:kalasetu_app/features/providers.dart';

class ListingPreviewScreen extends ConsumerStatefulWidget {
  final List<String> imagePaths;
  final String audioPath;

  const ListingPreviewScreen({
    super.key,
    required this.imagePaths,
    required this.audioPath,
  });

  @override
  ConsumerState<ListingPreviewScreen> createState() => _ListingPreviewScreenState();
}

class _ListingPreviewScreenState extends ConsumerState<ListingPreviewScreen> {
  GeneratedListing? _generatedListing;
  bool _isLoading = true;
  bool _isEnglish = true;
  double? _editedPrice;
  bool _isPublishing = false;
  String? _error;
  bool _showMontage = false;

  @override
  void initState() {
    super.initState();
    _generateListing();
  }

  Future<void> _generateListing() async {
    try {
      final apiClient = ref.read(apiClientProvider);

      final result = await apiClient.generateListing(
        imagePaths: widget.imagePaths,
        audioPath: widget.audioPath,
        languageCode: 'en',
      );
      
      if (mounted) {
        setState(() {
          _generatedListing = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to process listing: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _publishListing() async {
    setState(() {
      _isPublishing = true;
    });

    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.publishToOndc(_generatedListing!.id);
      
      if (mounted) {
        context.go('/listings');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPublishing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to publish: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              const Text('Processing your craft...', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('AI Vision Studio is enhancing your product photo'),
              const SizedBox(height: 32),
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(width: 300, height: 200, color: Colors.white),
              )
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _generateListing, child: const Text('Retry'))
            ],
          ),
        ),
      );
    }

    final listing = _generatedListing!;
    final firstImage = widget.imagePaths.isNotEmpty ? widget.imagePaths.first : '';
    final enhancedImage = listing.enhancedImage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Listing'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/voice', extra: widget.imagePaths),
        ),
      ),
      body: _isPublishing
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Quality Guidance Banner ──
                  if (enhancedImage.userMessage != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lightbulb_outline, color: AppColors.warning, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              enhancedImage.userMessage!,
                              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // ── Before / After Toggle ──
                  if (firstImage.isNotEmpty) ...[
                    if (enhancedImage.montageUrl != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SegmentedButton<bool>(
                            segments: const [
                              ButtonSegment(value: false, label: Text('Side-by-Side')),
                              ButtonSegment(value: true, label: Text('Montage')),
                            ],
                            selected: {_showMontage},
                            onSelectionChanged: (set) => setState(() => _showMontage = set.first),
                            style: SegmentedButton.styleFrom(
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),

                    // Montage view
                    if (_showMontage && enhancedImage.montageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: _buildImage(enhancedImage.montageUrl!, height: 220),
                      )
                    else
                      // Side-by-side cards
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                    child: _buildImage(firstImage, height: 140),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Before', style: TextStyle(color: AppColors.textSecondary)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Card(
                              elevation: 4,
                              shadowColor: AppColors.primary.withValues(alpha: 0.3),
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                    child: _buildImage(enhancedImage.enhancedImagePath, height: 140),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('After (AI Studio)', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                  const SizedBox(height: 16),

                  // ── AI Enhancement Tags ──
                  if (enhancedImage.enhancementsApplied.isNotEmpty) ...[
                    const Text(
                      'AI Studio Enhancements',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: enhancedImage.enhancementsApplied.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle, color: AppColors.success, size: 14),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  tag,
                                  style: const TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // ── Description ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(value: true, label: Text('EN')),
                          ButtonSegment(value: false, label: Text('हिं')),
                        ],
                        selected: {_isEnglish},
                        onSelectionChanged: (set) => setState(() => _isEnglish = set.first),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _isEnglish ? listing.descriptionEn : listing.descriptionHi,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Price ──
                  const Text('Fair Price', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      // Show edit price dialog
                    },
                    child: Text(
                      '${listing.pricing.currency} ${_editedPrice ?? listing.pricing.suggestedPrice}',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Materials:'), Text('${listing.pricing.currency} ${listing.pricing.materialCost}')]),
                          const SizedBox(height: 8),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Labor (${listing.pricing.laborHours} hrs):'), Text('${listing.pricing.currency} ${listing.pricing.laborCost}')]),
                          const SizedBox(height: 8),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Fair margin:'), Text('${listing.pricing.currency} ${listing.pricing.fairMargin}')]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Category ──
                  Row(
                    children: [
                      const Icon(Icons.local_offer, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text('${listing.category} > ${listing.subcategory}', style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 48),

                  // ── Actions ──
                  ElevatedButton(
                    onPressed: _publishListing,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Approve & Push to ONDC', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {
                      // Edit mode
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Edit Details', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildImage(String path, {double height = 120}) {
    if (path.startsWith('data:image')) {
      try {
        final commaIndex = path.indexOf(',');
        final base64String = commaIndex != -1 ? path.substring(commaIndex + 1) : path;
        return Image.memory(
          base64Decode(base64String),
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            height: height,
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image),
          ),
        );
      } catch (_) {
        return Container(height: height, color: Colors.grey[200], child: const Icon(Icons.image));
      }
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: height,
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image),
        ),
      );
    }
    final file = File(path);
    if (file.existsSync()) {
      return Image.file(
        file,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: height,
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image),
        ),
      );
    }
    return Container(
      height: height,
      color: Colors.grey[200],
      child: const Icon(Icons.image),
    );
  }
}
