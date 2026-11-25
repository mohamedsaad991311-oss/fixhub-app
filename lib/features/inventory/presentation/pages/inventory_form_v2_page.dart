// lib/features/inventory/presentation/pages/inventory_form_v2_page.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InventoryFormV2Page extends StatefulWidget {
  final Map<String, dynamic>? itemToEdit;
  const InventoryFormV2Page({super.key, this.itemToEdit});

  @override
  State<InventoryFormV2Page> createState() => _InventoryFormV2PageState();
}

class _InventoryFormV2PageState extends State<InventoryFormV2Page> {
  final _formKey = GlobalKey<FormState>();
  final _client = Supabase.instance.client;

  final _nameController = TextEditingController();
  final _nameArController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _modelController = TextEditingController();
  final _serialController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _sellPriceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();

  String _itemType = 'accessory';
  String? _selectedCategory;
  String _condition = 'ممتاز';
  bool _isLoading = false;
  List<String> _existingModels = [];

  @override
  void initState() {
    super.initState();
    _fetchModels();
    if (widget.itemToEdit != null) {
      _loadItemData();
    }
  }

  Future<void> _fetchModels() async {
    try {
      final res = await _client
          .from('inventory')
          .select('model')
          .not('model', 'is', null);
      final models =
          (res as List).map((e) => e['model'] as String).toSet().toList();
      setState(() => _existingModels = models);
    } catch (_) {}
  }

  void _loadItemData() {
    final item = widget.itemToEdit!;
    _nameController.text = item['name'] ?? '';
    _nameArController.text = item['name_ar'] ?? '';
    _barcodeController.text = item['barcode'] ?? '';
    _modelController.text = item['model'] ?? '';
    _serialController.text = item['serial_number'] ?? '';
    _costPriceController.text = (item['cost_price'] ?? 0).toString();
    _sellPriceController.text = (item['selling_price'] ?? 0).toString();
    _quantityController.text = (item['quantity'] ?? 0).toString();
    _notesController.text = item['notes'] ?? '';
    _itemType = item['item_type'] ?? 'accessory';
    _condition = item['condition'] ?? 'ممتاز';
    _selectedCategory = item['category'];
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_nameController.text.trim().isEmpty &&
        _nameArController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب كتابة الاسم (عربي أو إنجليزي) على الأقل'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _client.auth.currentUser;
      final staff = await _client
          .from('staff')
          .select('tenant_id')
          .eq('user_id', user!.id)
          .maybeSingle();
      final tenantId = staff?['tenant_id'];

      final data = {
        'tenant_id': tenantId,
        'name': _nameController.text.trim().isEmpty
            ? null
            : _nameController.text.trim(),
        'name_ar': _nameArController.text.trim().isEmpty
            ? null
            : _nameArController.text.trim(),
        'barcode': _barcodeController.text.trim().isEmpty
            ? null
            : _barcodeController.text.trim(),
        'model': _modelController.text.trim().isEmpty
            ? null
            : _modelController.text.trim(),
        'serial_number': _serialController.text.trim().isEmpty
            ? null
            : _serialController.text.trim(),
        'cost_price': double.tryParse(_costPriceController.text) ?? 0.0,
        'selling_price': double.tryParse(_sellPriceController.text) ?? 0.0,
        'quantity': int.tryParse(_quantityController.text) ?? 0,
        'notes': _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        'item_type': _itemType,
        'category': _itemType == 'accessory' ? _selectedCategory : null,
        'condition': _itemType == 'phone_used' ? _condition : null,
        'is_active': true,
        'is_shop_item': true, // ✅ مهم جداً: لضمان ظهوره في الكاشير فقط
      };

      if (widget.itemToEdit != null) {
        await _client
            .from('inventory')
            .update(data)
            .eq('id', widget.itemToEdit!['id']);
      } else {
        await _client.from('inventory').insert(data);
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
              widget.itemToEdit == null ? 'إضافة صنف جديد' : 'تعديل الصنف')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                    value: 'accessory',
                    label: Text('إكسسوار'),
                    icon: Icon(Icons.headphones)),
                ButtonSegment(
                    value: 'phone_new',
                    label: Text('هاتف جديد'),
                    icon: Icon(Icons.phone_iphone)),
                ButtonSegment(
                    value: 'phone_used',
                    label: Text('هاتف مستعمل'),
                    icon: Icon(Icons.phone_android)),
              ],
              selected: {_itemType},
              onSelectionChanged: (s) => setState(() => _itemType = s.first),
            ),
            if (_itemType == 'accessory') ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                    labelText: 'فئة الإكسسوار', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'جراب', child: Text('جراب')),
                  DropdownMenuItem(value: 'اسكرينة', child: Text('اسكرينة')),
                  DropdownMenuItem(value: 'سماعة', child: Text('سماعة')),
                  DropdownMenuItem(value: 'شاحن', child: Text('شاحن')),
                  DropdownMenuItem(value: 'كابل', child: Text('كابل')),
                  DropdownMenuItem(
                      value: 'باور بانك', child: Text('باور بانك')),
                  DropdownMenuItem(value: 'أخرى', child: Text('أخرى')),
                ],
                onChanged: (val) {
                  setState(() {
                    _selectedCategory = val;
                    // ✅ السحر هنا: بمجرد اختيار الفئة، يتم كتابة الاسم العربي تلقائياً إذا كان فارغاً
                    if (_nameArController.text.trim().isEmpty && val != null) {
                      _nameArController.text = val;
                    }
                  });
                },
                validator: (v) => v == null ? 'اختر الفئة' : null,
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                    labelText: 'الاسم (إنجليزي) - اختياري',
                    hintText: 'مثال: iPhone Charger')),
            const SizedBox(height: 12),
            TextFormField(
                controller: _nameArController,
                decoration: const InputDecoration(
                    labelText: 'الاسم (عربي) - اختياري',
                    hintText: 'مثال: شاحن آيفون')),
            const SizedBox(height: 12),
            Autocomplete<String>(
              optionsBuilder: (textEditingValue) {
                if (textEditingValue.text.isEmpty) return _existingModels;
                return _existingModels.where((m) => m
                    .toLowerCase()
                    .contains(textEditingValue.text.toLowerCase()));
              },
              onSelected: (val) => _modelController.text = val,
              fieldViewBuilder:
                  (context, controller, focusNode, onFieldSubmitted) {
                _modelController.text = controller.text;
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                      labelText: 'الموديل (اختياري)',
                      hintText: 'مثال: iPhone 13'),
                  onChanged: (v) => _modelController.text = v,
                );
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
                controller: _barcodeController,
                decoration:
                    const InputDecoration(labelText: 'الباركود (اختياري)')),
            const SizedBox(height: 12),
            if (_itemType == 'phone_new' || _itemType == 'phone_used') ...[
              TextFormField(
                  controller: _serialController,
                  decoration:
                      const InputDecoration(labelText: 'السيريال / IMEI')),
              const SizedBox(height: 12),
            ],
            if (_itemType == 'phone_used') ...[
              DropdownButtonFormField<String>(
                value: _condition,
                items: const [
                  DropdownMenuItem(value: 'ممتاز', child: Text('ممتاز')),
                  DropdownMenuItem(value: 'جيد جداً', child: Text('جيد جداً')),
                  DropdownMenuItem(value: 'جيد', child: Text('جيد')),
                  DropdownMenuItem(
                      value: 'يحتاج صيانة', child: Text('يحتاج صيانة')),
                ],
                onChanged: (v) => setState(() => _condition = v!),
                decoration: const InputDecoration(labelText: 'حالة الجهاز'),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                    child: TextFormField(
                        controller: _costPriceController,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'سعر الشراء'))),
                const SizedBox(width: 12),
                Expanded(
                    child: TextFormField(
                        controller: _sellPriceController,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'سعر البيع'))),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'الكمية المتاحة')),
            const SizedBox(height: 12),
            TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration:
                    const InputDecoration(labelText: 'ملاحظات (اختياري)')),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('حفظ الصنف', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
