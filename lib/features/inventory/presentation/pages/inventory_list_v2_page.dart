// lib/features/inventory/presentation/pages/inventory_list_v2_page.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'inventory_form_v2_page.dart';

class InventoryListV2Page extends StatefulWidget {
  const InventoryListV2Page({super.key});

  @override
  State<InventoryListV2Page> createState() => _InventoryListV2PageState();
}

class _InventoryListV2PageState extends State<InventoryListV2Page> {
  final _client = Supabase.instance.client;
  final _searchController = TextEditingController();

  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _filteredItems = [];
  bool _isLoading = true;
  String _filterType = 'all'; // all, accessory, phone_new, phone_used

  @override
  void initState() {
    super.initState();
    _fetchItems();
    _searchController.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchItems() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw 'غير مسجل دخول';

      final staff = await _client
          .from('staff')
          .select('tenant_id')
          .eq('user_id', user.id)
          .maybeSingle();
      final tenantId = staff?['tenant_id'];
      if (tenantId == null) throw 'لا يوجد tenant_id';

      final res = await _client
          .from('inventory')
          .select()
          .eq('tenant_id', tenantId)
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false);

      setState(() {
        _items = List<Map<String, dynamic>>.from(res);
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('خطأ: $e')));
      }
    }
  }

  void _applyFilter() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = _items.where((item) {
        final name = (item['name'] ?? '').toString().toLowerCase();
        final nameAr = (item['name_ar'] ?? '').toString().toLowerCase();
        final barcode = (item['barcode'] ?? '').toString().toLowerCase();
        final matchesSearch = name.contains(query) ||
            nameAr.contains(query) ||
            barcode.contains(query);

        final itemType = item['item_type'] ?? 'accessory';
        final matchesType = _filterType == 'all' || itemType == _filterType;

        return matchesSearch && matchesType;
      }).toList();
    });
  }

  // ✅ دالة تحديد الأيقونة (تعتمد على الفئة أو الاسم)
  IconData _getIconForItem(Map<String, dynamic> item) {
    if (item['item_type'] == 'phone_new') return Icons.phone_iphone;
    if (item['item_type'] == 'phone_used') return Icons.phone_android;

    final nameAr = (item['name_ar'] ?? item['name'] ?? '').toString();
    final nameEn = (item['name'] ?? '').toString().toLowerCase();
    final cat = (item['category'] ?? '').toString();

    if (cat == 'جراب' ||
        nameAr.contains('جراب') ||
        nameEn.contains('case') ||
        nameEn.contains('cover')) {
      return Icons.phone_iphone;
    }
    if (cat == 'اسكرينة' ||
        nameAr.contains('اسكرين') ||
        nameAr.contains('حماية') ||
        nameEn.contains('screen') ||
        nameEn.contains('glass')) {
      return Icons.screen_lock_portrait;
    }
    if (cat == 'سماعة' ||
        nameAr.contains('سماع') ||
        nameAr.contains('هيدفون') ||
        nameEn.contains('headphone') ||
        nameEn.contains('earphone')) {
      return Icons.headphones;
    }
    if (cat == 'شاحن' ||
        nameAr.contains('شاحن') ||
        nameEn.contains('charger')) {
      return Icons.power;
    }
    if (cat == 'كابل' ||
        nameAr.contains('كابل') ||
        nameAr.contains('سلك') ||
        nameEn.contains('cable')) {
      return Icons.cable;
    }
    if (cat == 'باور بانك' ||
        nameAr.contains('بطاري') ||
        nameAr.contains('باور') ||
        nameEn.contains('power') ||
        nameEn.contains('battery')) {
      return Icons.battery_charging_full;
    }
    return Icons.inventory_2_outlined;
  }

  Future<void> _deleteItem(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا الصنف؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('حذف', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _client.from('inventory').update(
          {'deleted_at': DateTime.now().toIso8601String()}).eq('id', id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('تم حذف الصنف بنجاح'),
              backgroundColor: Colors.green),
        );
      }
      _fetchItems(); // ✅ تحديث القائمة فوراً بعد الحذف
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('خطأ في الحذف: $e')));
      }
    }
  }

  void _openForm([Map<String, dynamic>? item]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => InventoryFormV2Page(itemToEdit: item)),
    );
    if (result == true) _fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المخزون'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchItems),
        ],
      ),
      body: Column(
        children: [
          // شريط البحث
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث بالاسم أو الباركود...',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          // فلاتر النوع
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _buildFilterChip('الكل', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('إكسسوارات', 'accessory'),
                const SizedBox(width: 8),
                _buildFilterChip('هواتف جديدة', 'phone_new'),
                const SizedBox(width: 8),
                _buildFilterChip('هواتف مستعملة', 'phone_used'),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // قائمة الأصناف
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredItems.isEmpty
                    ? const Center(child: Text('لا توجد أصناف مطابقة للبحث'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _filteredItems.length,
                        itemBuilder: (context, i) {
                          final item = _filteredItems[i];
                          final isPhone = item['item_type'] == 'phone_new' ||
                              item['item_type'] == 'phone_used';
                          final qty = item['quantity'] ?? 0;
                          final isLowStock = qty < 5;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isPhone
                                    ? Colors.blue.withValues(alpha: 0.2)
                                    : Colors.green.withValues(alpha: 0.2),
                                child: Icon(
                                  _getIconForItem(
                                      item), // ✅ استخدام الأيقونة الديناميكية
                                  color: isPhone ? Colors.blue : Colors.green,
                                ),
                              ),
                              title: Text(item['name_ar'] ??
                                  item['name'] ??
                                  'بدون اسم'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      '${item['selling_price']} ج.م | الموديل: ${item['model'] ?? '-'}'),
                                  Row(
                                    children: [
                                      Text('الكمية: $qty',
                                          style: TextStyle(
                                              color: isLowStock
                                                  ? Colors.red
                                                  : Colors.grey,
                                              fontWeight: isLowStock
                                                  ? FontWeight.bold
                                                  : FontWeight.normal)),
                                      if (item['barcode'] != null) ...[
                                        const SizedBox(width: 8),
                                        Text('باركود: ${item['barcode']}',
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey)),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      onPressed: () => _openForm(item)),
                                  IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () => _deleteItem(item['id'])),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('إضافة صنف'),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterType == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() => _filterType = value);
        _applyFilter();
      },
    );
  }
}
