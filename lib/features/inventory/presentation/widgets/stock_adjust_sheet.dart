// lib/features/inventory/presentation/widgets/stock_adjust_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../data/models/inventory_item.dart';

/// ═══════════════════════════════════════════════════════════
/// StockAdjustMode — نوع العملية
/// ═══════════════════════════════════════════════════════════
enum StockAdjustMode { add, remove, adjust }

/// ═══════════════════════════════════════════════════════════
/// StockAdjustResult — نتيجة النموذج
/// ═══════════════════════════════════════════════════════════
class StockAdjustResult {
  final StockAdjustMode mode;
  final int quantity;
  final MovementType movementType;
  final String? notes;

  const StockAdjustResult({
    required this.mode,
    required this.quantity,
    required this.movementType,
    this.notes,
  });
}

/// ═══════════════════════════════════════════════════════════
/// StockAdjustSheet — Bottom Sheet لتعديل كمية
/// ═══════════════════════════════════════════════════════════
class StockAdjustSheet extends StatefulWidget {
  const StockAdjustSheet({
    super.key,
    required this.item,
    required this.mode,
  });

  final InventoryItem item;
  final StockAdjustMode mode;

  @override
  State<StockAdjustSheet> createState() => _StockAdjustSheetState();
}

class _StockAdjustSheetState extends State<StockAdjustSheet> {
  late final TextEditingController _qtyController;
  late final TextEditingController _notesController;

  late MovementType _movementType;

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController();
    _notesController = TextEditingController();

    // نوع الحركة الافتراضي
    switch (widget.mode) {
      case StockAdjustMode.add:
        _movementType = MovementType.purchase;
        break;
      case StockAdjustMode.remove:
        _movementType = MovementType.usage;
        break;
      case StockAdjustMode.adjust:
        _movementType = MovementType.adjustment;
        _qtyController.text = '${widget.item.quantity}';
        break;
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.spaceMd),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Header ───
              _Header(item: widget.item, mode: widget.mode),

              const SizedBox(height: AppSizes.spaceMd),

              // ─── Current quantity ───
              _CurrentQtyCard(item: widget.item),

              const SizedBox(height: AppSizes.spaceMd),

              // ─── Movement type (للإدخال/الإخراج) ───
              if (widget.mode != StockAdjustMode.adjust) ...[
                Text(
                  widget.mode == StockAdjustMode.add
                      ? 'سبب الإدخال'
                      : 'سبب الإخراج',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppSizes.spaceSm),
                _MovementTypePicker(
                  mode: widget.mode,
                  selected: _movementType,
                  onChanged: (t) => setState(() => _movementType = t),
                  scheme: scheme,
                ),
                const SizedBox(height: AppSizes.spaceMd),
              ],

              // ─── Quantity input ───
              Text(
                widget.mode == StockAdjustMode.adjust
                    ? 'الكمية الجديدة'
                    : 'الكمية',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSizes.spaceSm),
              TextField(
                controller: _qtyController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: '0',
                  filled: true,
                  fillColor: scheme.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    borderSide: BorderSide(
                      color: scheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    borderSide: BorderSide(
                      color: scheme.primary,
                      width: AppSizes.borderMedium,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: AppSizes.spaceSmMd,
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.spaceMd),

              // ─── Notes ───
              TextField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'ملاحظات (اختياري)',
                  hintText: 'مثال: شراء من المورد أحمد',
                  filled: true,
                  fillColor: scheme.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    borderSide: BorderSide(
                      color: scheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    borderSide: BorderSide(
                      color: scheme.primary,
                      width: AppSizes.borderMedium,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.spaceMd),

              // ─── Preview ───
              _Preview(
                current: widget.item.quantity,
                mode: widget.mode,
                newQty: _parsedQty(),
                scheme: scheme,
              ),

              const SizedBox(height: AppSizes.spaceMd),

              // ─── Actions ───
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(
                          0,
                          AppSizes.buttonHeightLg,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusLg,
                          ),
                        ),
                      ),
                      child: const Text('إلغاء'),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spaceSm),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _isValid() ? _submit : null,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(
                          0,
                          AppSizes.buttonHeightLg,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusLg,
                          ),
                        ),
                      ),
                      child: const Text(
                        'تأكيد',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Helpers ───

  int _parsedQty() {
    return int.tryParse(_qtyController.text.trim()) ?? 0;
  }

  bool _isValid() {
    final qty = _parsedQty();
    if (qty < 0) return false;

    switch (widget.mode) {
      case StockAdjustMode.add:
        return qty > 0;
      case StockAdjustMode.remove:
        return qty > 0 && qty <= widget.item.quantity;
      case StockAdjustMode.adjust:
        return qty >= 0;
    }
  }

  void _submit() {
    final qty = _parsedQty();
    final notes = _notesController.text.trim();

    Navigator.pop(
      context,
      StockAdjustResult(
        mode: widget.mode,
        quantity: qty,
        movementType: _movementType,
        notes: notes.isEmpty ? null : notes,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  HEADER
// ═══════════════════════════════════════════════════════════

class _Header extends StatelessWidget {
  const _Header({required this.item, required this.mode});

  final InventoryItem item;
  final StockAdjustMode mode;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final (IconData icon, String title, Color color) = switch (mode) {
      StockAdjustMode.add => (
          Icons.add_circle_outline,
          'إدخال كمية',
          const Color(0xFF10B981),
        ),
      StockAdjustMode.remove => (
          Icons.remove_circle_outline,
          'إخراج كمية',
          const Color(0xFFEF4444),
        ),
      StockAdjustMode.adjust => (
          Icons.tune,
          'تسوية الكمية',
          scheme.primary,
        ),
    };

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
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.displayName(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  CURRENT QTY CARD
// ═══════════════════════════════════════════════════════════

class _CurrentQtyCard extends StatelessWidget {
  const _CurrentQtyCard({required this.item});

  final InventoryItem item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceSmMd),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warehouse_outlined,
            size: 18,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSizes.spaceSm),
          Text(
            'الكمية الحالية',
            style: TextStyle(
              fontSize: 13,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            '${item.quantity}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  MOVEMENT TYPE PICKER
// ═══════════════════════════════════════════════════════════

class _MovementTypePicker extends StatelessWidget {
  const _MovementTypePicker({
    required this.mode,
    required this.selected,
    required this.onChanged,
    required this.scheme,
  });

  final StockAdjustMode mode;
  final MovementType selected;
  final ValueChanged<MovementType> onChanged;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final types = mode == StockAdjustMode.add
        ? const [
            MovementType.purchase,
            MovementType.returnIn,
            MovementType.adjustment,
          ]
        : const [
            MovementType.usage,
            MovementType.returnOut,
            MovementType.damaged,
            MovementType.lost,
          ];

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: types.map((type) {
        final isSelected = type == selected;
        return InkWell(
          onTap: () => onChanged(type),
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? scheme.primary.withValues(alpha: 0.15)
                  : scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
              border: Border.all(
                color: isSelected
                    ? scheme.primary
                    : scheme.outlineVariant.withValues(alpha: 0.5),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Text(
              type.labelAr,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  PREVIEW
// ═══════════════════════════════════════════════════════════

class _Preview extends StatelessWidget {
  const _Preview({
    required this.current,
    required this.mode,
    required this.newQty,
    required this.scheme,
  });

  final int current;
  final StockAdjustMode mode;
  final int newQty;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final resultingQty = switch (mode) {
      StockAdjustMode.add => current + newQty,
      StockAdjustMode.remove => current - newQty,
      StockAdjustMode.adjust => newQty,
    };

    final diff = resultingQty - current;
    final diffColor = diff > 0
        ? const Color(0xFF10B981)
        : (diff < 0 ? const Color(0xFFEF4444) : scheme.onSurfaceVariant);

    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceSmMd),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'الكمية بعد العملية',
                style: TextStyle(
                  fontSize: 11,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              Text(
                '$resultingQty',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: resultingQty < 0 ? scheme.error : scheme.onSurface,
                ),
              ),
            ],
          ),
          if (diff != 0)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: diffColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Text(
                '${diff > 0 ? "+" : ""}$diff',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: diffColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
