// lib/features/auth/presentation/pages/reset_password_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_names.dart';
import '../widgets/auth_widgets.dart';

// ═══════════════════════════════════════════════════════════════
//  RESET PASSWORD PAGE
// ═══════════════════════════════════════════════════════════════
//
// ملاحظة: الصفحة دي بتظهر بس كإرشاد للمستخدم.
// عملية إعادة التعيين الفعلية بتتم عبر:
//   1. المستخدم يدوس على رابط في الإيميل
//   2. Supabase web يعالج الرابط
//   3. المستخدم يرجع للتطبيق ويسجل دخول
//
// في المرحلة القادمة (9) هنضيف Deep Link Handler كامل
// عشان التطبيق يستقبل التوكن مباشرة.

class ResetPasswordPage extends ConsumerWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AuthScaffold(
      showBackButton: false,
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ─── Icon ───
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.mark_email_read_outlined,
              size: 56,
              color: scheme.primary,
            ),
          ),
        ),
        const SizedBox(height: AppSizes.spaceLg),

        // ─── Title ───
        Text(
          'افتح رابط الاستعادة',
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSizes.spaceMd),

        // ─── Description ───
        Text(
          'راجع بريدك الإلكتروني، وافتح الرابط اللي وصلك لتعيين كلمة مرور جديدة.',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),

        const SizedBox(height: AppSizes.spaceXl),

        // ─── Info Card ───
        Container(
          padding: const EdgeInsets.all(AppSizes.spaceMd),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(
              color: scheme.outlineVariant,
              width: AppSizes.borderThin,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: AppSizes.iconSm,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: AppSizes.spaceSm),
                  Text(
                    'ملاحظات',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spaceSmMd),
              _TipRow(
                text: 'الرابط صالح لمدة ساعة واحدة فقط.',
                scheme: scheme,
              ),
              _TipRow(
                text: 'لو الرابط ما فتحش، جرّب تنسخه وتلصقه في المتصفح.',
                scheme: scheme,
              ),
              _TipRow(
                text: 'تأكد إنك بتفتح الرابط من نفس الجهاز.',
                scheme: scheme,
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSizes.spaceXl),

        // ─── Back to Login ───
        AuthButton(
          label: 'العودة لتسجيل الدخول',
          icon: Icons.arrow_back,
          onPressed: () => context.go(RouteNames.login),
        ),
      ],
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow({required this.text, required this.scheme});

  final String text;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spaceXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spaceSm),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurface,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
