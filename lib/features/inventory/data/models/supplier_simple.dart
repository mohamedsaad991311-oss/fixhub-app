import 'package:flutter/foundation.dart'; 
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import '../../../../core/services/supabase_service.dart'; 
 
class SimpleSupplier { 
  final String id; 
  final String name; 
  SimpleSupplier({required this.id, required this.name}); 
  factory SimpleSupplier.fromJson(Map<String, dynamic> json) { 
    return SimpleSupplier( 
      id: json['id'].toString(), 
      name: json['name'] as String? ?? 'بدون اسم', 
    ); 
  } 
} 
 
final suppliersProvider = FutureProvider<List<SimpleSupplier>>((ref) async { 
  final client = ref.watch(supabaseClientProvider); 
  try { 
    final data = await client.from('الموردون').select('id, name'); 
    return (data as List).map((e) => SimpleSupplier.fromJson(e)).toList(); 
  } catch (e) { 
    if (kDebugMode) print('Error fetching suppliers: $e'); 
    return []; 
  } 
}); 
