// lib/features/tracking/presentation/pages/tracking_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/services/receipt_service.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../receipts/data/models/receipt.dart';

/// ═══════════════════════════════════════════════════════════════
/// TrackingDetailPage — معاينة صفحة تتبع العميل
/// ═══════════════════════════════════════════════════════════════
///
/// - يجلب الإيصال بواسطة tracking_token
/// - يعرض: الخط الزمني + الجهاز + المبالغ + التواريخ
/// - نفس التصميم الذي سيظهر على الويب (Phase 10)
///
class TrackingDetailPage extends ConsumerStatefulWidget {
  const TrackingDetailPage({
    super.key,
    required this.token,
  });

  final String token;

  @override
  ConsumerState<TrackingDetailPage> createState() => _TrackingDetailPageState();
}

class _TrackingDetailPageState extends ConsumerState<TrackingDetailPage> {
  Receipt? _receipt;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final service = ref.read(receiptServiceProvider);
      final receipt = await service.getByTrackingToken(widget.token);

      if (!mounted) return;

      if (receipt == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'رابط التتبع غير صالح أو تم إلغاؤه';
        });
        return;
      }

      setState(() {
        _receipt = receipt;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'تعذّر تحميل بيانات الإيصال';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تتبع الإيصال'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
            onPressed: _isLoading ? null : _load,
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildError(context);
    }

    final receipt = _receipt;
    if (receipt == null) {
      return _buildError(context);
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          final padding = isWide ? AppSizes.spaceLg : AppSizes.spaceMd;

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
                  // ─── الهيدر (الورشة + رقم الإيصال) ───
                  _buildHeader(context, receipt),
                  const SizedBox(height: AppSizes.spaceMd),

                  // ─── الحالة الحالية ───
                  _buildCurrentStatusCard(context, receipt),
                  const SizedBox(height: AppSizes.spaceMd),

                  // ─── الخط الزمني ───
                  _buildTimeline(context, receipt),
                  const SizedBox(height: AppSizes.spaceMd),

                  // ─── معلومات الجهاز ───
                  _buildDeviceInfo(context, receipt),
                  const SizedBox(height: AppSizes.spaceMd),

                  // ─── الأعراض ───
                  if (receipt.issues.isNotEmpty) ...[
                    _buildIssuesCard(context, receipt),
                    const SizedBox(height: AppSizes.spaceMd),
                  ],

                  // ─── المبالغ ───
                  _buildAmountsCard(context, receipt),
                  const SizedBox(height: AppSizes.spaceMd),

                  // ─── التواريخ ───
                  _buildDatesCard(context, receipt),
                  const SizedBox(height: AppSizes.spaceMd),

                  // ─── الضمان (لو مسلّم) ───
                  if (receipt.status == ReceiptStatus.delivered &&
                      receipt.warrantyDays > 0) ...[
                    _buildWarrantyCard(context, receipt),
                    const SizedBox(height: AppSizes.spaceMd),
                  ],

                  const SizedBox(height: AppSizes.spaceXl),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  الهيدر
  // ═══════════════════════════════════════════════════════════════

  Widget _buildHeader(BuildContext context, Receipt receipt) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            scheme.primary.withValues(alpha: isDark ? 0.25 : 0.12),
            scheme.primaryContainer.withValues(alpha: isDark ? 0.15 : 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.3),
          width: AppSizes.borderMedium,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Icon(
                  Icons.build_circle_outlined,
                  color: scheme.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: AppSizes.spaceSmMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مرحباً ${receipt.customerName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'يمكنك متابعة حالة جهازك من هنا',
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
          Container(
            padding: const EdgeInsets.all(AppSizes.spaceSm),
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 16,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSizes.spaceXs),
                Text(
                  'رقم الإيصال:',
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: AppSizes.spaceXs),
                Expanded(
                  child: Text(
                    receipt.receiptNumber,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  الحالة الحالية
  // ═══════════════════════════════════════════════════════════════

  Widget _buildCurrentStatusCard(BuildContext context, Receipt receipt) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _statusColor(receipt.status);
    final statusIcon = _statusIcon(receipt.status);

    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceMd),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.4),
          width: AppSizes.borderThick,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 30),
          ),
          const SizedBox(width: AppSizes.spaceSmMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الحالة الحالية',
                  style: TextStyle(
                    fontSize: 11,
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  receipt.status.labelAr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  الخط الزمني
  // ═══════════════════════════════════════════════════════════════

  Widget _buildTimeline(BuildContext context, Receipt receipt) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const stages = [
      ReceiptStatus.received,
      ReceiptStatus.inProgress,
      ReceiptStatus.waitingParts,
      ReceiptStatus.ready,
      ReceiptStatus.delivered,
    ];

    final currentIndex = stages.indexOf(receipt.status);

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timeline,
                size: AppSizes.iconXs,
                color: scheme.primary,
              ),
              const SizedBox(width: AppSizes.spaceXs),
              Text(
                'مراحل الإصلاح',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: scheme.primary,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceMd),
          ...stages.asMap().entries.map((entry) {
            final index = entry.key;
            final stage = entry.value;

            final isDone = currentIndex >= index;
            final isCurrent = currentIndex == index;
            final isLast = index == stages.length - 1;

            final color = isDone
                ? const Color(0xFF10B981)
                : scheme.onSurfaceVariant.withValues(alpha: 0.3);

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // عمود: أيقونة + خط
                Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isDone
                            ? color.withValues(alpha: 0.15)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: color,
                          width: isCurrent ? 3 : 2,
                        ),
                      ),
                      child: isDone
                          ? Icon(
                              Icons.check,
                              size: 16,
                              color: color,
                            )
                          : null,
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 36,
                        color: color.withValues(alpha: 0.4),
                      ),
                  ],
                ),
                const SizedBox(width: AppSizes.spaceSmMd),
                // النص + التاريخ
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stage.labelAr,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight:
                                isCurrent ? FontWeight.w800 : FontWeight.w600,
                            color: isDone
                                ? scheme.onSurface
                                : scheme.onSurfaceVariant,
                          ),
                        ),
                        if (isCurrent) ...[
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsetsDirectional.symmetric(
                              horizontal: AppSizes.spaceSm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusSm),
                            ),
                            child: Text(
                              'الحالة الحالية',
                              style: TextStyle(
                                fontSize: 10,
                                color: color,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  معلومات الجهاز
  // ═══════════════════════════════════════════════════════════════

  Widget _buildDeviceInfo(BuildContext context, Receipt receipt) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final deviceName = [
      receipt.deviceBrand,
      receipt.deviceModel,
    ].where((e) => e != null && e.isNotEmpty).join(' ');

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.phone_android_outlined,
                size: AppSizes.iconXs,
                color: scheme.primary,
              ),
              const SizedBox(width: AppSizes.spaceXs),
              Text(
                'معلومات الجهاز',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: scheme.primary,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceSmMd),
          _infoRow(
            context,
            icon: Icons.devices_outlined,
            label: 'الجهاز',
            value: deviceName.isEmpty ? '—' : deviceName,
            scheme: scheme,
          ),
          if (receipt.deviceImei != null && receipt.deviceImei!.isNotEmpty) ...[
            const SizedBox(height: AppSizes.spaceSm),
            _infoRow(
              context,
              icon: Icons.qr_code,
              label: 'IMEI',
              value: receipt.deviceImei!,
              scheme: scheme,
            ),
          ],
          if (receipt.deviceColor != null &&
              receipt.deviceColor!.isNotEmpty) ...[
            const SizedBox(height: AppSizes.spaceSm),
            _infoRow(
              context,
              icon: Icons.palette_outlined,
              label: 'اللون',
              value: receipt.deviceColor!,
              scheme: scheme,
            ),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  الأعراض
  // ═══════════════════════════════════════════════════════════════

  Widget _buildIssuesCard(BuildContext context, Receipt receipt) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.report_problem_outlined,
                size: AppSizes.iconXs,
                color: scheme.primary,
              ),
              const SizedBox(width: AppSizes.spaceXs),
              Text(
                'الأعراض المُبلّغ عنها',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: scheme.primary,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceSmMd),
          ...receipt.issues.map(
            (issue) => Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.spaceXs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(top: 6),
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
                      issue.description ?? '—',
                      style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurface,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  المبالغ
  // ═══════════════════════════════════════════════════════════════

  Widget _buildAmountsCard(BuildContext context, Receipt receipt) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final total = receipt.finalCost > 0
        ? receipt.finalCost
        : (receipt.total > 0 ? receipt.total : receipt.estimatedCost);
    final deposit = receipt.deposit;
    final remaining = (total - deposit).clamp(0, double.infinity).toDouble();

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.payments_outlined,
                size: AppSizes.iconXs,
                color: scheme.primary,
              ),
              const SizedBox(width: AppSizes.spaceXs),
              Text(
                'المبالغ',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: scheme.primary,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceSmMd),
          _infoRow(
            context,
            icon: Icons.receipt,
            label: 'الإجمالي',
            value: CurrencyFormatter.format(total),
            scheme: scheme,
          ),
          const SizedBox(height: AppSizes.spaceSm),
          _infoRow(
            context,
            icon: Icons.savings_outlined,
            label: 'العربون',
            value: CurrencyFormatter.format(deposit),
            scheme: scheme,
            valueColor: const Color(0xFF3B82F6),
          ),
          const SizedBox(height: AppSizes.spaceSm),
          Divider(
            color: scheme.outlineVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: AppSizes.spaceSm),
          _infoRow(
            context,
            icon: Icons.account_balance_wallet_outlined,
            label: 'المتبقي',
            value: CurrencyFormatter.format(remaining),
            scheme: scheme,
            valueColor: remaining > 0
                ? const Color(0xFFEF4444)
                : const Color(0xFF10B981),
            bold: true,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  التواريخ
  // ═══════════════════════════════════════════════════════════════

  Widget _buildDatesCard(BuildContext context, Receipt receipt) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: AppSizes.iconXs,
                color: scheme.primary,
              ),
              const SizedBox(width: AppSizes.spaceXs),
              Text(
                'التواريخ',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: scheme.primary,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceSmMd),
          if (receipt.createdAt != null) ...[
            _infoRow(
              context,
              icon: Icons.login,
              label: 'الاستلام',
              value: _formatDate(receipt.createdAt!),
              scheme: scheme,
            ),
            const SizedBox(height: AppSizes.spaceSm),
          ],
          if (receipt.expectedDeliveryDate != null) ...[
            _infoRow(
              context,
              icon: Icons.schedule,
              label: 'التسليم المتوقع',
              value: _formatDate(receipt.expectedDeliveryDate!),
              scheme: scheme,
              valueColor: const Color(0xFFF59E0B),
            ),
            const SizedBox(height: AppSizes.spaceSm),
          ],
          if (receipt.deliveredAt != null)
            _infoRow(
              context,
              icon: Icons.check_circle_outline,
              label: 'تاريخ التسليم',
              value: _formatDate(receipt.deliveredAt!),
              scheme: scheme,
              valueColor: const Color(0xFF10B981),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  الضمان
  // ═══════════════════════════════════════════════════════════════

  Widget _buildWarrantyCard(BuildContext context, Receipt receipt) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final deliveredAt = receipt.deliveredAt ?? DateTime.now();
    final warrantyEnd = deliveredAt.add(Duration(days: receipt.warrantyDays));
    final remainingDays = warrantyEnd.difference(DateTime.now()).inDays;

    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceMd),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.4),
          width: AppSizes.borderThick,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: const Icon(
              Icons.verified_outlined,
              color: Color(0xFF10B981),
              size: 26,
            ),
          ),
          const SizedBox(width: AppSizes.spaceSmMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الضمان ساري',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  remainingDays > 0
                      ? 'ينتهي بعد $remainingDays يوم '
                          '(${_formatDate(warrantyEnd)})'
                      : 'انتهى الضمان بتاريخ ${_formatDate(warrantyEnd)}',
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
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  خطأ
  // ═══════════════════════════════════════════════════════════════

  Widget _buildError(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.link_off,
              size: AppSizes.iconXxl,
              color: scheme.error,
            ),
            const SizedBox(height: AppSizes.spaceMd),
            Text(
              _errorMessage ?? 'حدث خطأ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSizes.spaceSm),
            Text(
              'تأكد من صحة الرابط، أو تواصل مع الورشة',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSizes.spaceLg),
            FilledButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  مساعدات
  // ═══════════════════════════════════════════════════════════════

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

  IconData _statusIcon(ReceiptStatus status) {
    switch (status) {
      case ReceiptStatus.received:
        return Icons.inbox_outlined;
      case ReceiptStatus.inProgress:
        return Icons.build_outlined;
      case ReceiptStatus.waitingParts:
        return Icons.hourglass_top;
      case ReceiptStatus.ready:
        return Icons.check_circle_outline;
      case ReceiptStatus.delivered:
        return Icons.local_shipping_outlined;
      case ReceiptStatus.rejected:
        return Icons.cancel_outlined;
    }
  }

  Widget _infoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme scheme,
    Color? valueColor,
    bool bold = false,
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: bold ? 14 : 13,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              color: valueColor ?? scheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime d) {
    return '${d.day}/${d.month}/${d.year}';
  }
}
