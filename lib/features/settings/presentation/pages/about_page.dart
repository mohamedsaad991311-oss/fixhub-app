// lib/features/settings/presentation/pages/about_page.dart

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/constants/app_sizes.dart';

/// ═══════════════════════════════════════════════════════════════
/// AboutPage — حول التطبيق
/// ═══════════════════════════════════════════════════════════════
///
/// - شعار التطبيق
/// - الاسم + الإصدار (من package_info_plus)
/// - معلومات تقنية (Bundle ID، Dart، Flutter)
/// - روابط: سياسة الخصوصية، شروط الاستخدام، التواصل
///
class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  PackageInfo? _info;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  Future<void> _loadInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() {
        _info = info;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('حول التطبيق'),
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
                maxWidth: AppSizes.maxFormWidth * 2,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSizes.spaceLg),

                  // ═══ Logo + App Info ═══
                  _buildAppHeader(context, scheme),

                  const SizedBox(height: AppSizes.spaceXl),

                  // ═══ Info Section ═══
                  _buildSectionTitle(
                      context, 'معلومات التطبيق', Icons.info_outline),
                  const SizedBox(height: AppSizes.spaceSm),
                  _buildInfoCard(context, scheme),

                  const SizedBox(height: AppSizes.spaceLg),

                  // ═══ Links Section ═══
                  _buildSectionTitle(context, 'روابط', Icons.link_outlined),
                  const SizedBox(height: AppSizes.spaceSm),
                  _buildLinksCard(context, scheme),

                  const SizedBox(height: AppSizes.spaceXl),

                  // ═══ Footer ═══
                  _buildFooter(context, scheme),

                  const SizedBox(height: AppSizes.spaceLg),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  APP HEADER
  // ═══════════════════════════════════════════════════════════════

  Widget _buildAppHeader(BuildContext context, ColorScheme scheme) {
    final version = _info?.version ?? '1.0.0';
    final buildNumber = _info?.buildNumber ?? '1';

    return Column(
      children: [
        // ──── Logo ────
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: [
                scheme.primary,
                scheme.primary.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.build_circle_outlined,
              size: 52,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(height: AppSizes.spaceMd),

        // ──── App Name ────
        Text(
          'FixHub',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: scheme.onSurface,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'نظام إدارة ورش صيانة الموبايل',
          style: TextStyle(
            fontSize: 13,
            color: scheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: AppSizes.spaceSmMd),

        // ──── Version Badge ────
        if (!_isLoading)
          Container(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppSizes.spaceSmMd,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
              border: Border.all(
                color: scheme.primary.withValues(alpha: 0.3),
                width: AppSizes.borderNormal,
              ),
            ),
            child: Text(
              'الإصدار $version ($buildNumber)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: scheme.primary,
              ),
            ),
          )
        else
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  INFO CARD
  // ═══════════════════════════════════════════════════════════════

  Widget _buildInfoCard(BuildContext context, ColorScheme scheme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color:
            isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.4),
          width: AppSizes.borderNormal,
        ),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            context,
            icon: Icons.apps,
            label: 'اسم التطبيق',
            value: _info?.appName ?? 'FixHub',
          ),
          _divider(scheme),
          _buildInfoRow(
            context,
            icon: Icons.tag,
            label: 'Package',
            value: _info?.packageName ?? 'com.fixhub.fixhub_app',
          ),
          _divider(scheme),
          _buildInfoRow(
            context,
            icon: Icons.code,
            label: 'Flutter',
            value: '3.47.2',
          ),
          _divider(scheme),
          _buildInfoRow(
            context,
            icon: Icons.memory,
            label: 'Dart',
            value: '3.13.2',
          ),
          _divider(scheme),
          _buildInfoRow(
            context,
            icon: Icons.person_outline,
            label: 'المطور',
            value: 'ElForQan',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spaceSmMd,
        vertical: AppSizes.spaceSm,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Icon(
              icon,
              size: AppSizes.iconXs,
              color: scheme.primary,
            ),
          ),
          const SizedBox(width: AppSizes.spaceSmMd),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(ColorScheme scheme) {
    return Divider(
      height: 1,
      indent: AppSizes.spaceLg + AppSizes.spaceMd,
      color: scheme.outlineVariant.withValues(alpha: 0.3),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  LINKS CARD
  // ═══════════════════════════════════════════════════════════════

  Widget _buildLinksCard(BuildContext context, ColorScheme scheme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color:
            isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.4),
          width: AppSizes.borderNormal,
        ),
      ),
      child: Column(
        children: [
          _buildLinkRow(
            context,
            icon: Icons.privacy_tip_outlined,
            label: 'سياسة الخصوصية',
            onTap: () => _showComingSoon(context, 'سياسة الخصوصية'),
          ),
          _divider(scheme),
          _buildLinkRow(
            context,
            icon: Icons.description_outlined,
            label: 'شروط الاستخدام',
            onTap: () => _showComingSoon(context, 'شروط الاستخدام'),
          ),
          _divider(scheme),
          _buildLinkRow(
            context,
            icon: Icons.star_outline,
            label: 'قيّم التطبيق',
            onTap: () => _showComingSoon(context, 'تقييم التطبيق'),
          ),
          _divider(scheme),
          _buildLinkRow(
            context,
            icon: Icons.email_outlined,
            label: 'تواصل معنا',
            onTap: () => _showComingSoon(context, 'تواصل معنا'),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spaceSmMd,
            vertical: AppSizes.spaceSmMd,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: AppSizes.iconSm,
                color: scheme.primary,
              ),
              const SizedBox(width: AppSizes.spaceSmMd),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              Icon(
                Icons.open_in_new,
                size: AppSizes.iconXs,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  FOOTER
  // ═══════════════════════════════════════════════════════════════

  Widget _buildFooter(BuildContext context, ColorScheme scheme) {
    return Column(
      children: [
        Icon(
          Icons.favorite,
          size: 16,
          color: scheme.error.withValues(alpha: 0.7),
        ),
        const SizedBox(height: AppSizes.spaceSm),
        Text(
          'صُنع بحب في مصر 🇪🇬',
          style: TextStyle(
            fontSize: 12,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '© 2026 FixHub — جميع الحقوق محفوظة',
          style: TextStyle(
            fontSize: 11,
            color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
      ],
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

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '$feature — قريباً',
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }
}
