import 'package:flutter/material.dart';

/// KalaSetu Heritage Color Palette
/// Terracotta & Trust Blue theme tailored for rural Indian artisans.
class AppColors {
  // Brand Primaries
  static const Color terracotta = Color(0xFFEA580C);       // Warm earthen clay
  static const Color terracottaDark = Color(0xFFC2410C);   // Deep terracotta
  static const Color terracottaLight = Color(0xFFFFF7ED);  // Soft terracotta wash

  // Trust Secondary
  static const Color trustBlue = Color(0xFF1A56DB);        // ONDC & Digital India Blue
  static const Color trustBlueDark = Color(0xFF1E429F);
  static const Color trustBlueLight = Color(0xFFEBF5FF);

  // Studio Canvas & Backgrounds
  static const Color studioBackdrop = Color(0xFFF4EFE6);   // Warm e-commerce cream
  static const Color surfaceLight = Color(0xFFFFFDF9);     // Off-white card canvas
  static const Color background = Color(0xFFF9FAFB);       // App background
  static const Color slateDark = Color(0xFF1E293B);        // Deep text / slate

  // Feedback & Accents
  static const Color successGreen = Color(0xFF16A34A);
  static const Color warningAmber = Color(0xFFD97706);
  static const Color errorRed = Color(0xFFDC2626);
  static const Color goldHeritage = Color(0xFFD97706);

  // Neutral Greys
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey800 = Color(0xFF1F2937);

  // ── Legacy Aliases (used across feature screens) ──
  static const Color primary = terracotta;
  static const Color primaryLight = terracottaLight;
  static const Color primaryDark = terracottaDark;
  static const Color primaryContainer = Color(0xFFFFEDD5);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF7C2D12);

  static const Color secondary = trustBlue;
  static const Color secondaryContainer = trustBlueLight;
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF1E3A8A);

  static const Color accent = trustBlue;
  static const Color surface = surfaceLight;
  static const Color surfaceVariant = grey100;
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = grey100;
  static const Color surfaceContainer = grey200;
  static const Color surfaceContainerHigh = grey300;

  static const Color onSurface = slateDark;
  static const Color onSurfaceVariant = grey600;
  static const Color outline = grey400;
  static const Color outlineVariant = grey300;

  static const Color success = successGreen;
  static const Color warning = warningAmber;
  static const Color error = errorRed;
  static const Color info = trustBlue;
  static const Color online = successGreen;
  static const Color textPrimary = slateDark;
  static const Color textSecondary = grey600;
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color statusDraft = grey400;
  static const Color statusProcessing = trustBlue;
  static const Color statusPending = warningAmber;
  static const Color statusPublished = successGreen;
}
