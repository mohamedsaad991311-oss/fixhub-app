// lib/features/onboarding/presentation/pages/splash_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/providers/onboarding_provider.dart';
import '../../../../core/router/route_names.dart';

/// ═══════════════════════════════════════════════════════════
/// SplashPage — شاشة البداية
/// ═══════════════════════════════════════════════════════════
///
/// - تعرض شعار + اسم التطبيق مع أنيميشن
/// - تنتظر ~2.5 ثانية
/// - ثم تنتقل:
///   - /onboarding لو المستخدم جديد
///   - /home       لو المستخدم شاف الـ onboarding
///
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    // ─── إعداد الأنيميشن ───
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();

    // ─── الانتقال بعد 2.5 ثانية ───
    _navigateAfterDelay();
  }

    Future<void> _navigateAfterDelay() async {
    debugPrint('🚀 Splash: بدء الانتظار 2.5 ثانية...');
    await Future.delayed(const Duration(milliseconds: 2500));

    debugPrint('🚀 Splash: mounted = $mounted');
    if (!mounted) return;

    try {
      final onboardingDone = ref.read(onboardingProvider);
      debugPrint('🚀 Splash: onboardingDone = $onboardingDone');

      final target =
          onboardingDone ? RouteNames.home : RouteNames.onboarding;
      debugPrint('🚀 Splash: navigating to $target');

      if (mounted) {
        context.go(target);
      }
    } catch (e, stack) {
      debugPrint('❌ Splash error: $e');
      debugPrint('Stack: $stack');
      if (mounted) {
        context.go(RouteNames.onboarding);
      }
    }
  }
    @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primary,
              scheme.primaryContainer,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return FadeTransition(
                  opacity: _fadeAnim,
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ─── الشعار ───
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: scheme.onPrimary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.build_circle,
                            size: 72,
                            color: scheme.onPrimary,
                          ),
                        ),

                        const SizedBox(height: AppSizes.spaceLg),

                        // ─── اسم التطبيق ───
                        Text(
                          'FixHub',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                color: scheme.onPrimary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                        ),

                        const SizedBox(height: AppSizes.spaceXs),

                        // ─── الوصف ───
                        Text(
                          'نظام إدارة ورش الصيانة',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: scheme.onPrimary.withValues(alpha: 0.85),
                              ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: AppSizes.spaceXxl),

                        // ─── مؤشر التحميل ───
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              scheme.onPrimary.withValues(alpha: 0.9),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}