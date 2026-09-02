import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalasetu_app/core/constants/app_colors.dart';
import 'package:kalasetu_app/features/providers.dart';

class AppLanguage {
  final String code;
  final String name;
  final String nativeName;
  final String flag;
  final bool isDefault;

  const AppLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
    this.isDefault = false,
  });
}

const AppLanguage defaultLanguage = AppLanguage(
  code: 'en',
  name: 'English',
  nativeName: 'English',
  flag: '🇬🇧',
  isDefault: true,
);

const List<AppLanguage> regionalLanguages = [
  AppLanguage(code: 'hi', name: 'Hindi', nativeName: 'हिंदी', flag: '🇮🇳'),
  AppLanguage(code: 'te', name: 'Telugu', nativeName: 'తెలుగు', flag: '🇮🇳'),
  AppLanguage(code: 'ta', name: 'Tamil', nativeName: 'தமிழ்', flag: '🇮🇳'),
  AppLanguage(code: 'kn', name: 'Kannada', nativeName: 'ಕನ್ನಡ', flag: '🇮🇳'),
  AppLanguage(code: 'mr', name: 'Marathi', nativeName: 'मराठी', flag: '🇮🇳'),
  AppLanguage(code: 'bn', name: 'Bengali', nativeName: 'বাংলা', flag: '🇮🇳'),
];

class LanguageSelectorSheet extends ConsumerWidget {
  const LanguageSelectorSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const LanguageSelectorSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Select Language',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
            ),
            const SizedBox(height: 12),
            const Divider(),
            
            // Section 1: Default Language
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              child: Text(
                'DEFAULT LANGUAGE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            _buildTile(context, ref, defaultLanguage, currentLocale.languageCode),

            const SizedBox(height: 12),
            const Divider(),

            // Section 2: Regional Indian Languages
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              child: Text(
                'REGIONAL INDIAN LANGUAGES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: regionalLanguages.length,
                itemBuilder: (context, index) {
                  return _buildTile(context, ref, regionalLanguages[index], currentLocale.languageCode);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, WidgetRef ref, AppLanguage lang, String currentCode) {
    final isSelected = currentCode == lang.code;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Text(lang.flag, style: const TextStyle(fontSize: 24)),
      title: Text(
        lang.nativeName,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontSize: 16,
        ),
      ),
      subtitle: Text(lang.name, style: const TextStyle(fontSize: 12)),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : const Icon(Icons.circle_outlined, color: Colors.grey),
      onTap: () {
        ref.read(localeProvider.notifier).state = Locale(lang.code);
        Navigator.pop(context);
      },
    );
  }
}
