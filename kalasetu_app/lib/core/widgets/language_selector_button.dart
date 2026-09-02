import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalasetu_app/core/constants/app_colors.dart';
import 'package:kalasetu_app/core/widgets/language_selector_sheet.dart';
import 'package:kalasetu_app/features/providers.dart';

class LanguageSelectorButton extends ConsumerWidget {
  const LanguageSelectorButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    
    AppLanguage activeLang = defaultLanguage;
    if (locale.languageCode != 'en') {
      activeLang = regionalLanguages.firstWhere(
        (l) => l.code == locale.languageCode,
        orElse: () => defaultLanguage,
      );
    }

    return InkWell(
      onTap: () => LanguageSelectorSheet.show(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.translate_rounded, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              activeLang.nativeName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.arrow_drop_down, size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
