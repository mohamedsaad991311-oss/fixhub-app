import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_service.dart';
import 'supabase_service.dart';

// ═══════════════════════════════════════════════════════════════
//  STORAGE BUCKETS
// ═══════════════════════════════════════════════════════════════

/// الـ Buckets المتاحة في Supabase Storage
///
/// - Public buckets: روابط مباشرة (avatars, logos, receipts)
/// - Private buckets: روابط موقّعة مؤقتة (invoices, expenses, backups)
enum StorageBucket {
  avatars('avatars', isPublic: true),
  logos('logos', isPublic: true),
  receipts('receipts', isPublic: true),
  invoices('invoices', isPublic: false),
  expenses('expenses', isPublic: false),
  backups('backups', isPublic: false);

  const StorageBucket(this.name, {required this.isPublic});

  final String name;
  final bool isPublic;

  /// أقصى حجم مسموح (بالبايت)
  int get maxSizeBytes {
    switch (this) {
      case StorageBucket.avatars:
      case StorageBucket.logos:
        return 2 * 1024 * 1024; // 2 MB
      case StorageBucket.receipts:
      case StorageBucket.expenses:
        return 5 * 1024 * 1024; // 5 MB
      case StorageBucket.invoices:
        return 10 * 1024 * 1024; // 10 MB
      case StorageBucket.backups:
        return 100 * 1024 * 1024; // 100 MB
    }
  }

  /// الامتدادات المسموحة
  List<String> get allowedExtensions {
    switch (this) {
      case StorageBucket.avatars:
      case StorageBucket.logos:
        return ['jpg', 'jpeg', 'png', 'webp'];
      case StorageBucket.receipts:
      case StorageBucket.expenses:
        return ['jpg', 'jpeg', 'png', 'webp', 'pdf'];
      case StorageBucket.invoices:
        return ['jpg', 'jpeg', 'png', 'pdf'];
      case StorageBucket.backups:
        return ['json', 'zip', 'sql'];
    }
  }
}

// ═══════════════════════════════════════════════════════════════
//  STORAGE RESULT
// ═══════════════════════════════════════════════════════════════

/// نتيجة عملية رفع ملف
class StorageResult {
  const StorageResult({
    required this.success,
    this.path,
    this.publicUrl,
    this.error,
  });

  final bool success;
  final String? path;
  final String? publicUrl;
  final String? error;

  factory StorageResult.failure(String error) =>
      StorageResult(success: false, error: error);

  @override
  String toString() => success
      ? 'StorageResult(success, path: $path)'
      : 'StorageResult(failure, error: $error)';
}

// ═══════════════════════════════════════════════════════════════
//  STORAGE SERVICE
// ═══════════════════════════════════════════════════════════════

class StorageService {
  StorageService({
    required SupabaseClient client,
    required AuthService authService,
  })  : _client = client,
        _authService = authService;

  final SupabaseClient _client;
  final AuthService _authService;

  // ─────────────────────────────────────────────────────────────
  //  CORE UPLOAD
  // ─────────────────────────────────────────────────────────────

  /// رفع ملف عام (يُستخدم داخلياً + متاح للخارج)
  ///
  /// [bucket] الـ Bucket المستهدف
  /// [file] الملف (File) — للـ mobile/desktop
  /// [bytes] البيانات الخام — للـ web
  /// [fileName] اسم الملف الأصلي (لاستخراج الامتداد)
  /// [folder] مجلد فرعي داخل الـ bucket (اختياري)
  Future<StorageResult> uploadFile({
    required StorageBucket bucket,
    required String fileName,
    File? file,
    Uint8List? bytes,
    String? folder,
    bool upsert = false,
  }) async {
    try {
      // 1. التحقق من المدخلات
      if (file == null && bytes == null) {
        return StorageResult.failure('لا يوجد ملف للرفع');
      }

      // 2. التحقق من الامتداد
      final ext = _extractExtension(fileName);
      if (!bucket.allowedExtensions.contains(ext)) {
        return StorageResult.failure(
          'الامتداد .$ext غير مسموح. المسموح: ${bucket.allowedExtensions.join(", ")}',
        );
      }

      // 3. التحقق من الحجم
      final size = file != null ? await file.length() : bytes!.length;
      if (size > bucket.maxSizeBytes) {
        final maxMb = (bucket.maxSizeBytes / (1024 * 1024)).toStringAsFixed(0);
        return StorageResult.failure(
            'حجم الملف يتجاوز الحد المسموح ($maxMb MB)');
      }

      // 4. توليد المسار
      final path = await _generatePath(
        bucket: bucket,
        fileName: fileName,
        folder: folder,
      );

      // 5. الرفع
      final uploadData = file ?? bytes!;
      await _client.storage.from(bucket.name).upload(
            path,
            uploadData,
            fileOptions: FileOptions(
              contentType: _mimeType(ext),
              upsert: upsert,
            ),
          );

      // 6. الحصول على الرابط
      final url = bucket.isPublic
          ? _client.storage.from(bucket.name).getPublicUrl(path)
          : null;

      return StorageResult(
        success: true,
        path: path,
        publicUrl: url,
      );
    } on StorageException catch (e) {
      return StorageResult.failure('فشل الرفع: ${e.message}');
    } catch (e) {
      return StorageResult.failure('خطأ غير متوقع: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  CONVENIENCE METHODS
  // ─────────────────────────────────────────────────────────────

  /// رفع صورة شخصية
  Future<StorageResult> uploadAvatar({
    required String userId,
    required String fileName,
    File? file,
    Uint8List? bytes,
  }) =>
      uploadFile(
        bucket: StorageBucket.avatars,
        fileName: fileName,
        file: file,
        bytes: bytes,
        folder: userId,
        upsert: true,
      );

  /// رفع شعار الورشة
  Future<StorageResult> uploadLogo({
    required String tenantId,
    required String fileName,
    File? file,
    Uint8List? bytes,
  }) =>
      uploadFile(
        bucket: StorageBucket.logos,
        fileName: fileName,
        file: file,
        bytes: bytes,
        folder: tenantId,
        upsert: true,
      );

  /// رفع صورة جهاز (Receipt)
  Future<StorageResult> uploadReceiptImage({
    required String receiptId,
    required String fileName,
    File? file,
    Uint8List? bytes,
  }) =>
      uploadFile(
        bucket: StorageBucket.receipts,
        fileName: fileName,
        file: file,
        bytes: bytes,
        folder: receiptId,
      );

  /// رفع فاتورة مورد (private)
  Future<StorageResult> uploadInvoice({
    required String supplierId,
    required String fileName,
    File? file,
    Uint8List? bytes,
  }) =>
      uploadFile(
        bucket: StorageBucket.invoices,
        fileName: fileName,
        file: file,
        bytes: bytes,
        folder: supplierId,
      );

  /// رفع إيصال مصروف (private)
  Future<StorageResult> uploadExpenseReceipt({
    required String expenseId,
    required String fileName,
    File? file,
    Uint8List? bytes,
  }) =>
      uploadFile(
        bucket: StorageBucket.expenses,
        fileName: fileName,
        file: file,
        bytes: bytes,
        folder: expenseId,
      );

  /// رفع نسخة احتياطية (private)
  Future<StorageResult> uploadBackup({
    required String tenantId,
    required String fileName,
    File? file,
    Uint8List? bytes,
  }) =>
      uploadFile(
        bucket: StorageBucket.backups,
        fileName: fileName,
        file: file,
        bytes: bytes,
        folder: tenantId,
      );

  // ─────────────────────────────────────────────────────────────
  //  DELETE
  // ─────────────────────────────────────────────────────────────

  /// حذف ملف واحد
  Future<bool> deleteFile({
    required StorageBucket bucket,
    required String path,
  }) async {
    try {
      await _client.storage.from(bucket.name).remove([path]);
      return true;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('deleteFile error: $e');
      }
      return false;
    }
  }

  /// حذف مجموعة ملفات
  Future<bool> deleteFiles({
    required StorageBucket bucket,
    required List<String> paths,
  }) async {
    if (paths.isEmpty) return true;
    try {
      await _client.storage.from(bucket.name).remove(paths);
      return true;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('deleteFiles error: $e');
      }
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  URLS
  // ─────────────────────────────────────────────────────────────

  /// رابط عام مباشر (للـ public buckets فقط)
  String? getPublicUrl({
    required StorageBucket bucket,
    required String path,
  }) {
    if (!bucket.isPublic) return null;
    return _client.storage.from(bucket.name).getPublicUrl(path);
  }

  /// رابط موقّع مؤقت (للـ private buckets)
  ///
  /// [expiresIn] بالثواني — الافتراضي ساعة
  Future<String?> getSignedUrl({
    required StorageBucket bucket,
    required String path,
    int expiresIn = 3600,
  }) async {
    try {
      return await _client.storage.from(bucket.name).createSignedUrl(
            path,
            expiresIn,
          );
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('getSignedUrl error: $e');
      }
      return null;
    }
  }

  /// روابط موقّعة متعددة دفعة واحدة
  Future<List<String>> getSignedUrls({
    required StorageBucket bucket,
    required List<String> paths,
    int expiresIn = 3600,
  }) async {
    if (paths.isEmpty) return [];
    try {
      final results = await _client.storage
          .from(bucket.name)
          .createSignedUrlsResult(paths, expiresIn);

      // نستخرج الـ URLs من الـ SignedUrlSuccess فقط
      return results
          .whereType<SignedUrlSuccess>()
          .map((e) => e.signedUrl)
          .toList(growable: false);
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('getSignedUrls error: $e');
      }
      return [];
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  LIST / INFO
  // ─────────────────────────────────────────────────────────────

  /// عرض محتوى bucket (مجلد معين أو الجذر)
  Future<List<FileObject>> listFiles({
    required StorageBucket bucket,
    String? folder,
    int limit = 100,
  }) async {
    try {
      return await _client.storage.from(bucket.name).list(
            path: folder,
            searchOptions: SearchOptions(limit: limit),
          );
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('listFiles error: $e');
      }
      return const [];
    }
  }

  /// التحقق من وجود ملف
  Future<bool> fileExists({
    required StorageBucket bucket,
    required String path,
  }) async {
    try {
      final folder = _parentFolder(path);
      final name = _fileName(path);
      final files = await _client.storage.from(bucket.name).list(path: folder);
      return files.any((f) => f.name == name);
    } catch (_) {
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  HELPERS
  // ─────────────────────────────────────────────────────────────

  /// توليد مسار منظّم: {tenantId}/{userId}/{folder}/{timestamp}_{filename}
  Future<String> _generatePath({
    required StorageBucket bucket,
    required String fileName,
    String? folder,
  }) async {
    final userId = _authService.currentUser?.id ?? 'anonymous';
    final tenantId = await _authService.getUserTenantId() ?? 'no-tenant';

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final safeName = _sanitizeFileName(fileName);

    final segments = <String>[tenantId, userId];
    if (folder != null && folder.trim().isNotEmpty) {
      segments.add(folder.trim());
    }
    segments.add('${timestamp}_$safeName');

    return segments.join('/');
  }

  /// استخراج الامتداد (lowercase بدون نقطة)
  String _extractExtension(String fileName) {
    final idx = fileName.lastIndexOf('.');
    if (idx == -1 || idx == fileName.length - 1) return '';
    return fileName.substring(idx + 1).toLowerCase();
  }

  /// تنظيف اسم الملف من الرموز الخطيرة
  String _sanitizeFileName(String name) {
    final ext = _extractExtension(name);
    var base =
        ext.isEmpty ? name : name.substring(0, name.length - ext.length - 1);
    base = base.replaceAll(RegExp(r'[^\w\u0600-\u06FF\-]+'), '_');
    if (base.length > 60) base = base.substring(0, 60);
    return ext.isEmpty ? base : '$base.$ext';
  }

  /// MIME type حسب الامتداد
  String _mimeType(String ext) {
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      case 'json':
        return 'application/json';
      case 'zip':
        return 'application/zip';
      case 'sql':
        return 'application/sql';
      default:
        return 'application/octet-stream';
    }
  }

  String _parentFolder(String path) {
    final idx = path.lastIndexOf('/');
    return idx == -1 ? '' : path.substring(0, idx);
  }

  String _fileName(String path) {
    final idx = path.lastIndexOf('/');
    return idx == -1 ? path : path.substring(idx + 1);
  }
}

// ═══════════════════════════════════════════════════════════════
//  RIVERPOD PROVIDERS
// ═══════════════════════════════════════════════════════════════

final storageServiceProvider = Provider<StorageService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final authService = ref.watch(authServiceProvider);
  return StorageService(client: client, authService: authService);
});
