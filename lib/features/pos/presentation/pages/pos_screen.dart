// lib/features/pos/presentation/pages/pos_screen.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/cart_item.dart';
import '../../data/services/sales_service.dart';
import '../../data/services/receipt_service.dart';
import '../../../inventory/presentation/pages/inventory_list_v2_page.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final _sales = SalesService();
  final _searchController = TextEditingController();

  final List<CartItem> _cart = [];
  final Map<String, int> _availableQtyById = {};
  final List> _products = [];
  List> _filteredProducts = [];

  bool _loading = true;
  bool _processing = false;
  String? _error;
  String? _tenantId;

  // متغيرات المحل
  String _shopName = 'FixHub';
  String _shopPhone = 'غير مسجل';

  @override
  void initState() {
    super.initState();
    _bootstrap();
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterProducts);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      if (user == null) {
        throw 'المستخدم غير مسجل دخول';
      }

      final staff = await client
          .from('staff')
          .select('tenant_id')
          .eq('user_id', user.id)
          .maybeSingle();

      _tenantId = staff?['tenant_id'] as String?;
      if (_tenantId == null || _tenantId!.trim().isEmpty) {
        throw 'لم يتم العثور على tenant_id لهذا المستخدم';
      }

      // جلب بيانات المحل
      final tenant = await client
          .from('tenants')
          .select('name, phone')
          .eq('id', _tenantId!)
          .maybeSingle();

      if (tenant != null) {
        final fetchedName = (tenant['name'] as String?)?.trim() ?? '';
        final fetchedPhone = (tenant['phone'] as String?)?.trim() ?? '';
        _shopName = fetchedName.isNotEmpty ? fetchedName : 'FixHub';
        _shopPhone = fetchedPhone.isNotEmpty ? fetchedPhone : 'غير مسجل';
      }

      final inv = await client
          .from('inventory')
          .select(
              'id, name, name_ar, selling_price, quantity, barcode, category, item_type')
          .eq('tenant_id', _tenantId!)
          .eq('is_shop_item', true)
          .isFilter('deleted_at', null)
          .limit(200);

      _products.clear();
      _availableQtyById.clear();

      for (final row in (inv as List)) {
        final id = row['id'].toString();
        final qty = (row['quantity'] as num?)?.toInt() ?? 0;
        _availableQtyById[id] = qty;
        _products.add({
          'id': id,
          'name': row['name_ar'] ?? row['name'] ?? 'بدون اسم',
          'name_en': row['name'] ?? '',
          'price': (row['selling_price'] as num?)?.toDouble() ?? 0.0,
          'qty': qty,
          'barcode': row['barcode'] ?? '',
          'category': row['category'] ?? '',
          'item_type': row['item_type'] ?? 'accessory',
        });
      }

      _filterProducts();
      if (!mounted) return;
      setState(() {
        _error = null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _filterProducts() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = List>.from(_products);
        return;
      }
      _filteredProducts = _products.where((p) {
        final nameAr = p['name'].toString().toLowerCase();
        final nameEn = p['name_en'].toString().toLowerCase();
        final barcode = p['barcode'].toString().toLowerCase();
        return nameAr.contains(query) ||
            nameEn.contains(query) ||
            barcode.contains(query);
      }).toList();
    });
  }

  IconData _getIconForProduct(Map<String, dynamic> p) {
    if (p['item_type'] == 'phone_new') return Icons.phone_iphone;
    if (p['item_type'] == 'phone_used') return Icons.phone_android;

    final nameAr = (p['name'] ?? '').toString();
    final nameEn = (p['name_en'] ?? '').toString().toLowerCase();
    final cat = (p['category'] ?? '').toString();

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

  void _addToCart(Map<String, dynamic> p) {
    final productId = p['id'].toString();
    final maxQty = _availableQtyById[productId] ?? ((p['qty'] as int?) ?? 0);
    if (maxQty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الكمية غير متوفرة في المخزون'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final idx = _cart.indexWhere((c) => c.productId == productId);
    final currentQty = idx >= 0 ? _cart[idx].qty : 0;
    if (currentQty >= maxQty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الحد الأقصى المتاح في المخزون هو $maxQty'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      if (idx >= 0) {
        _cart[idx].qty++;
      } else {
        _cart.add(
          CartItem(
            productId: productId,
            name: p['name'].toString(),
            price: ((p['price'] as num?)?.toDouble() ?? 0.0),
          ),
        );
      }
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      if (_cart[index].qty > 1) {
        _cart[index].qty--;
      } else {
        _cart.removeAt(index);
      }
    });
  }

  double get _total => _cart.fold(0.0, (a, b) => a + b.total);

  Future<void> _showCheckoutDialog() async {
    String paymentMethod = 'نقدي';
    final customerNameController = TextEditingController();
    final addressController = TextEditingController();
    final paidAmountController =
        TextEditingController(text: _total.toStringAsFixed(2));

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('إتمام البيع'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: paymentMethod,
                decoration: const InputDecoration(labelText: 'طريقة الدفع'),
                items: const [
                  DropdownMenuItem(value: 'نقدي', child: Text('نقدي')),
                  DropdownMenuItem(value: 'آجل', child: Text('آجل')),
                  DropdownMenuItem(value: 'كاش', child: Text('كاش')),
                  DropdownMenuItem(value: 'إنستاباي', child: Text('إنستاباي')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    paymentMethod = val;
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: customerNameController,
                decoration:
                    const InputDecoration(labelText: 'اسم العميل (اختياري)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration:
                    const InputDecoration(labelText: 'العنوان (اختياري)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: paidAmountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'المبلغ المدفوع'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('تأكيد وطباعة'),
          ),
        ],
      ),
    );

    final customerName = customerNameController.text.trim();
    final address = addressController.text.trim();
    final parsedPaid = double.tryParse(paidAmountController.text.trim());

    customerNameController.dispose();
    addressController.dispose();
    paidAmountController.dispose();

    if (result == true) {
      await _checkout(
        paymentMethod: paymentMethod,
        customerName: customerName,
        address: address,
        paidAmount: parsedPaid ?? _total,
      );
    }
  }

  Future<void> _checkout({
    required String paymentMethod,
    required String customerName,
    required String address,
    required double paidAmount,
  }) async {
    if (_cart.isEmpty || _tenantId == null) {
      return;
    }

    setState(() => _processing = true);
    try {
      final items = _cart
          .map((c) => {
                'product_id': c.productId,
                'name': c.name,
                'item_type': 'accessory',
                'quantity': c.qty,
                'unit_price': c.price,
                'line_total': c.total,
              })
          .toList();

      await _sales.createSaleInvoice(
        tenantId: _tenantId!,
        items: items,
        paidAmount: paidAmount,
        customerName: customerName.isEmpty ? null : customerName,
      );

      if (!mounted) {
        return;
      }

      final receiptItems = _cart
          .map((c) => {
                'name': c.name,
                'qty': c.qty,
                'price': c.price,
                'total': c.total,
              })
          .toList();

      try {
        await ReceiptService.printReceipt(
          context: context,
          shopName: _shopName, // استخدام اسم المحل من الداتابيز
          shopPhone: _shopPhone, // استخدام رقم التليفون من الداتابيز
          items: receiptItems,
          totalAmount: _total,
          paymentMethod: paymentMethod,
          customerName: customerName,
          address: address,
          paidAmount: paidAmount,
        );
      } catch (printError) {
        debugPrint('فشل الطباعة: $printError');
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إتمام البيع بنجاح ✅'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _cart.clear();
        _processing = false;
      });
      await _bootstrap();
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _processing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في البيع: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('نقطة البيع')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      );
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('نقطة البيع - كاشير'),
        actions: [
          IconButton(
            icon: const Icon(Icons.inventory, color: Colors.blue),
            tooltip: 'إدارة المخزون',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const InventoryListV2Page(),
                ),
              );
              if (!mounted) {
                return;
              }
              setState(() {
                _loading = true;
                _products.clear();
              });
              await _bootstrap();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _loading = true;
                _products.clear();
              });
              _bootstrap();
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 750;
          final productsSection = _buildProductsSection(theme);
          final cartSection = _buildCartSection(
            theme,
            width: isWide ? 350 : double.infinity,
          );

          if (isWide) {
            return Row(
              children: [
                Expanded(flex: 2, child: productsSection),
                cartSection,
              ],
            );
          }

          return Column(
            children: [
              Expanded(flex: 3, child: productsSection),
              const Divider(height: 1),
              Expanded(flex: 2, child: cartSection),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProductsSection(ThemeData theme) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'ابحث بالاسم أو الباركود...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
        ),
        Expanded(
          child: _filteredProducts.isEmpty
              ? const Center(child: Text('لا توجد منتجات مطابقة'))
              : GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: _filteredProducts.length,
                  itemBuilder: (context, i) {
                    final p = _filteredProducts[i];
                    return InkWell(
                      onTap: () => _addToCart(p),
                      borderRadius: BorderRadius.circular(12),
                      child: Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _getIconForProduct(p),
                                size: 36,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                p['name'].toString(),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${p['price']} ج.م',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'متاح: ${p['qty']}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCartSection(ThemeData theme, {required double width}) {
    return Container(
      width: width,
      color: theme.colorScheme.surfaceContainerLow,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'سلة المشتريات',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _cart.isEmpty
                ? const Center(child: Text('السلة فارغة'))
                : ListView.separated(
                    itemCount: _cart.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final c = _cart[i];
                      return ListTile(
                        title: Text(c.name),
                        subtitle: Text('${c.price} ج.م × ${c.qty}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(