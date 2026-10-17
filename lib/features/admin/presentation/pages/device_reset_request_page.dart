// lib/features/admin/presentation/pages/device_reset_request_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/services/admin_service.dart';

import '../../../../core/services/device_info_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// ═══════════════════════════════════════════════════════════════
/// DeviceResetRequestPage — صفحة طلب إعادة تعيين الجهاز (للعميل)
/// ═══════════════════════════════════════════════════════════════
///
/// - عرض حالة الطلب الحالي (لو موجود)
/// - نموذج إنشاء طلب جديد (لو مفيش طلب معلق)
/// - عرض معلومات الجهاز الحالي
///
class DeviceResetRequestPage extends ConsumerStatefulWidget {
  const DeviceResetRequestPage({super.key});

  @override
  ConsumerState<DeviceResetRequestPage> createState() =>
      _DeviceResetRequestPageState();
}

class _DeviceResetRequestPageState
    extends ConsumerState<DeviceResetRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _deviceNameCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();

  bool _isLoading = true;
  bool _isSubmitting = false;
  DeviceResetRequest? _currentRequest;
  DeviceInfo? _currentDevice;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _deviceNameCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════
  //  تحميل
  // ═══════════════════════════════════════════════════════════════

  Future<void> _load() async {
    setState(() => _isLoading = true);

    try {
      final adminService = ref.read(adminServiceProvider);
      final deviceService = ref.read(deviceInfoServiceProvider);

      final request = await adminService.getMyPendingRequest();
      final device = await deviceService.getInfo();

      if (!mounted) return;
      setState(() {
        _currentRequest = request;
        _currentDevice = device;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  إرسال الطلب
  // ═══════════════════════════════════════════════════════════════

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = ref.read(authProvider).valueOrNull;
    final tenantId = authState?.tenant?.id;

    if (tenantId == null) {
      _showSnack('لا يمكن تحديد الورشة', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    final adminService = ref.read(adminServiceProvider);
    final ok = await adminService.createDeviceResetRequest(
      tenantId: tenantId,
      currentDeviceId: _currentDevice?.deviceId ?? 'unknown',
      requestedDeviceName: _deviceNameCtrl.text.trim(),
      requestedPlatform: _currentDevice?.platform,
      reason: _reasonCtrl.text.trim().isEmpty ? null : _reasonCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (ok) {
      _showSnack('تم إرسال الطلب بنجاح', isError: false);
      _deviceNameCtrl.clear();
      _reasonCtrl.clear();
      await _load();
    } else {
      _showSnack('فشل إرسال الطلب. حاول مرة أخرى.', isError: true);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  مساعدات
  // ═══════════════════════════════════════════════════════════════

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
  //  بناء الصفحة
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعادة تعيين الجهاز'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
            onPressed: _isLoading ? null : _load,
          ),
        ],
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
                        // ─── معلومات الجهاز الحالي ───
                        _buildCurrentDeviceCard(context),
                        const SizedBox(height: AppSizes.spaceLg),

                        // ─── المحتوى حسب الحالة ───
                        if (_currentRequest != null)
                          _buildRequestStatus(context)
                        else
                          _buildRequestForm(context),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  معلومات الجهاز الحالي
  // ═══════════════════════════════════════════════════════════════

  Widget _buildCurrentDeviceCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceSmMd),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          Row(
            children: [
              Icon(
                Icons.smartphone,
                size: AppSizes.iconXs,
                color: scheme.primary,
              ),
              const SizedBox(width: AppSizes.spaceXs),
              Text(
                'الجهاز الحالي',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: scheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceSmMd),

          // التفاصيل
          _infoRow(
            context,
            icon: Icons.devices_outlined,
            label: 'الموديل',
            value: _currentDevice?.deviceModel ?? 'غير معروف',
            scheme: scheme,
          ),
          const SizedBox(height: AppSizes.spaceSm),
          _infoRow(
            context,
            icon: Icons.tablet_android_outlined,
            label: 'المنصة',
            value: _currentDevice?.platform ?? 'غير معروفة',
            scheme: scheme,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  حالة الطلب الحالي
  // ═══════════════════════════════════════════════════════════════

  Widget _buildRequestStatus(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final request = _currentRequest!;

    // لون وأيقونة حسب الحالة
    final (statusColor, statusIcon, statusTitle, statusMessage) =
        _styleForStatus(request);

    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceMd),
      decoration: BoxDecoration(
        color:
            isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.4),
          width: AppSizes.borderMedium,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── الحالة ───
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSizes.spaceSmMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusTitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      statusMessage,
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

          const SizedBox(height: AppSizes.spaceMd),

          // ─── تفاصيل الطلب ───
          Container(
            padding: const EdgeInsets.all(AppSizes.spaceSm),
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Column(
              children: [
                _infoRow(
                  context,
                  icon: Icons.access_time,
                  label: 'تاريخ الطلب',
                  value: _formatDateTime(request.requestedAt),
                  scheme: scheme,
                ),
                if (request.requestedDeviceName != null &&
                    request.requestedDeviceName!.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.spaceSm),
                  _infoRow(
                    context,
                    icon: Icons.phone_android_outlined,
                    label: 'الجهاز الجديد',
                    value: request.requestedDeviceName!,
                    scheme: scheme,
                  ),
                ],
                if (request.reason != null && request.reason!.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.spaceSm),
                  _infoRow(
                    context,
                    icon: Icons.notes,
                    label: 'السبب',
                    value: request.reason!,
                    scheme: scheme,
                  ),
                ],
                if (request.adminNotes != null &&
                    request.adminNotes!.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.spaceSm),
                  _infoRow(
                    context,
                    icon: Icons.admin_panel_settings_outlined,
                    label: 'ملاحظات الأدمن',
                    value: request.adminNotes!,
                    scheme: scheme,
                  ),
                ],
              ],
            ),
          ),

          // ─── إجراءات إضافية ───
          if (request.isRejected) ...[
            const SizedBox(height: AppSizes.spaceMd),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _resetAndShowForm,
                icon: const Icon(Icons.refresh),
                label: const Text('إرسال طلب جديد'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(
                    AppSizes.buttonHeightMd,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// إعادة تعيين النموذج لعرضه من جديد
  void _resetAndShowForm() {
    setState(() => _currentRequest = null);
  }

  // ═══════════════════════════════════════════════════════════════
  //  نموذج الطلب
  // ═══════════════════════════════════════════════════════════════

  Widget _buildRequestForm(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceMd),
      decoration: BoxDecoration(
        color:
            isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.4),
          width: AppSizes.borderNormal,
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── العنوان ───
            Row(
              children: [
                Icon(
                  Icons.help_outline,
                  size: AppSizes.iconSm,
                  color: scheme.primary,
                ),
                const SizedBox(width: AppSizes.spaceXs),
                Expanded(
                  child: Text(
                    'اطلب إعادة تعيين الجهاز',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spaceSm),

            // ─── التوضيح ───
            Container(
              padding: const EdgeInsets.all(AppSizes.spaceSm),
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Text(
                'حسابك مرتبط بجهاز واحد فقط. لاستخدام التطبيق على جهاز جديد، أرسل طلباً وسيوافق عليه الأدمن.',
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurface,
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: AppSizes.spaceMd),

            // ─── اسم الجهاز الجديد ───
            TextFormField(
              controller: _deviceNameCtrl,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'اسم الجهاز الجديد',
                hintText: 'مثال: Samsung Galaxy S24',
                prefixIcon: const Icon(Icons.phone_android_outlined),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'اكتب اسم الجهاز الجديد';
                }
                return null;
              },
            ),

            const SizedBox(height: AppSizes.spaceSmMd),

            // ─── السبب (اختياري) ───
            TextFormField(
              controller: _reasonCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'السبب (اختياري)',
                hintText: 'مثال: اشتريت موبايل جديد',
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.notes),
                ),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
            ),

            const SizedBox(height: AppSizes.spaceMd),

            // ─── زر الإرسال ───
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Icon(Icons.send_outlined),
                label: Text(_isSubmitting ? 'جارٍ الإرسال...' : 'إرسال الطلب'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(AppSizes.buttonHeightLg),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  مساعدات
  // ═══════════════════════════════════════════════════════════════

  /// نمط الحالة (لون + أيقونة + عنوان + رسالة)
  (Color, IconData, String, String) _styleForStatus(
    DeviceResetRequest request,
  ) {
    if (request.isPending) {
      return (
        const Color(0xFFF59E0B),
        Icons.hourglass_top,
        'قيد المراجعة',
        'طلبك وصل، سيتم مراجعته من قبل الأدمن قريباً',
      );
    }
    if (request.isApproved) {
      return (
        const Color(0xFF10B981),
        Icons.check_circle_outline,
        'تمت الموافقة',
        'يمكنك الآن تسجيل الدخول من جهازك الجديد',
      );
    }
    return (
      const Color(0xFFEF4444),
      Icons.cancel_outlined,
      'تم الرفض',
      'تم رفض طلبك. يمكنك إرسال طلب جديد',
    );
  }

  Widget _infoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme scheme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: scheme.onSurfaceVariant),
        const SizedBox(width: AppSizes.spaceXs),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 12,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: AppSizes.spaceXs),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime d) {
    return '${d.day}/${d.month}/${d.year} - '
        '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }
}
