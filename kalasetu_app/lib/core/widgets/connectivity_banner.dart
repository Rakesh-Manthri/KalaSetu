import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalasetu_app/core/constants/app_colors.dart';
import 'package:kalasetu_app/core/constants/app_dimensions.dart';
import 'package:kalasetu_app/core/network/connectivity_provider.dart';
import 'package:kalasetu_app/l10n/app_localizations.dart';

class ConnectivityBanner extends ConsumerWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(connectivityStatusProvider);
    final localizations = AppLocalizations.of(context);

    Color backgroundColor;
    String statusText;
    Color dotColor;

    switch (status) {
      case ConnectivityStatus.online:
        backgroundColor = AppColors.success.withValues(alpha: 0.1);
        statusText = localizations?.online ?? 'Online';
        dotColor = AppColors.success;
        break;
      case ConnectivityStatus.lowBandwidth:
        backgroundColor = AppColors.warning.withValues(alpha: 0.1);
        statusText = localizations?.lowBandwidth ?? 'Low Bandwidth';
        dotColor = AppColors.warning;
        break;
      case ConnectivityStatus.offline:
        backgroundColor = AppColors.error.withValues(alpha: 0.1);
        statusText = localizations?.offline ?? 'Offline';
        dotColor = AppColors.error;
        break;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.spacingXs,
        horizontal: AppDimensions.spacingMd,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingSm),
          Text(
            statusText,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
