// lib/features/receipts/presentation/widgets/receipt_actions_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'receipt_edit_sheet.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/services/receipt_service.dart';
import '../../data/models/receipt.dart';
import '../providers/receipt_detail_provider.dart';
import '../providers/receipts_list_provider.dart';

/// ═══════════════════════════════════════════════════════════
/// ReceiptActionsBar — شريط الأزرار السفلية في تفاصيل الإيصال
/// ═══════════════════════════════════════════════════════════
class ReceiptActionsBar extends ConsumerWidget {
  const ReceiptActionsBar({super.key, required this.receipt});

  final Receipt receipt;

  // ⚠️ رابط مؤقت — نغيّره بعد النشر (Vercel / Firebase)
  static const String _trackBaseUrl = 'https://fixhub-app.web.app/track.html';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final isUpdating = ref.watch(receiptUpdatingProvider(receipt.id));

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSizes.spaceMd,
        AppSizes.spaceSmMd,
        AppSizes.spaceMd,
        MediaQuery.of(context).padding.bottom + AppSizes.spaceSmMd,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          top: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      // نستخدم Wrap في حالة ضيق المساحة
      child: Wrap(
        spacing: AppSizes.spaceSm,
        runSpacing: AppSizes.spaceSm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // ─── التقدّم للحالة التالية ───
          if (!receipt.status.isFinal)
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.45,
              child: FilledButton.icon(
                onPressed:
                    isUpdating ? null : () => _advanceStatus(context, ref),
                icon: isUpdating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.arrow_forward, size: 18),
                label: Text(
                  _nextStatusLabel(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, AppSizes.buttonHeightLg),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  ),
                ),
              ),
            ),

          // ─── تغيير الحالة + رفض ───
          if (!receipt.status.isFinal) ...[
            SizedBox(
              width: 100,
              child: OutlinedButton.icon(
                onPressed:
                    isUpdating ? null : () => _showStatusSheet(context, ref),
                icon: const Icon(Icons.tune, size: 18),
                label: const Text(
                  'تغيير',
                  style: TextStyle(fontSize: 13),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, AppSizes.buttonHeightLg),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  ),
                ),
              ),
            ),

            // ─── زر الرفض ───
            IconButton.filledTonal(
              tooltip: 'رفض الإيصال',
              onPressed:
                  isUpdating ? null : () => _confirmReject(context, ref),
              icon: const Icon(Icons.cancel_outlined, size: 20),
              style: IconButton.styleFrom(
                minimumSize: const Size(52, 52),
                backgroundColor:
                    const Color(0xFFEF4444).withValues(alpha: 0.15),
                foregroundColor: const Color(0xFFEF4444),
              ),
            ),
          ],

          // ─── زر التعديل ───
          IconButton.filledTonal(
            tooltip: 'تعديل الإيصال',
            onPressed: isUpdating ? null : () => _editReceipt(context),
            icon: const Icon(Icons.edit_outlined, size: 20),
            style: IconButton.styleFrom(
              minimumSize: const Size(52, 52),
              backgroundColor: scheme.tertiary.withValues(alpha: 0.15),
              foregroundColor: scheme.tertiary,
            ),
          ),

          // ─── زر الحذف ───
          IconButton.filledTonal(
            tooltip: 'حذف الإيصال',
            onPressed: isUpdating ? null : () => _confirmDelete(context, ref),
            icon: const Icon(Icons.delete_outline, size: 20),
            style: IconButton.styleFrom(
              minimumSize: const Size(52, 52),
              backgroundColor: scheme.error.withValues(alpha: 0.15),
              foregroundColor: scheme.error,
            ),
          ),

          // ─── زر المشاركة ───
          IconButton.filledTonal(
            tooltip: 'مشاركة رابط التتبع',
            onPressed: () => _shareTracking(context),
            icon: const Icon(Icons.share_outlined, size: 20),
            style: IconButton.styleFrom(
              minimumSize: const Size(52, 52),
              backgroundColor: scheme.primary.withValues(alpha: 0.15),
              foregroundColor: scheme.primary,
            ),
          ),

          // ─── نسخ الرابط (لو فيه رقم تليفون) ───
          if (receipt.customerPhone != null &&
              receipt.customerPhone!.isNotEmpty)
            IconButton.filledTonal(
              tooltip: 'نسخ الرابط',
              onPressed: () => _copyTracking(context),
              icon: const Icon(Icons.link, size: 20),
              style: IconButton.styleFrom(
                minimumSize: const Size(52, 52),
              ),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  Helpers
  // ═══════════════════════════════════════════════════════════

  String _nextStatusLabel() {
    final next = receipt.status.next;
    if (next == null) return 'التالي';
    return next.labelAr;
  }

  /// بناء رابط التتبع (برقم الإيصال، أو رقم التليفون)
  String? _buildTrackUrl() {
    if (receipt.receiptNumber.isNotEmpty) {
      return '$_trackBaseUrl?receipt=${receipt.receiptNumber}';
    }
    if (receipt.customerPhone != null && receipt.customerPhone!.isNotEmpty) {
      return '$_trackBaseUrl?phone=${receipt.customerPhone}';
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════════
  //  Actions
  // ═══════════════════════════════════════════════════════════

  Future<void> _advanceStatus(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(receiptDetailProvider(receipt.id).notifier);
    final ok = await notifier.advanceStatus();

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'تم تحديث الحالة' : 'فشل تحديث الحالة'),
        backgroundColor:
            ok ? const Color(0xFF10B981) : Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _showStatusSheet(BuildContext context, WidgetRef ref) async {
    final selected = await showModalBottomSheet<ReceiptStatus>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => _StatusPickerSheet(current: receipt.status),
    );

    if (selected == null || selected == receipt.status) return;
    if (!context.mounted) return;

    final notifier = ref.read(receiptDetailProvider(receipt.id).notifier);
    final ok = await notifier.changeStatus(newStatus: selected);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'تم تحديث الحالة' : 'فشل تحديث الحالة'),
        backgroundColor:
            ok ? const Color(0xFF10B981) : Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _confirmReject(BuildContext context, WidgetRef ref) async {
    final scheme = Theme.of(context).colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.cancel_outlined, color: scheme.error, size: 22),
            const SizedBox(width: 8),
            const Text('رفض الإيصال؟'),
          ],
        ),
        content: const Text(
          'هل أنت متأكد من رفض هذا الإيصال؟ '
          'لا يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: scheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('رفض'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    final notifier = ref.read(receiptDetailProvider(receipt.id).notifier);
    final ok = await notifier.changeStatus(
      newStatus: ReceiptStatus.rejected,
      note: 'تم رفض الإيصال من الفني',
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'تم رفض الإيصال' : 'فشل الرفض'),
        backgroundColor: ok ? scheme.error : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// زر التعديل — بيعرض رسالة مؤقتة لحد ما نعمل شاشة التعديل
    /// زر التعديل — بيفتح Bottom Sheet للتعديل
  Future<void> _editReceipt(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ReceiptEditSheet(receipt: receipt),
    );
  }
  /// زر الحذف — بيطلب تأكيد وبعدها soft delete
  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final scheme = Theme.of(context).colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.delete_outline, color: scheme.error, size: 22),
            const SizedBox(width: 8),
            const Text('حذف الإيصال؟'),
          ],
        ),
        content: Text(
          'سيتم حذف الإيصال رقم "${receipt.receiptNumber}" من القائمة.\n'
          'السجل سيبقى محفوظاً في النظام ويمكن استرجاعه لاحقاً.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: scheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    final service = ref.read(receiptServiceProvider);
    final ok = await service.delete(
      receipt.id,
      reason: 'حذف من شاشة تفاصيل الإيصال',
    );

    if (!context.mounted) return;

    if (ok) {
      ref.read(receiptsListProvider.notifier).refresh();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم حذف الإيصال بنجاح'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('فشل حذف الإيصال'),
          backgroundColor: scheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _copyTracking(BuildContext context) async {
    final url = _buildTrackUrl();
    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يوجد رقم إيصال أو رقم تليفون للمشاركة'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await Clipboard.setData(ClipboardData(text: url));

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم نسخ رابط التتبع'),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _shareTracking(BuildContext context) async {
    final url = _buildTrackUrl();
    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يوجد رقم إيصال أو رقم تليفون للمشاركة'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final customerPhone = receipt.customerPhone;
    if (customerPhone != null && customerPhone.isNotEmpty) {
      final cleanedPhone = customerPhone.replaceAll(RegExp(r'\D'), '');
      final message = Uri.encodeComponent(
        '📱 متابعة حالة جهازك في FixHub:\n'
        'رقم الإيصال: ${receipt.receiptNumber}\n'
        'الرابط: $url\n\n'
        'شكراً لتعاملك معنا 🌹',
      );
      final whatsappUrl = 'https://wa.me/$cleanedPhone?text=$message';

      try {
        final launched = await launchUrl(
          Uri.parse(whatsappUrl),
          mode: LaunchMode.externalApplication,
        );
        if (launched) return;
      } catch (_) {
        // fallback
      }
    }

    await Clipboard.setData(ClipboardData(text: url));

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          customerPhone != null && customerPhone.isNotEmpty
              ? 'تم نسخ رابط التتبع (تعذّر فتح واتساب)'
              : 'تم نسخ رابط التتبع',
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  STATUS PICKER SHEET
// ═══════════════════════════════════════════════════════════

class _StatusPickerSheet extends StatelessWidget {
  const _StatusPickerSheet({required this.current});

  final ReceiptStatus current;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.spaceMd),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: scheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.tune, color: scheme.primary, size: 20),
                const SizedBox(width: AppSizes.spaceSm),
                Text(
                  'تغيير الحالة',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: ReceiptStatus.values.map((status) {
                  final isCurrent = status == current;
                  return ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: status.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      ),
                      child: Icon(
                        status.icon,
                        size: 20,
                        color: status.color,
                      ),
                    ),
                    title: Text(
                      status.labelAr,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                    trailing: isCurrent
                        ? Icon(
                            Icons.check_circle,
                            color: scheme.primary,
                            size: 22,
                          )
                        : null,
                    onTap:
                        isCurrent ? null : () => Navigator.pop(context, status),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}