// lib/core/services/supabase_service.dart

import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// ═══════════════════════════════════════════════════════════
/// SupabaseService — Wrapper للـ Supabase Client
/// ═══════════════════════════════════════════════════════════
///
/// - Singleton: instance واحد للتطبيق
/// - Provider: للاستخدام مع Riverpod
/// - Helpers: دوال مساعدة (اختياري)
///
class SupabaseService {
  // ─── Singleton ───
  SupabaseService._();
  static final SupabaseService _instance = SupabaseService._();
  static SupabaseService get instance => _instance;

  // ═══════════════════════════════════════════════════════════
  // Client Access
  // ═══════════════════════════════════════════════════════════

  /// Supabase Client (الوصول المباشر)
  SupabaseClient get client => Supabase.instance.client;

  /// Auth (للـ login/signup)
  GoTrueClient get auth => client.auth;

  /// Storage (للـ files)
  SupabaseStorageClient get storage => client.storage;

  /// Realtime (للـ subscriptions)
  RealtimeClient get realtime => client.realtime;

  // ═══════════════════════════════════════════════════════════
  // Auth Helpers
  // ═══════════════════════════════════════════════════════════

  /// المستخدم الحالي (null لو مش مسجّل)
  User? get currentUser => auth.currentUser;

  /// هل المستخدم مسجّل؟
  bool get isLoggedIn => currentUser != null;

  /// ID المستخدم الحالي
  String? get currentUserId => currentUser?.id;

  /// الإيميل
  String? get currentUserEmail => currentUser?.email;

  // ═══════════════════════════════════════════════════════════
  // Database Helpers
  // ═══════════════════════════════════════════════════════════

  /// الوصول لجدول
  ///
  /// مثال:
  /// ```dart
  /// final data = await supabaseService.from('receipts').select();
  /// ```
  PostgrestQueryBuilder from(String table) {
    return client.from(table);
  }

  /// استدعاء RPC Function
  ///
  /// مثال:
  /// ```dart
  /// final result = await supabaseService.rpc('my_function', params: {...});
  /// ```
  PostgrestFilterBuilder<dynamic> rpc(
    String fn, {
    Map<String, dynamic>? params,
  }) {
    return client.rpc(fn, params: params);
  }

  // ═══════════════════════════════════════════════════════════
  // Common Queries
  // ═══════════════════════════════════════════════════════════

  /// إرجاع كل الصفوف من جدول
  Future<List<Map<String, dynamic>>> getAll(
    String table, {
    String columns = '*',
    String? orderBy,
    bool ascending = true,
    int? limit,
    int? offset,
  }) async {
    // نبني الـ query خطوة بخطوة
    final builder = client.from(table).select(columns);

    // لو محتاجين ترتيب
    if (orderBy != null) {
      final ordered = builder.order(orderBy, ascending: ascending);
      // لو محتاجين limit أو offset
      if (limit != null) {
        final limited = ordered.limit(limit);
        if (offset != null) {
          final data = await limited.range(
            offset,
            offset + limit - 1,
          );
          return (data as List).cast<Map<String, dynamic>>();
        }
        final data = await limited;
        return (data as List).cast<Map<String, dynamic>>();
      }
      final data = await ordered;
      return (data as List).cast<Map<String, dynamic>>();
    }

    // بدون ترتيب
    if (limit != null) {
      final limited = builder.limit(limit);
      if (offset != null) {
        final data = await limited.range(
          offset,
          offset + limit - 1,
        );
        return (data as List).cast<Map<String, dynamic>>();
      }
      final data = await limited;
      return (data as List).cast<Map<String, dynamic>>();
    }

    final data = await builder;
    return (data as List).cast<Map<String, dynamic>>();
  }

  /// إرجاع صف واحد حسب id
  Future<Map<String, dynamic>?> getById(
    String table,
    String id, {
    String columns = '*',
  }) async {
    final data =
        await client.from(table).select(columns).eq('id', id).maybeSingle();
    return data;
  }

  /// إرجاع صف واحد حسب شرط
  Future<Map<String, dynamic>?> getOne(
    String table, {
    required String column,
    required dynamic value,
    String columns = '*',
  }) async {
    final data = await client
        .from(table)
        .select(columns)
        .eq(column, value)
        .maybeSingle();
    return data;
  }

  /// إدخال صف
  Future<Map<String, dynamic>> insert(
    String table,
    Map<String, dynamic> data,
  ) async {
    final result = await client.from(table).insert(data).select().single();
    return result;
  }

  /// إدخال عدة صفوف
  Future<List<Map<String, dynamic>>> insertMany(
    String table,
    List<Map<String, dynamic>> data,
  ) async {
    final result = await client.from(table).insert(data).select();
    return (result as List).cast<Map<String, dynamic>>();
  }

  /// تحديث صف
  Future<Map<String, dynamic>> update(
    String table,
    String id,
    Map<String, dynamic> data,
  ) async {
    final result =
        await client.from(table).update(data).eq('id', id).select().single();
    return result;
  }

  /// حذف صف
  Future<void> delete(String table, String id) async {
    await client.from(table).delete().eq('id', id);
  }

  /// عدّ الصفوف
  Future<int> count(
    String table, {
    String? column,
    dynamic value,
  }) async {
    var query = client.from(table).select('id');

    if (column != null && value != null) {
      query = query.eq(column, value);
    }

    final data = await query;
    return (data as List).length;
  }

  /// هل الصف موجود؟
  Future<bool> exists(
    String table, {
    required String column,
    required dynamic value,
  }) async {
    final data =
        await client.from(table).select('id').eq(column, value).limit(1);
    return (data as List).isNotEmpty;
  }

  // ═══════════════════════════════════════════════════════════
  // Storage Helpers
  // ═══════════════════════════════════════════════════════════

  /// رفع ملف
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required List<int> bytes,
    String? contentType,
  }) async {
    await storage.from(bucket).uploadBinary(
          path,
          bytes is Uint8List ? bytes : Uint8List.fromList(bytes),
          fileOptions: FileOptions(
            contentType: contentType,
            upsert: true,
          ),
        );
    return getPublicUrl(bucket: bucket, path: path);
  }

  /// إرجاع URL عام لملف
  String getPublicUrl({
    required String bucket,
    required String path,
  }) {
    return storage.from(bucket).getPublicUrl(path);
  }

  /// حذف ملف
  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    await storage.from(bucket).remove([path]);
  }

  /// إرجاع قائمة ملفات في مجلد
  Future<List<FileObject>> listFiles({
    required String bucket,
    String? folder,
  }) async {
    return await storage.from(bucket).list(path: folder);
  }

  // ═══════════════════════════════════════════════════════════
  // Realtime Helpers
  // ═══════════════════════════════════════════════════════════

  /// الاستماع لتغييرات جدول
  ///
  /// مثال:
  /// ```dart
  /// final stream = supabaseService.streamTable(
  ///   'receipts',
  ///   filter: 'tenant_id=eq.xxx',
  /// );
  /// stream.listen((data) { ... });
  /// ```
  Stream<List<Map<String, dynamic>>> streamTable(
    String table, {
    String? filter,
  }) {
    return client
        .from(table)
        .stream(primaryKey: ['id'])
        .eq('tenant_id', filter ?? '')
        .map((data) => data.cast<Map<String, dynamic>>());
  }

  // ═══════════════════════════════════════════════════════════
  // Error Handling
  // ═══════════════════════════════════════════════════════════

  /// تحويل خطأ Supabase لرسالة مفهومة
  String getErrorMessage(dynamic error) {
    if (error is AuthException) {
      return error.message;
    }
    if (error is PostgrestException) {
      return error.message;
    }
    if (error is StorageException) {
      return error.message;
    }
    return error.toString();
  }

  /// هل الخطأ "غير مصرح"؟
  bool isUnauthorized(dynamic error) {
    if (error is PostgrestException) {
      return error.code == '401' || error.code == 'PGRST301';
    }
    if (error is AuthException) {
      return error.statusCode == '401';
    }
    return false;
  }

  /// هل الخطأ "غير موجود"؟
  bool isNotFound(dynamic error) {
    if (error is PostgrestException) {
      return error.code == '404' || error.code == 'PGRST116';
    }
    return false;
  }

  // ═══════════════════════════════════════════════════════════
  // Utility
  // ═══════════════════════════════════════════════════════════

  /// انتظار الاتصال (للاختبار)
  Future<void> ping() async {
    await client.from('tenants').select('id').limit(1);
  }

  /// معلومات المشروع
  Map<String, dynamic> get projectInfo {
    return {
      'url': client.rest.url,
      'is_logged_in': isLoggedIn,
      'user_id': currentUserId,
    };
  }
}

// ═══════════════════════════════════════════════════════════
// Riverpod Provider
// ═══════════════════════════════════════════════════════════

/// Provider للـ SupabaseService
///
/// الاستخدام:
/// ```dart
/// final supabase = ref.watch(supabaseServiceProvider);
/// final data = await supabase.getAll('receipts');
/// ```
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService.instance;
});

/// Provider للـ SupabaseClient مباشرة
///
/// الاستخدام:
/// ```dart
/// final client = ref.watch(supabaseClientProvider);
/// final data = await client.from('receipts').select();
/// ```
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return SupabaseService.instance.client;
});

/// Provider للمستخدم الحالي
///
/// يتحدّث تلقائياً عند login/logout
final currentUserProvider = Provider<User?>((ref) {
  return SupabaseService.instance.currentUser;
});
