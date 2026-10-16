// lib/features/scanner/presentation/widgets/scanner_overlay.dart

import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';

/// ═══════════════════════════════════════════════════════════════
/// ScannerOverlay — طبقة فوق الكاميرا لإطار المسح
/// ═══════════════════════════════════════════════════════════════
///
/// - إطار مربع في الوسط (نسبة 1:1)
/// - حدود مضيئة بألوان الثيم
/// - نص تعليمي بالأسفل
/// - خلفية معتمة خارج الإطار
/// - AnimatedScanLine اختياري
///
class ScannerOverlay extends StatefulWidget {
  const ScannerOverlay({
    super.key,
    this.hintText = 'ضع الكود داخل الإطار',
    this.showAnimatedLine = true,
    this.cutOutSize,
  });

  /// نص تعليمي أسفل الإطار
  final String hintText;

  /// إظهار الخط المتحرك
  final bool showAnimatedLine;

  /// حجم الإطار (اختياري — افتراضياً 70% من العرض)
  final double? cutOutSize;

  @override
  State<ScannerOverlay> createState() => _ScannerOverlayState();
}

class _ScannerOverlayState extends State<ScannerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final size = MediaQuery.sizeOf(context);

    // حجم الإطار: 70% من العرض، أو القيمة الممررة
    final cutOut = widget.cutOutSize ?? (size.width * 0.7);

    // إحداثيات الإطار (متمركز)
    final cutOutRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.42),
      width: cutOut,
      height: cutOut,
    );

    return Stack(
      children: [
        // ──── Overlay معتم خارج الإطار ────
        Positioned.fill(
          child: CustomPaint(
            painter: _OverlayPainter(
              cutOutRect: cutOutRect,
              overlayColor: Colors.black.withValues(alpha: 0.6),
            ),
          ),
        ),

        // ──── Corner brackets (زوايا مضيئة) ────
        Positioned(
          left: cutOutRect.left,
          top: cutOutRect.top,
          width: cutOutRect.width,
          height: cutOutRect.height,
          child: CustomPaint(
            painter: _CornerBracketsPainter(
              color: scheme.primary,
              strokeWidth: 4.0,
              cornerLength: 32.0,
            ),
          ),
        ),

        // ──── Animated scan line ────
        if (widget.showAnimatedLine)
          Positioned(
            left: cutOutRect.left + AppSizes.spaceSm,
            top: cutOutRect.top,
            width: cutOutRect.width - (AppSizes.spaceSm * 2),
            height: cutOutRect.height,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Align(
                  alignment: Alignment(0, (_animation.value * 2) - 1),
                  child: Container(
                    height: 2.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          scheme.primary.withValues(alpha: 0.0),
                          scheme.primary,
                          scheme.primary.withValues(alpha: 0.0),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: scheme.primary.withValues(alpha: 0.6),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

        // ──── Hint text ────
        Positioned(
          left: 0,
          right: 0,
          top: cutOutRect.bottom + AppSizes.spaceLg,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spaceLg,
            ),
            child: Text(
              widget.hintText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                shadows: [
                  Shadow(
                    blurRadius: 4,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  OVERLAY PAINTER — يعتم خارج الإطار
// ═══════════════════════════════════════════════════════════════

class _OverlayPainter extends CustomPainter {
  _OverlayPainter({
    required this.cutOutRect,
    required this.overlayColor,
  });

  final Rect cutOutRect;
  final Color overlayColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = overlayColor;

    // ارسم مستطيل كامل مع فتحة (even-odd path)
    final path = Path()
      ..addRect(Offset.zero & size)
      ..addRRect(
        RRect.fromRectAndRadius(
          cutOutRect,
          const Radius.circular(AppSizes.radiusXl),
        ),
      )
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter old) =>
      old.cutOutRect != cutOutRect || old.overlayColor != overlayColor;
}

// ═══════════════════════════════════════════════════════════════
//  CORNER BRACKETS PAINTER — زوايا مضيئة
// ═══════════════════════════════════════════════════════════════

class _CornerBracketsPainter extends CustomPainter {
  _CornerBracketsPainter({
    required this.color,
    required this.strokeWidth,
    required this.cornerLength,
  });

  final Color color;
  final double strokeWidth;
  final double cornerLength;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;
    final l = cornerLength;

    // ──── Top-Left ────
    canvas.drawPath(
      Path()
        ..moveTo(0, l)
        ..lineTo(0, 0)
        ..lineTo(l, 0),
      paint,
    );

    // ──── Top-Right ────
    canvas.drawPath(
      Path()
        ..moveTo(w - l, 0)
        ..lineTo(w, 0)
        ..lineTo(w, l),
      paint,
    );

    // ──── Bottom-Left ────
    canvas.drawPath(
      Path()
        ..moveTo(0, h - l)
        ..lineTo(0, h)
        ..lineTo(l, h),
      paint,
    );

    // ──── Bottom-Right ────
    canvas.drawPath(
      Path()
        ..moveTo(w - l, h)
        ..lineTo(w, h)
        ..lineTo(w, h - l),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CornerBracketsPainter old) =>
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.cornerLength != cornerLength;
}
