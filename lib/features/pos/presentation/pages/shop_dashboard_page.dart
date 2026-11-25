// lib/features/pos/presentation/pages/shop_dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../inventory/presentation/pages/inventory_list_v2_page.dart';

class ShopDashboardPage extends StatelessWidget {
  const ShopDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المحل - مبيعات وإكسسوارات'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'أهلاً بك في إدارة المحل',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'من هنا يمكنك إدارة نقطة البيع، المخزون، والجرد الخاص بالإكسسوارات والهواتف.',
              style: TextStyle(
                  fontSize: 14, color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),

            // شبكة الأزرار
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _buildMenuCard(
                    context,
                    title: 'نقطة البيع',
                    subtitle: 'الكاشير وإصدار الفواتير',
                    icon: Icons.point_of_sale,
                    color: Colors.green,
                    onTap: () => context.push(RouteNames.pos),
                  ),
                  _buildMenuCard(
                    context,
                    title: 'إدارة المخزون',
                    subtitle: 'إضافة وتعديل الأصناف',
                    icon: Icons.inventory_2,
                    color: Colors.blue,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const InventoryListV2Page()),
                    ),
                  ),
                  _buildMenuCard(
                    context,
                    title: 'الجرد',
                    subtitle: 'مراجعة الكميات',
                    icon: Icons.assignment,
                    color: Colors.orange,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('شاشة الجرد قريباً...')),
                      );
                    },
                  ),
                  _buildMenuCard(
                    context,
                    title: 'سجل المبيعات',
                    subtitle: 'فواتير اليوم',
                    icon: Icons.receipt_long,
                    color: Colors.purple,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('سجل المبيعات قريباً...')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
