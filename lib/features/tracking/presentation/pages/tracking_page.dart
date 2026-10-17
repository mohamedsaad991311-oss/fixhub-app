// lib/features/tracking/presentation/pages/tracking_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_sizes.dart';

import '../../../../core/services/settings_service.dart';
import '../../../receipts/data/models/receipt.dart';
import '../providers/tracking_provider.dart';
import '../widgets/tracking_receipt_card.dart';

/// ═══════════════════════════════════════════════════════════════
/// TrackingPage — إدارة روابط التتبع
/// ═══════════════════════════════════════════════════════════════
///
/// - عرض الإيصالات اللي عندها رابط تتبع
/// - نسخ / مشاركة / معاينة
/// - تجديد / إلغاء الرابط
///
class TrackingPage extends ConsumerStatefulWidget {
  const TrackingPage({super.key});

  @override
  ConsumerState<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends ConsumerState<TrackingPage> {
  final _searchCtrl = TextEditingController();
  String? _processingId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(trackingProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════
  //  نسخ الرابط
  // ═══════════════════════════════════════════════════════════════

  Future<void> _copyLink(Receipt receipt) async {
    final token = receipt.trackingToken;
    if (token == null || token.isEmpty) return;

    final link = 'https://fixhub.app/track/$token';
    await Clipboard.setData(ClipboardData(text: link));

    if (!mounted) return;
    _showSnack('تم نسخ الرابط', isError: false);
  }

  // ═══════════════════════════════════════════════════════════════
  //  إرسال واتساب
  // ═══════════════════════════════════════════════════════════════

  Future<void> _sendWhatsapp(Receipt receipt) async {
    final token = receipt.trackingToken;
    if (token == null || token.isEmpty) return;

    // 1) جلب رقم واتساب الورشة من الإعدادات
    final settingsService = ref.read(settingsServiceProvider);
    final settings = await settingsService.getSettings();

    final shopWhatsapp = settings.shopWhatsapp;
    if (shopWhatsapp == null || shopWhatsapp.isEmpty) {
      if (!mounted) return;
      _showSnack(
        'لم يتم تعيين رقم واتساب في الإعدادات',
        isError: true,
      );
      return;
    }

    // 2) رقم العميل (نستخدمه كـ destination)
    final customerPhone = receipt.customerPhone;
    if (customerPhone == null || customerPhone.isEmpty) {
      if (!mounted) return;
      _showSnack('لا يوجد رقم للعميل', isError: true);
      return;
    }

    // 3) بناء رسالة الترحيب من القالب
    final trackingUrl = 'https://fixhub.app/track/$token';
    final deviceName = [
      receipt.deviceBrand,
      receipt.deviceModel,
    ].where((e) => e != null && e.isNotEmpty).join(' ');

    final message = settings.buildWelcomeMessage(
      customerName: receipt.customerName,
      deviceName: deviceName.isEmpty ? 'الجهاز' : deviceName,
      receiptNumber: receipt.receiptNumber,
      trackingUrl: trackingUrl,
    );

    // 4) فتح واتساب
    final phone = customerPhone.replaceAll(RegExp(r'\D'), '');
    final uri =
        Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}');

    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        _showSnack('تعذّر فتح واتساب', isError: true);
      }
    } catch (e) {
      if (mounted) {
        _showSnack('تعذّر فتح واتساب', isError: true);
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  تجديد الرابط
  // ═══════════════════════════════════════════════════════════════

  Future<void> _regenerate(Receipt receipt) async {
    final confirmed = await _confirmDialog(
      title: 'تجديد الرابط',
      message: 'سيتم إنشاء رابط تتبع جديد. الرابط القديم سيتوقف عن العمل.',
      confirmText: 'تجديد',
      isDestructive: false,
    );
    if (confirmed != true) return;

    setState(() => _processingId = receipt.id);

    final newToken =
        await ref.read(trackingProvider.notifier).regenerateToken(receipt.id);

    if (!mounted) return;
    setState(() => _processingId = null);

    _showSnack(
      newToken != null ? 'تم تجديد الرابط' : 'فشل التجديد',
      isError: newToken == null,
    );
    ref.read(trackingProvider.notifier).clearMessages();
  }

  // ═══════════════════════════════════════════════════════════════
  //  إلغاء الرابط
  // ═══════════════════════════════════════════════════════════════

  Future<void> _revoke(Receipt receipt) async {
    final confirmed = await _confirmDialog(
      title: 'إلغاء الرابط',
      message:
          'هل تريد إلغاء رابط التتبع؟\n\nلن يستطيع العميل متابعة الإيصال بعد الآن.',
      confirmText: 'إلغاء الرابط',
      isDestructive: true,
    );
    if (confirmed != true) return;

    setState(() => _processingId = receipt.id);

    final ok =
        await ref.read(trackingProvider.notifier).revokeToken(receipt.id);

    if (!mounted) return;
    setState(() => _processingId = null);

    _showSnack(
      ok ? 'تم إلغاء الرابط' : 'فشل الإلغاء',
      isError: !ok,
    );
    ref.read(trackingProvider.notifier).clearMessages();
  }

  // ═══════════════════════════════════════════════════════════════
  //  معاينة صفحة العميل
  // ═══════════════════════════════════════════════════════════════

  Future<void> _preview(Receipt receipt) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXxl),
        ),
      ),
      builder: (ctx) => _PreviewSheet(receipt: receipt),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  بناء الصفحة
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(trackingProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('روابط التتبع'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
            onPressed: state.isLoading
                ? null
                : () => ref.read(trackingProvider.notifier).refresh(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(trackingProvider.notifier).refresh(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            final padding = isWide ? AppSizes.spaceLg : AppSizes.spaceMd;

            if (state.isLoading && state.receipts.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(padding),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSizes.maxContentWidth,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ─── إحصائيات ───
                    _buildStatsCard(context, state, scheme),
                    const SizedBox(height: AppSizes.spaceMd),

                    // ─── البحث ───
                    _buildSearchBar(state, scheme),
                    const SizedBox(height: AppSizes.spaceMd),

                    // ─── القائمة ───
                    if (state.filteredReceipts.isEmpty)
                      _buildEmptyState(context, scheme, state)
                    else
                      ...state.filteredReceipts.map(
                        (receipt) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSizes.spaceSmMd,
                          ),
                          child: TrackingReceiptCard(
                            receipt: receipt,
                            isBusy: _processingId == receipt.id,
                            onCopyLink: () => _copyLink(receipt),
                            onWhatsapp: () => _sendWhatsapp(receipt),
                            onPreview: () => _preview(receipt),
                            onRegenerate: () => _regenerate(receipt),
                            onRevoke: () => _revoke(receipt),
                          ),
                        ),
                      ),

                    const SizedBox(height: AppSizes.spaceXl),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  إحصائيات
  // ═══════════════════════════════════════════════════════════════

  Widget _buildStatsCard(
    BuildContext context,
    TrackingState state,
    ColorScheme scheme,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = state.receipts.length;

    // عدد الإيصالات النشطة (ليها رابط تتبع)
    final active = state.receipts.where((r) {
      return r.status != ReceiptStatus.delivered &&
          r.status != ReceiptStatus.rejected;
    }).length;

    // عدد المسلّمة
    final delivered =
        state.receipts.where((r) => r.status == ReceiptStatus.delivered).length;

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
      child: Row(
        children: [
          Expanded(
            child: _statItem(
              context,
              icon: Icons.link,
              label: 'إجمالي',
              value: '$total',
              color: scheme.primary,
              scheme: scheme,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: scheme.outlineVariant.withValues(alpha: 0.4),
          ),
          Expanded(
            child: _statItem(
              context,
              icon: Icons.sync_alt,
              label: 'نشطة',
              value: '$active',
              color: const Color(0xFFF59E0B),
              scheme: scheme,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: scheme.outlineVariant.withValues(alpha: 0.4),
          ),
          Expanded(
            child: _statItem(
              context,
              icon: Icons.check_circle_outline,
              label: 'مسلّمة',
              value: '$delivered',
              color: const Color(0xFF10B981),
              scheme: scheme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required ColorScheme scheme,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: AppSizes.iconSm),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  البحث
  // ═══════════════════════════════════════════════════════════════

  Widget _buildSearchBar(TrackingState state, ColorScheme scheme) {
    return TextField(
      controller: _searchCtrl,
      onChanged: (v) => ref.read(trackingProvider.notifier).setSearchQuery(v),
      decoration: InputDecoration(
        hintText: 'بحث بالاسم / التليفون / IMEI / رقم الإيصال',
        hintStyle: TextStyle(
          fontSize: 13,
          color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        prefixIcon: Icon(
          Icons.search,
          color: scheme.onSurfaceVariant,
          size: AppSizes.iconSm,
        ),
        suffixIcon: state.searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () {
                  _searchCtrl.clear();
                  ref.read(trackingProvider.notifier).clearSearch();
                },
              )
            : null,
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: BorderSide(
            color: scheme.primary,
            width: AppSizes.borderMedium,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spaceSmMd,
          vertical: AppSizes.spaceSm,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  حالة فارغة
  // ═══════════════════════════════════════════════════════════════

  Widget _buildEmptyState(
    BuildContext context,
    ColorScheme scheme,
    TrackingState state,
  ) {
    final hasSearch = state.searchQuery.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.spaceXl,
        horizontal: AppSizes.spaceMd,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.4),
          width: AppSizes.borderNormal,
        ),
      ),
      child: Column(
        children: [
          Icon(
            hasSearch ? Icons.search_off : Icons.link,
            size: AppSizes.iconHuge,
            color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSizes.spaceSm),
          Text(
            hasSearch ? 'لا توجد نتائج' : 'لا توجد روابط تتبع',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hasSearch
                ? 'جرّب كلمة بحث مختلفة'
                : 'ستظهر هنا الإيصالات التي عندها رابط تتبع',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  مساعدات
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
}

// ═══════════════════════════════════════════════════════════════
//  Bottom Sheet: معاينة صفحة العميل
// ═══════════════════════════════════════════════════════════════

class _PreviewSheet extends StatelessWidget {
  const _PreviewSheet({required this.receipt});

  final Receipt receipt;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceLg),
      decoration: BoxDecoration(
        color: isDark ? scheme.surfaceContainerHigh : scheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXxl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // المقبض
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spaceMd),

              // العنوان
              Row(
                children: [
                  Icon(
                    Icons.visibility_outlined,
                    size: AppSizes.iconSm,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: AppSizes.spaceXs),
                  Text(
                    'معاينة صفحة العميل',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.spaceMd),

              // وصف
              Container(
                padding: const EdgeInsets.all(AppSizes.spaceSm),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Text(
                  'هذه هي المعلومات التي سيراها العميل عند فتح رابط التتبع. '
                  'الصفحة الفعلية على الويب ستكون في Phase 10.',
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurface,
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.spaceMd),

              // معاينة الكارت
              _buildPreviewCard(context, scheme),

              const SizedBox(height: AppSizes.spaceMd),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCard(BuildContext context, ColorScheme scheme) {
    final statusColor = _statusColor(receipt.status);

    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceMd),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.35),
          width: AppSizes.borderMedium,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الورشة + الحالة
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
                  Icons.receipt_long,
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
                      receipt.receiptNumber,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'الجهاز: ${[
                        receipt.deviceBrand,
                        receipt.deviceModel,
                      ].where((e) => e != null && e.isNotEmpty).join(' ')}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.spaceMd),

          // الخط الزمني للحالات
          _buildStatusTimeline(context, scheme),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline(
    BuildContext context,
    ColorScheme scheme,
  ) {
    // الحالات بالترتيب
    const stages = [
      ReceiptStatus.received,
      ReceiptStatus.inProgress,
      ReceiptStatus.waitingParts,
      ReceiptStatus.ready,
      ReceiptStatus.delivered,
    ];

    final currentIndex = stages.indexOf(receipt.status);

    return Column(
      children: stages.asMap().entries.map((entry) {
        final index = entry.key;
        final stage = entry.value;

        final isDone = currentIndex >= index;
        final isCurrent = currentIndex == index;
        final isLast = index == stages.length - 1;

        final color = isDone
            ? const Color(0xFF10B981)
            : scheme.onSurfaceVariant.withValues(alpha: 0.4);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العمود: أيقونة + خط
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isDone
                        ? color.withValues(alpha: 0.15)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2),
                  ),
                  child: isDone
                      ? Icon(
                          Icons.check,
                          size: 14,
                          color: color,
                        )
                      : null,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 32,
                    color: color.withValues(alpha: 0.4),
                  ),
              ],
            ),
            const SizedBox(width: AppSizes.spaceSmMd),
            // النص
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(top: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stage.labelAr,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isCurrent ? FontWeight.w800 : FontWeight.w600,
                        color:
                            isDone ? scheme.onSurface : scheme.onSurfaceVariant,
                      ),
                    ),
                    if (isCurrent) ...[
                      const SizedBox(height: 2),
                      Text(
                        'الحالة الحالية',
                        style: TextStyle(
                          fontSize: 10,
                          color: color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Color _statusColor(ReceiptStatus status) {
    switch (status) {
      case ReceiptStatus.received:
        return const Color(0xFF3B82F6);
      case ReceiptStatus.inProgress:
        return const Color(0xFFF59E0B);
      case ReceiptStatus.waitingParts:
        return const Color(0xFF8B5CF6);
      case ReceiptStatus.ready:
        return const Color(0xFF10B981);
      case ReceiptStatus.delivered:
        return const Color(0xFF059669);
      case ReceiptStatus.rejected:
        return const Color(0xFFEF4444);
    }
  }
}
