import 'package:supabase_flutter/supabase_flutter.dart';

class SalesService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<Map<String, dynamic>> createSaleInvoice({
    required String tenantId,
    required List<Map<String, dynamic>> items,
    required double paidAmount,
    String? customerName,
  }) async {
    // ✅ إرسال الأصناف كمصفوفة (مش String) عشان Supabase يقرأها كـ JSONB
    final res = await _client.rpc('rpc_create_sale_invoice', params: {
      'p_tenant_id': tenantId,
      'p_items': items, 
      'p_paid_amount': paidAmount,
      'p_customer_name': (customerName == null || customerName.isEmpty) ? null : customerName,
    });
    
    return (res as Map).cast<String, dynamic>();
  }
}