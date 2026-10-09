// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/localization/locale_provider.dart';
import 'core/providers/prefs_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/theme_provider.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  // ─── 1. تهيئة Flutter ───
  WidgetsFlutterBinding.ensureInitialized();

  // ─── 2. تهيئة Hive ───
  await Hive.initFlutter();

  // ─── 3. تهيئة SharedPreferences ───
  final prefs = await SharedPreferences.getInstance();

  // ─── 4. تهيئة التواريخ (للغة العربية) ───
  await initializeDateFormatting('ar');
  await initializeDateFormatting('en');

  // ─── 5. تشغيل التطبيق ───
  runApp(
    ProviderScope(
      overrides: [
        // override للـ SharedPreferences
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: const FixHubApp(),
    ),
  );
}

class FixHubApp extends ConsumerWidget {
  const FixHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ─── الـ Providers ───
    final locale = ref.watch(localeProvider);
    final lightTheme = ref.watch(lightThemeProvider);
    final darkTheme = ref.watch(darkThemeProvider);
    final themeMode = ref.watch(themeModeProvider);

    // ─── GoRouter (يتبني مرة واحدة) ───
    final router = AppRouter.create();

    return MaterialApp.router(
      title: 'FixHub',
      debugShowCheckedModeBanner: false,

      // ─── اللغة ───
      locale: locale,
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ─── الثيم ───
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,

      // ─── Router ───
      routerConfig: router,
    );
  }
}