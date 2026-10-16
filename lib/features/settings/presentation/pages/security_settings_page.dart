// lib/features/settings/presentation/pages/security_settings_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../core/services/pin_lock_service.dart';

/// ═══════════════════════════════════════════════════════════════
/// SecuritySettingsPage — إعدادات الأمان
/// ═══════════════════════════════════════════════════════════════
class SecuritySettingsPage extends ConsumerStatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  ConsumerState<SecuritySettingsPage> createState() =>
      _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends ConsumerState<SecuritySettingsPage> {
  bool _pinEnabled = false;
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    try {
      final pinService = ref.read(pinLockServiceProvider);
      final bioService = ref.read(biometricServiceProvider);

      final pinEnabled = await pinService.isEnabled();
      final bioAvailable = await bioService.isAvailable();
      final bioEnabled = bioAvailable ? await bioService.isEnabled() : false;

      if (!mounted) return;

      setState(() {
        _pinEnabled = pinEnabled;
        _biometricAvailable = bioAvailable;
        _biometricEnabled = bioEnabled;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  PIN
  // ═══════════════════════════════════════════════════════════════

  Future<void> _togglePin(bool value) async {
    if (value) {
      // لو عايز يفعّل → روح لصفحة إعداد PIN
      await context.push(RouteNames.pinLock);
      if (mounted) _loadState();
      return;
    }

    // تعطيل — تأكيد
    final confirmed = await _confirmDialog(
      title: 'تعطيل قفل PIN',
      message:
          'هل أنت متأكد؟ سيتم إلغاء قفل التطبيق بكلمة PIN وسيتم حذف الـ PIN الحالي.',
      confirmText: 'تعطيل',
      isDestructive: true,
    );

    if (confirmed != true) return;

    try {
      final service = ref.read(pinLockServiceProvider);
      final ok = await service.removePin();
      if (!mounted) return;

      if (ok) {
        setState(() => _pinEnabled = false);
        _showSnack('تم تعطيل قفل PIN', isError: false);
      } else {
        _showSnack('فشل التعطيل', isError: true);
      }
    } catch (e) {
      _showSnack('فشل التعطيل', isError: true);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  BIOMETRIC
  // ═══════════════════════════════════════════════════════════════

  Future<void> _toggleBiometric(bool value) async {
    try {
      final service = ref.read(biometricServiceProvider);

      if (value) {
        // اختبر البصمة الأول
        final result = await service.authenticate(
          reason: 'تأكيد تفعيل البصمة',
        );
        if (!result.isSuccess) {
          if (mounted) {
            _showSnack(result.messageAr, isError: true);
          }
          return;
        }
        await service.setEnabled(enabled: true);
      } else {
        await service.setEnabled(enabled: false);
      }

      if (!mounted) return;
      setState(() => _biometricEnabled = value);
      _showSnack(
        value ? 'تم تفعيل البصمة' : 'تم تعطيل البصمة',
        isError: false,
      );
    } catch (e) {
      _showSnack('فشل العملية', isError: true);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  DIALOGS & SNACKS
  // ═══════════════════════════════════════════════════════════════

  Future<bool?> _confirmDialog({
    required String title,
    required String message,
    required String confirmText,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        return AlertDialog(
          icon: Icon(
            isDestructive ? Icons.warning_amber_rounded : Icons.info_outline,
            color: isDestructive ? scheme.error : scheme.primary,
            size: 40,
          ),
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(
                backgroundColor: isDestructive ? scheme.error : scheme.primary,
              ),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
  }

  void _showSnack(String message, {required bool isError}) {
    if (!mounted) return;
    final scheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          backgroundColor: isError ? scheme.error : const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  // ═══════════════════════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الأمان والخصوصية'),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
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
                        // ──── Info ────
                        _buildInfoCard(context),
                        const SizedBox(height: AppSizes.spaceLg),

                        // ──── PIN ────
                        _buildSectionTitle(
                          context,
                          'قفل التطبيق',
                          Icons.lock_outline,
                        ),
                        const SizedBox(height: AppSizes.spaceSm),
                        _buildPinCard(context, scheme),

                        const SizedBox(height: AppSizes.spaceLg),

                        // ──── Biometric ────
                        _buildSectionTitle(
                          context,
                          'البصمة / Face ID',
                          Icons.fingerprint,
                        ),
                        const SizedBox(height: AppSizes.spaceSm),
                        _buildBiometricCard(context, scheme),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  WIDGETS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildInfoCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
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
            Icons.shield_outlined,
            color: scheme.primary,
            size: AppSizes.iconSm,
          ),
          const SizedBox(width: AppSizes.spaceSm),
          Expanded(
            child: Text(
              'حماية بياناتك بقفل PIN أو البصمة',
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

  Widget _buildPinCard(BuildContext context, ColorScheme scheme) {
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
          SwitchListTile(
            value: _pinEnabled,
            onChanged: _togglePin,
            secondary: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Icon(
                Icons.lock_outline,
                size: AppSizes.iconSm,
                color: scheme.primary,
              ),
            ),
            title: const Text(
              'تفعيل قفل PIN',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Text(
              '6 أرقام لحماية التطبيق',
              style: TextStyle(fontSize: 12),
            ),
          ),
          if (_pinEnabled) ...[
            Divider(
              height: 1,
              indent: AppSizes.spaceLg + AppSizes.spaceMd,
              color: scheme.outlineVariant.withValues(alpha: 0.3),
            ),
            ListTile(
              leading: const SizedBox(width: 40),
              title: const Text(
                'تغيير PIN',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Icon(
                Icons.chevron_left,
                color: scheme.onSurfaceVariant,
              ),
              onTap: () async {
                await context.push(RouteNames.pinLock);
                if (mounted) _loadState();
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBiometricCard(BuildContext context, ColorScheme scheme) {
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
      child: SwitchListTile(
        value: _biometricEnabled,
        onChanged: _biometricAvailable ? _toggleBiometric : null,
        secondary: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
          child: Icon(
            Icons.fingerprint,
            size: AppSizes.iconSm,
            color: scheme.primary,
          ),
        ),
        title: const Text(
          'تفعيل البصمة',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          _biometricAvailable
              ? 'فتح التطبيق ببصمة الإصبع / Face ID'
              : 'البصمة غير متاحة على هذا الجهاز',
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

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
}
