import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:kalasetu_app/core/constants/app_colors.dart';
import 'package:kalasetu_app/core/constants/app_dimensions.dart';

class LoadingOverlay extends StatelessWidget {
  final String message;
  final bool useShimmer;

  const LoadingOverlay({
    super.key,
    required this.message,
    this.useShimmer = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingXl),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              const SizedBox(height: AppDimensions.spacingLg),
              if (useShimmer)
                Shimmer.fromColors(
                  baseColor: AppColors.textPrimary,
                  highlightColor: AppColors.textSecondary,
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              else
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
