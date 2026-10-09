// lib/core/router/app_placeholder_pages.dart

import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════
/// Placeholder Pages — صفحات مؤقتة
/// ═══════════════════════════════════════════════════════════
///
/// ⚠️ مهم: الملف ده مؤقت!
/// لما نعمل الشاشة الحقيقية في المرحلة 9، هنستبدل الـ placeholder.
///
/// كل صفحة بسيطة: Center + Icon + Text + اسم الصفحة
///
class PlaceholderPage extends StatelessWidget {
  final String title;
  final IconData icon;

  const PlaceholderPage({
    super.key,
    required this.title,
    this.icon = Icons.construction,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: scheme.surfaceContainer,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 80,
                color: scheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'قيد التطوير',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// AUTH PAGES (placeholders)
// ═══════════════════════════════════════════════════════════

class LoginPlaceholderPage extends StatelessWidget {
  const LoginPlaceholderPage({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderPage(
        title: 'تسجيل الدخول',
        icon: Icons.login,
      );
}

class SignupPlaceholderPage extends StatelessWidget {
  const SignupPlaceholderPage({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderPage(
        title: 'إنشاء حساب',
        icon: Icons.person_add,
      );
}

class ForgotPasswordPlaceholderPage extends StatelessWidget {
  const ForgotPasswordPlaceholderPage({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderPage(
        title: 'نسيت كلمة المرور',
        icon: Icons.lock_reset,
      );
}

class ResetPasswordPlaceholderPage extends StatelessWidget {
  const ResetPasswordPlaceholderPage({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderPage(
        title: 'إعادة تعيين كلمة المرور',
        icon: Icons.password,
      );
}

class PinLockPlaceholderPage extends StatelessWidget {
  const PinLockPlaceholderPage({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderPage(
        title: 'قفل PIN',
        icon: Icons.pin,
      );
}

// ═══════════════════════════════════════════════════════════
// MAIN PAGES (placeholders)
// ═══════════════════════════════════════════════════════════

class ReceiptsPlaceholderPage extends StatelessWidget {
  const ReceiptsPlaceholderPage({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderPage(
        title: 'الإيصالات',
        icon: Icons.receipt_long,
      );
}

class ReceiptDetailPlaceholderPage extends StatelessWidget {
  final String id;
  const ReceiptDetailPlaceholderPage({super.key, required this.id});
  @override
  Widget build(BuildContext context) => PlaceholderPage(
        title: 'تفاصيل إيصال #$id',
        icon: Icons.receipt,
      );
}

class ReceiptCreatePlaceholderPage extends StatelessWidget {
  const ReceiptCreatePlaceholderPage({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderPage(
        title: 'إنشاء إيصال',
        icon: Icons.add_box,
      );
}

class ReceiptEditPlaceholderPage extends StatelessWidget {
  final String id;
  const ReceiptEditPlaceholderPage({super.key, required this.id});
  @override
  Widget build(BuildContext context) => PlaceholderPage(
        title: 'تعديل إيصال #$id',
        icon: Icons.edit,
      );
}

class InventoryPlaceholderPage extends StatelessWidget {
  const InventoryPlaceholderPage({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderPage(
        title: 'المخزون',
        icon: Icons.inventory_2,
      );
}

class InventoryDetailPlaceholderPage extends StatelessWidget {
  final String id;
  const InventoryDetailPlaceholderPage({super.key, required this.id});
  @override
  Widget build(BuildContext context) => PlaceholderPage(
        title: 'تفاصيل قطعة #$id',
        icon: Icons.inventory,
      );
}

class InventoryEditPlaceholderPage extends StatelessWidget {
  const InventoryEditPlaceholderPage({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderPage(
        title: 'إضافة / تعديل قطعة',
        icon: Icons.add_circle,
      );
}

class SuppliersPlaceholderPage extends StatelessWidget {
  const SuppliersPlaceholderPage({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderPage(
        title: 'الموردين',
        icon: Icons.business,
      );
}

class SupplierDetailPlaceholderPage extends StatelessWidget {
  final String id;
  const SupplierDetailPlaceholderPage({super.key, required this.id});
  @override
  Widget build(BuildContext context) => PlaceholderPage(
        title: 'تفاصيل مورد #$id',
        icon: Icons.store,
      );
}

class SupplierEditPlaceholderPage extends StatelessWidget {
  const SupplierEditPlaceholderPage({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderPage(
        title: 'إضافة / تعديل مورد',
        icon: Icons.add_business,
      );
}

class SupplierInvoicesPlaceholderPage extends StatelessWidget {
  final String id;
  const SupplierInvoicesPlaceholderPage({super.key, required this.id});
  @override
  Widget build(BuildContext context) => PlaceholderPage(
        title: 'فواتير المورد #$id',
        icon: Icons.receipt,
      );
}

class SupplierPaymentsPlaceholderPage extends StatelessWidget {
  final String id;
  const SupplierPaymentsPlaceholderPage({super.key, required this.id});
  @override
  Widget build(BuildContext context) => PlaceholderPage(
        title: 'مدفوعات المورد #$id',
        icon: Icons.payments,
      );
}

class SupplierReturnsPlaceholderPage extends StatelessWidget {
  final String id;
  const SupplierReturnsPlaceholderPage({super.key, required this.id});
  @override
  Widget build(BuildContext context) => PlaceholderPage(
        title: 'مرتجعات المورد #$id',
        icon: Icons.assignment_return,
      );
}

class StaffPlaceholderPage extends StatelessWidget {
  const StaffPlaceholderPage({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderPage(
        title: 'الموظفين',
        icon: Icons.people,
      );
}

class StaffDetailPlaceholderPage extends StatelessWidget {
  final String id;
  const StaffDetailPlaceholderPage({super.key, required this.id});
  @override
  Widget build(BuildContext context) => PlaceholderPage(
        title: 'تفاصيل موظف #$id',
        icon: Icons.person,
      );
}

class StaffEditPlaceholderPage extends StatelessWidget {
  const StaffEditPlaceholderPage({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderPage(
        title: 'إضافة / تعديل موظف',
        icon: Icons.person_add_alt,
      );
}

class ExpensesPlaceholderPage extends StatelessWidget {
  const ExpensesPlaceholderPage({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderPage(
        title: 'المصروفات',
        icon: Icons.money_off,
      );
}

class ExpenseDetailPlaceholderPage extends StatelessWidget {
  final String id;
  const ExpenseDetailPlaceholderPage({super.key, required this.id});
  @override
  Widget build(BuildContext context) => PlaceholderPage(
        title: 'تفاصيل مصروف #$id',
        icon: Icons.receipt,
      );
}

class ExpenseEditPlaceholderPage extends StatelessWidget {
  const ExpenseEditPlaceholderPage({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderPage(
        title: 'إضافة / تعديل مصروف',
        icon: Icons.add_card,
      );
}

class DeliveryPlaceholderPage extends StatelessWidget {
  const DeliveryPlaceholderPage({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderPage(
        title: 'التسليم',
        icon: Icons.local_shipping,
      );
}

class ReportsPlaceholderPage extends StatelessWidget {
  const ReportsPlaceholderPage({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderPage(
        title: 'التقارير',
        icon: Icons.bar_chart,
      );
}

class ScannerPlaceholderPage extends StatelessWidget {
  const ScannerPlaceholderPage({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderPage(
        title: 'الماسح',
        icon: Icons.qr_code_scanner,
      );
}

class TrackingPlaceholderPage extends StatelessWidget {
  const TrackingPlaceholderPage({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderPage(
        title: 'التتبع',
        icon: Icons.track_changes,
      );
}

class TrackingDetailPlaceholderPage extends StatelessWidget {
  final String token;
  const TrackingDetailPlaceholderPage({super.key, required this.token});
  @override
  Widget build(BuildContext context) => PlaceholderPage(
        title: 'تتبع #$token',
        icon: Icons.location_on,
      );
}

class CloudSyncPlaceholderPage extends StatelessWidget {
  const CloudSyncPlaceholderPage({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderPage(
        title: 'المزامنة السحابية',
        icon: Icons.cloud_sync,
      );
}

class BackupPlaceholderPage extends StatelessWidget {
  const BackupPlaceholderPage({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderPage(
        title: 'النسخ الاحتياطي',
        icon: Icons.backup,
      );
}

class ActivityLogPlaceholderPage extends StatelessWidget {
  const ActivityLogPlaceholderPage({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderPage(
        title: 'سجل النشاط',
        icon: Icons.history,
      );
}

class SubscriptionPlaceholderPage extends StatelessWidget {
  const SubscriptionPlaceholderPage({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderPage(
        title: 'الاشتراكات',
        icon: Icons.workspace_premium,
      );
}

// ═══════════════════════════════════════════════════════════
// SETTINGS PAGES (placeholders)
// ═══════════════════════════════════════════════════════════

class SettingsPlaceholderPage extends StatelessWidget {
  const SettingsPlaceholderPage({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderPage(
        title: 'الإعدادات',
        icon: Icons.settings,
      );
}

class ShopInfoPlaceholderPage extends StatelessWidget {
  const ShopInfoPlaceholderPage({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderPage(
        title: 'معلومات الورشة',
        icon: Icons.storefront,
      );
}

class WhatsappSettingsPlaceholderPage extends StatelessWidget {
  const WhatsappSettingsPlaceholderPage({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderPage(
        title: 'إعدادات الواتساب',
        icon: Icons.chat,
      );
}

class LanguageSettingsPlaceholderPage extends StatelessWidget {
  const LanguageSettingsPlaceholderPage({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderPage(
        title: 'إعدادات اللغة',
        icon: Icons.language,
      );
}

class SecuritySettingsPlaceholderPage extends StatelessWidget {
  const SecuritySettingsPlaceholderPage({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderPage(
        title: 'إعدادات الأمان',
        icon: Icons.security,
      );
}

class AboutPlaceholderPage extends StatelessWidget {
  const AboutPlaceholderPage({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderPage(
        title: 'حول التطبيق',
        icon: Icons.info,
      );
}

class NotFoundPlaceholderPage extends StatelessWidget {
  const NotFoundPlaceholderPage({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderPage(
        title: 'الصفحة غير موجودة',
        icon: Icons.error_outline,
      );
}