// lib/features/scanner/presentation/pages/scanner_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_names.dart';
import '../../../receipts/data/models/receipt.dart';
import '../providers/scanner_provider.dart';
import '../widgets/scanner_overlay.dart';

/// ═══════════════════════════════════════════════════════════════
/// ScannerPage — صفحة المسح (باركود / QR / IMEI)
/// ═══════════════════════════════════════════════════════════════
///
/// وضعان:
/// - Tool Mode:  popOnDetect=true → يرجّع القيمة فوراً
/// - Standalone: popOnDetect=false → يبحث في Supabase ويعرض النتيجة
///
class ScannerPage extends ConsumerStatefulWidget {
  const ScannerPage({
    super.key,
    this.popOnDetect = false,
  });

  /// لو true: يرجّع القيمة بعد أول مسح (Tool mode)
  /// لو false: يبحث في قاعدة البيانات ويعرض النتيجة (Standalone)
  final bool popOnDetect;

  @override
  ConsumerState<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends ConsumerState<ScannerPage> {
  late final MobileScannerController _controller;
  bool _isSheetOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
      formats: const [
        BarcodeFormat.qrCode,
        BarcodeFormat.code128,
        BarcodeFormat.code39,
        BarcodeFormat.code93,
        BarcodeFormat.ean13,
        BarcodeFormat.ean8,
        BarcodeFormat.upcA,
        BarcodeFormat.upcE,
        BarcodeFormat.itf14,
        BarcodeFormat.codabar,
        BarcodeFormat.dataMatrix,
        BarcodeFormat.pdf417,
        BarcodeFormat.aztec,
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════
  //  DETECT — لما الكاميرا تمسح
  // ═══════════════════════════════════════════════════════════════

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (capture.barcodes.isEmpty) return;

    final barcode = capture.barcodes.first;
    final rawValue = barcode.rawValue;
    if (rawValue == null || rawValue.trim().isEmpty) return;

    // Tool Mode → رجّع القيمة فوراً
    if (widget.popOnDetect) {
      await _controller.stop();
      if (mounted) {
        Navigator.of(context).pop(rawValue);
      }
      return;
    }

    // Standalone Mode → ابحث في Supabase
    final notifier = ref.read(scannerProvider.notifier);
    await notifier.onDetect(rawValue);

    // افتح Bottom Sheet لعرض النتيجة
    if (mounted && !_isSheetOpen) {
      _isSheetOpen = true;
      await _showResultSheet();
      _isSheetOpen = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  RESULT BOTTOM SHEET
  // ═══════════════════════════════════════════════════════════════

  Future<void> _showResultSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ResultSheet(
        onRescan: () {
          Navigator.of(context).pop();
          ref.read(scannerProvider.notifier).reset();
        },
        onOpenReceipt: (receipt) {
          Navigator.of(context).pop();
          context.push(RouteNames.receiptDetailOf(receipt.id));
        },
        onOpenInventory: (itemId) {
          Navigator.of(context).pop();
          context.push(RouteNames.inventoryDetailOf(itemId));
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scannerProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ──── Camera ────
          Positioned.fill(
            child: MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
              errorBuilder: (context, error) {
                return _buildCameraError(context, error, scheme);
              },
            ),
          ),

          // ──── Overlay ────
          if (!widget.popOnDetect)
            const Positioned.fill(
              child: ScannerOverlay(
                hintText: 'ضع الباركود أو QR داخل الإطار',
              ),
            )
          else
            const Positioned.fill(
              child: ScannerOverlay(
                hintText: 'ضع الكود داخل الإطار',
                showAnimatedLine: true,
              ),
            ),

          // ──── Top Bar ────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: _buildTopBar(context, state, scheme),
            ),
          ),

          // ──── Bottom Bar (Standalone only) ────
          if (!widget.popOnDetect)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                top: false,
                child: _buildBottomBar(context, state, scheme),
              ),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  TOP BAR
  // ═══════════════════════════════════════════════════════════════

  Widget _buildTopBar(
    BuildContext context,
    ScannerState state,
    ColorScheme scheme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spaceSm,
        vertical: AppSizes.spaceSm,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          // ──── Close button ────
          IconButton(
            onPressed: () {
              if (widget.popOnDetect) {
                Navigator.of(context).pop();
              } else {
                context.pop();
              }
            },
            icon: const Icon(Icons.close, color: Colors.white),
            tooltip: 'إغلاق',
          ),
          const Spacer(),
          // ──── Title ────
          Text(
            widget.popOnDetect ? 'مسح الكود' : 'الماسح الضوئي',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          // ──── Torch ────
          IconButton(
            onPressed: () {
              _controller.toggleTorch();
              ref.read(scannerProvider.notifier).toggleTorch();
            },
            icon: Icon(
              state.isTorchOn ? Icons.flash_on : Icons.flash_off,
              color: state.isTorchOn ? const Color(0xFFF59E0B) : Colors.white,
            ),
            tooltip: 'الفلاش',
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  BOTTOM BAR (Standalone mode)
  // ═══════════════════════════════════════════════════════════════

  Widget _buildBottomBar(
    BuildContext context,
    ScannerState state,
    ColorScheme scheme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spaceMd,
        vertical: AppSizes.spaceMd,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: 0.85),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ──── Mode label ────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.tune, color: Colors.white70, size: 16),
              const SizedBox(width: AppSizes.spaceXs),
              Text(
                'وضع المسح: ${state.mode.labelAr}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceSm),

          // ──── Modes chips ────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ScanMode.values.map((mode) {
                final isSelected = state.mode == mode;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spaceXs,
                  ),
                  child: ChoiceChip(
                    label: Text(
                      mode.labelAr,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? scheme.onPrimary : Colors.white,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) {
                      ref.read(scannerProvider.notifier).setMode(mode);
                    },
                    selectedColor: scheme.primary,
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    side: BorderSide(
                      color: isSelected ? scheme.primary : Colors.white24,
                    ),
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: AppSizes.spaceSm),

          // ──── Camera switch ────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  _controller.switchCamera();
                  ref.read(scannerProvider.notifier).switchCamera();
                },
                icon: const Icon(
                  Icons.flip_camera_ios,
                  color: Colors.white,
                  size: 28,
                ),
                tooltip: 'تبديل الكاميرا',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  CAMERA ERROR
  // ═══════════════════════════════════════════════════════════════

  Widget _buildCameraError(
    BuildContext context,
    MobileScannerException error,
    ColorScheme scheme,
  ) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spaceXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.no_photography_outlined,
                size: 64,
                color: Colors.white54,
              ),
              const SizedBox(height: AppSizes.spaceMd),
              const Text(
                'تعذّر الوصول للكاميرا',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSizes.spaceSm),
              Text(
                error.errorDetails?.message ?? 'تأكد من صلاحيات الكاميرا',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: AppSizes.spaceLg),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('رجوع'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  RESULT SHEET — Bottom Sheet للنتيجة
// ═══════════════════════════════════════════════════════════════

class _ResultSheet extends ConsumerWidget {
  const _ResultSheet({
    required this.onRescan,
    required this.onOpenReceipt,
    required this.onOpenInventory,
  });

  final VoidCallback onRescan;
  final void Function(Receipt receipt) onOpenReceipt;
  final void Function(String itemId) onOpenInventory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scannerProvider);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final result = state.result;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? scheme.surfaceContainerHigh : scheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXxl),
        ),
      ),
      padding: const EdgeInsets.all(AppSizes.spaceLg),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ──── Handle ────
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

            // ──── Loading ────
            if (state.isSearching)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSizes.spaceXl),
                child: Center(child: CircularProgressIndicator()),
              )
            // ──── Result ────
            else if (result != null)
              _buildResultContent(result, scheme)
            else
              _buildEmptyContent(scheme),
          ],
        ),
      ),
    );
  }

  Widget _buildResultContent(
    ScanLookupResult result,
    ColorScheme scheme,
  ) {
    // ──── Found Receipt ────
    if (result.receipt != null) {
      final r = result.receipt!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(
            icon: Icons.receipt_long,
            color: const Color(0xFF10B981),
            title: 'تم العثور على إيصال',
            subtitle: r.receiptNumber,
            scheme: scheme,
          ),
          const SizedBox(height: AppSizes.spaceMd),
          _infoRow('العميل', r.customerName, scheme),
          _infoRow(
            'الجهاز',
            '${r.deviceBrand} ${r.deviceModel}'.trim(),
            scheme,
          ),
          _infoRow('الحالة', r.status.labelAr, scheme),
          _infoRow('الإجمالي', '${r.total.toStringAsFixed(0)} ج.م', scheme),
          const SizedBox(height: AppSizes.spaceMd),
          FilledButton.icon(
            onPressed: () => onOpenReceipt(r),
            icon: const Icon(Icons.open_in_new),
            label: const Text('فتح الإيصال'),
          ),
          const SizedBox(height: AppSizes.spaceSm),
          OutlinedButton.icon(
            onPressed: onRescan,
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('مسح جديد'),
          ),
        ],
      );
    }

    // ──── Found Inventory ────
    if (result.inventoryItem != null) {
      final item = result.inventoryItem!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(
            icon: Icons.inventory_2,
            color: const Color(0xFF3B82F6),
            title: 'تم العثور على قطعة',
            subtitle: item.name,
            scheme: scheme,
          ),
          const SizedBox(height: AppSizes.spaceMd),
          _infoRow('الكمية', '${item.quantity}', scheme),
          _infoRow(
            'سعر البيع',
            '${item.sellingPrice.toStringAsFixed(0)} ج.م',
            scheme,
          ),
          const SizedBox(height: AppSizes.spaceMd),
          FilledButton.icon(
            onPressed: () => onOpenInventory(item.id),
            icon: const Icon(Icons.open_in_new),
            label: const Text('فتح القطعة'),
          ),
          const SizedBox(height: AppSizes.spaceSm),
          OutlinedButton.icon(
            onPressed: onRescan,
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('مسح جديد'),
          ),
        ],
      );
    }

    // ──── No Match / Error ────
    return _buildEmptyContent(scheme, errorMessage: result.errorMessage);
  }

  Widget _buildEmptyContent(ColorScheme scheme, {String? errorMessage}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _header(
          icon: Icons.search_off,
          color: scheme.error,
          title: errorMessage ?? 'لا توجد نتيجة',
          subtitle: null,
          scheme: scheme,
        ),
        const SizedBox(height: AppSizes.spaceLg),
        OutlinedButton.icon(
          onPressed: onRescan,
          icon: const Icon(Icons.qr_code_scanner),
          label: const Text('مسح جديد'),
        ),
      ],
    );
  }

  Widget _header({
    required IconData icon,
    required Color color,
    required String title,
    required String? subtitle,
    required ColorScheme scheme,
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: AppSizes.spaceSmMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 12,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: AppSizes.spaceSm),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
