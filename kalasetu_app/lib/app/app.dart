import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalasetu_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kalasetu_app/app/routes/app_router.dart';
import 'package:kalasetu_app/app/theme/app_theme.dart';
import 'package:kalasetu_app/features/providers.dart';

class KalaSetuApp extends ConsumerWidget {
  const KalaSetuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'KalaSetu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // Default
        Locale('hi'), // Hindi
        Locale('te'), // Telugu
        Locale('ta'), // Tamil
        Locale('kn'), // Kannada
        Locale('mr'), // Marathi
        Locale('bn'), // Bengali
      ],
      routerConfig: router,
    );
  }
}
