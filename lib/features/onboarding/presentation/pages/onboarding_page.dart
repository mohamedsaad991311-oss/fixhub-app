// lib/features/onboarding/presentation/pages/onboarding_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/providers/onboarding_provider.dart';
import '../../../../core/router/route_names.dart';

/// ═══════════════════════════════════════════════════════════
/// OnboardingPage — شاشات الترحيب (3 شاشات)
/// ═══════════════════════════════════════════════════════════
///
/// - PageView مع 3 شاشات
/// - Dots indicator
/// - أزرار Next / Skip
/// - زر "ابدأ" في آخر شاشة
/// - قابل للـ Scroll (عشان الشاشات القصيرة)
///
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  /// ─── قائمة الشاشات ───
  static const List<_OnboardingItem> _items = [
    _OnboardingItem(
      icon: Icons.build_circle_outlined,
      title: 'مرحباً بك في FixHub',
      description: 'نظام متكامل لإدارة ورش صيانة الموبايل.\n'
          'نظّم شغلك، تابع عملاءك، وطوّر ورشتك.',
    ),
    _OnboardingItem(
      icon: Icons.receipt_long_outlined,
      title: 'إيصالات ومخزون',
      description: 'أنشئ إيصالات استلام بسهولة،\n'
          'وتابع المخزون والقطع في مكان واحد.',
    ),
    _OnboardingItem(
      icon: Icons.insights_outlined,
      title: 'تقارير وتتبع',
      description: 'تقارير مفصّلة عن الإيرادات والمصروفات،\n'
          'مع تتبع مباشر لحالة كل جهاز.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════
  // عند الضغط على "التالي"
  // ═══════════════════════════════════════════════════════════

  void _onNext() {
    if (_currentPage < _items.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _onFinish();
    }
  }

  // ═══════════════════════════════════════════════════════════
  // عند الضغط على "تخطي" أو "ابدأ"
  // ═══════════════════════════════════════════════════════════

  Future<void> _onFinish() async {
    await ref.read(onboardingProvider.notifier).complete();
    if (mounted) {
      context.go(RouteNames.home);
    }
  }

  void _onSkip() {
    _onFinish();
  }

  // ═══════════════════════════════════════════════════════════
  // البناء
  // ═══════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isLast = _currentPage == _items.length - 1;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header: Skip ───
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spaceMd,
                vertical: AppSizes.spaceSm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!isLast)
                    TextButton(
                      onPressed: _onSkip,
                      child: const Text('تخطي'),
                    )
                  else
                    const SizedBox(height: 48),
                ],
              ),
            ),

            // ─── المحتوى (PageView) ───
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _items.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return _OnboardingSlide(item: _items[index]);
                },
              ),
            ),

            // ─── Dots Indicator ───
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSizes.spaceMd,
              ),
              child: _DotsIndicator(
                total: _items.length,
                current: _currentPage,
              ),
            ),

            // ─── زر Next / Start ───
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spaceLg,
                vertical: AppSizes.spaceMd,
              ),
              child: SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeightLg,
                child: FilledButton.icon(
                  onPressed: _onNext,
                  icon: Icon(
                    isLast ? Icons.check_circle : Icons.arrow_forward,
                  ),
                  label: Text(
                    isLast ? 'ابدأ الآن' : 'التالي',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// Onboarding Item Model
// ═══════════════════════════════════════════════════════════

class _OnboardingItem {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

// ═══════════════════════════════════════════════════════════
// Onboarding Slide Widget (قابل للـ Scroll)
// ═══════════════════════════════════════════════════════════

class _OnboardingSlide extends StatelessWidget {
  final _OnboardingItem item;

  const _OnboardingSlide({required this.item});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spaceLg,
        vertical: AppSizes.spaceMd,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.sizeOf(context).height * 0.5,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ─── الأيقونة (حجم أصغر) ───
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.icon,
                size: 65,
                color: scheme.primary,
              ),
            ),

            const SizedBox(height: AppSizes.spaceLg),

            // ─── العنوان ───
            Text(
              item.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSizes.spaceSmMd),

            // ─── الوصف ───
            Text(
              item.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.6,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// Dots Indicator
// ═══════════════════════════════════════════════════════════

class _DotsIndicator extends StatelessWidget {
  final int total;
  final int current;

  const _DotsIndicator({
    required this.total,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (index) {
        final isActive = index == current;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: isActive ? 24 : 8,
          decoration: BoxDecoration(
            color: isActive
                ? scheme.primary
                : scheme.onSurfaceVariant.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
