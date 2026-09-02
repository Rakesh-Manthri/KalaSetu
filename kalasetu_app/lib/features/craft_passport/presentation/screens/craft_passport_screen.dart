import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:kalasetu_app/core/constants/app_colors.dart';
import 'package:kalasetu_app/core/models/craft_passport.dart';
import 'package:kalasetu_app/features/providers.dart';

class CraftPassportScreen extends ConsumerStatefulWidget {
  final String listingId;

  const CraftPassportScreen({super.key, required this.listingId});

  @override
  ConsumerState<CraftPassportScreen> createState() => _CraftPassportScreenState();
}

class _CraftPassportScreenState extends ConsumerState<CraftPassportScreen> {
  CraftPassport? _passport;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPassport();
  }

  Future<void> _fetchPassport() async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final data = await apiClient.getCraftPassport(widget.listingId);
      if (mounted) {
        setState(() {
          _passport = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Digital Craft Passport'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.canPop() ? context.pop() : context.go('/listings'),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_passport == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Digital Craft Passport'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.canPop() ? context.pop() : context.go('/listings'),
          ),
        ),
        body: const Center(child: Text('Failed to load passport')),
      );
    }

    final p = _passport!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Craft Passport'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/listings'),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header Strip
                      Container(
                        height: 12,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.accent],
                          ),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Image Container
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: p.imageUrl.startsWith('http')
                            ? Image.network(
                                p.imageUrl,
                                width: 240,
                                height: 160,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 240,
                                  height: 160,
                                  color: AppColors.surfaceVariant,
                                  child: const Icon(Icons.diamond_outlined, size: 60, color: AppColors.primary),
                                ),
                              )
                            : Container(
                                width: 240,
                                height: 160,
                                color: AppColors.surfaceVariant,
                                child: const Icon(Icons.diamond_outlined, size: 60, color: AppColors.primary),
                              ),
                      ),
                      const Divider(height: 32),
                      // Info Rows
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                            _buildInfoRow(Icons.person, 'Artisan', p.artisanName),
                            const SizedBox(height: 12),
                            _buildInfoRow(Icons.location_on, 'Location', p.location),
                            const SizedBox(height: 12),
                            _buildInfoRow(Icons.verified, 'GI Tag', p.giTag ?? 'N/A'),
                            const SizedBox(height: 12),
                            _buildInfoRow(Icons.category, 'Materials', p.materials.join(', ')),
                            const SizedBox(height: 12),
                            _buildInfoRow(Icons.handyman, 'Techniques', p.techniques.join(', ')),
                          ],
                        ),
                      ),
                      const Divider(height: 32),
                      // QR Code
                      QrImageView(
                        data: p.verificationUrl,
                        version: QrVersions.auto,
                        size: 200.0,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Scan to verify authenticity',
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Share action
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share Passport', style: TextStyle(fontSize: 18)),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}
