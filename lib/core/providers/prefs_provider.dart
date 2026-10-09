// lib/core/providers/prefs_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ═══════════════════════════════════════════════════════════
/// SharedPreferences Provider
/// ═══════════════════════════════════════════════════════════
///
/// ⚠️ مهم: لازم نعمل override في main.dart:
/// ```dart
/// final prefs = await SharedPreferences.getInstance();
/// runApp(
///   ProviderScope(
///     overrides: [
///       sharedPrefsProvider.overrideWithValue(prefs),
///     ],
///     child: FixHubApp(),
///   ),
/// );
/// ```
///
final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPrefsProvider لازم يتعمل له override في main.dart',
  );
});