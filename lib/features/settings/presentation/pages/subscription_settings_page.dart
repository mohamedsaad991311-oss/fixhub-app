// lib/features/settings/presentation/pages/subscription_settings_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../auth/data/models/tenant.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// ═══════════════════════════════════════════════════════════════
/// SubscriptionSettingsPage — إدارة الاشتراك
/// ═══════════════════════════════════════════════════════════════
///
/// - عرض الخطة الحالية + الأيام المتبقية
/// - عرض الخطط المتاحة (Free / Pro)
/// - ملاحظة: الترقية مؤقتاً عبر الأدمن (Phase 11)
///
class SubscriptionSettingsPage extends ConsumerWidget {
  const SubscriptionSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider).valueOrNull;
    final tenant = authState?.tenant;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الاشتراك'),
        centerTitle: false,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          final padding = isWide ? AppSizes.spaceLg : AppSizes.spaceMd;

          return SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSizes.maxContentWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ═══ Current Subscription ═══
                  _buildCurrentCard(
                    context,
                    scheme,
                    tenant,
                    authState?.subscriptionDaysLeft,
                    authState?.isSubscriptionExpired ?? false,
                  ),

                  const SizedBox(height: AppSizes.spaceLg),

                  // ═══ Available Plans ═══
                  _buildSectionTitle(
                    context,
                    'الخطط المتاحة',
                    Icons.workspace_premium_outlined,
                  ),
                  const SizedBox(height: AppSizes.spaceSm),
                  _buildPlansList(context, scheme),

                  const SizedBox(height: AppSizes.spaceLg),

                  // ═══ Info Note ═══
                  _buildInfoCard(context, scheme),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  CURRENT SUBSCRIPTION
  // ═══════════════════════════════════════════════════════════════

  Widget _buildCurrentCard(
    BuildContext context,
    ColorScheme scheme,
    Tenant? tenant,
    int? daysLeft,
    bool isExpired,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // تحديد الحالة
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (tenant == null) {
      statusColor = scheme.outline;
      statusText = 'غير محدد';
      statusIcon = Icons.help_outline;
    } else if (isExpired) {
      statusColor = const Color(0xFFEF4444);
      statusText = 'منتهي';
      statusIcon = Icons.error_outline;
    } else if (daysLeft != null && daysLeft <= 7) {
      statusColor = const Color(0xFFF59E0B);
      statusText = 'قريب الانتهاء';
      statusIcon = Icons.warning_amber_rounded;
    } else {
      statusColor = const Color(0xFF10B981);
      statusText = 'نشط';
      statusIcon = Icons.check_circle_outline;
    }

    // progress bar (تقريبي — 365 يوم)
    double progress = 0.0;
    if (daysLeft != null) {
      progress = (daysLeft / 365).clamp(0.0, 1.0);
    }

    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            statusColor.withValues(alpha: isDark ? 0.25 : 0.12),
            scheme.primaryContainer.withValues(
              alpha: isDark ? 0.15 : 0.08,
            ),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.35),
          width: AppSizes.borderMedium,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ──── Header ────
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: AppSizes.spaceSmMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الخطة الحالية',
                      style: TextStyle(
                        fontSize: 11,
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _planLabel(tenant?.subscriptionPlan),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              // ──── Badge ────
              Container(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSizes.spaceSm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.spaceMd),

          // ──── Expiry ────
          Container(
            padding: const EdgeInsets.all(AppSizes.spaceSmMd),
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSizes.spaceXs),
                    Text(
                      'تاريخ الانتهاء',
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatDate(tenant?.subscriptionExpiresAt),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                  ],
                ),
                if (daysLeft != null) ...[
                  const SizedBox(height: AppSizes.spaceSm),
                  Row(
                    children: [
                      Icon(
                        Icons.hourglass_bottom,
                        size: 14,
                        color: statusColor,
                      ),
                      const SizedBox(width: AppSizes.spaceXs),
                      Text(
                        isExpired ? 'انتهى الاشتراك' : 'متبقي $daysLeft يوم',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spaceSm),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor:
                          scheme.outlineVariant.withValues(alpha: 0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  PLANS LIST
  // ═══════════════════════════════════════════════════════════════

  Widget _buildPlansList(BuildContext context, ColorScheme scheme) {
    return Column(
      children: [
        _buildPlanCard(
          context,
          scheme,
          title: 'مجانية',
          price: '0',
          period: 'دائماً',
          description: 'للتجربة والاستخدام المحدود',
          features: const [
            'فني واحد',
            'حتى 50 إيصال شهرياً',
            'بدون نسخ سحابي',
          ],
          color: scheme.outline,
          icon: Icons.person_outline,
        ),
        const SizedBox(height: AppSizes.spaceSmMd),
        _buildPlanCard(
          context,
          scheme,
          title: 'احترافية',
          price: '100',
          period: 'جنيه / سنة / فني',
          description: 'لكل الورش الكبيرة والصغيرة',
          features: const [
            'فنيين غير محدودين',
            'إيصالات غير محدودة',
            'نسخ سحابي تلقائي',
            'تقارير متقدمة',
            'دعم فني',
          ],
          color: const Color(0xFF10B981),
          icon: Icons.workspace_premium,
          isRecommended: true,
        ),
      ],
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    ColorScheme scheme, {
    required String title,
    required String price,
    required String period,
    required String description,
    required List<String> features,
    required Color color,
    required IconData icon,
    bool isRecommended = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceMd),
      decoration: BoxDecoration(
        color:
            isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: color.withValues(alpha: isRecommended ? 0.5 : 0.25),
          width: isRecommended ? AppSizes.borderThick : AppSizes.borderNormal,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ──── Header ────
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: AppSizes.spaceSmMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: scheme.onSurface,
                          ),
                        ),
                        if (isRecommended) ...[
                          const SizedBox(width: AppSizes.spaceSm),
                          Container(
                            padding: const EdgeInsetsDirectional.symmetric(
                              horizontal: AppSizes.spaceSm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusSm,
                              ),
                            ),
                            child: Text(
                              'موصى بها',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.spaceSmMd),

          // ──── Price ────
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: color,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: AppSizes.spaceXs),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  period,
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.spaceSmMd),

          // ──── Features ────
          ...features.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: color,
                  ),
                  const SizedBox(width: AppSizes.spaceSm),
                  Expanded(
                    child: Text(
                      f,
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSizes.spaceSmMd),

          // ──── Action Button ────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _showContactAdminDialog(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color, width: 1.5),
                minimumSize: const Size.fromHeight(
                  AppSizes.buttonHeightMd,
                ),
              ),
              child: Text(
                isRecommended ? 'ترقية للاحترافية' : 'الخطة الحالية',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  INFO CARD
  // ═══════════════════════════════════════════════════════════════

  Widget _buildInfoCard(BuildContext context, ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceSmMd),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.3),
          width: AppSizes.borderNormal,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: scheme.primary,
            size: AppSizes.iconSm,
          ),
          const SizedBox(width: AppSizes.spaceSm),
          Expanded(
            child: Text(
              'الترقية تتم حالياً عبر الأدمن. الدفع الإلكتروني قادم قريباً.',
              style: TextStyle(
                fontSize: 12,
                color: scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  HELPERS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: AppSizes.iconXs, color: scheme.primary),
        const SizedBox(width: AppSizes.spaceXs),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: scheme.primary,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  String _planLabel(dynamic plan) {
    final name = plan?.toString().split('.').last.toLowerCase();
    switch (name) {
      case 'free':
        return 'مجانية';
      case 'pro':
      case 'premium':
        return 'احترافية';
      default:
        return 'مجانية';
    }
  }

  String _formatDate(DateTime? d) {
    if (d == null) return 'غير محدد';
    return '${d.day}/${d.month}/${d.year}';
  }

  void _showContactAdminDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(
          Icons.support_agent,
          color: Color(0xFF10B981),
          size: 40,
        ),
        title: const Text('ترقية الاشتراك'),
        content: const Text(
          'للترقية إلى الخطة الاحترافية، يرجى التواصل مع الأدمن.\n\n'
          'سيتم تفعيل الاشتراك خلال 24 ساعة من الدفع.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }
}
