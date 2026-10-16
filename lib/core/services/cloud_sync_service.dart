// lib/core/services/cloud_sync_service.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_service.dart';
import 'storage_service.dart';
import 'supabase_service.dart';

/// ═══════════════════════════════════════════════════════════════
/// BACKUP FILE — بيانات ملف نسخة احتياطية
/// ═══════════════════════════════════════════════════════════════

class BackupFile {
  const BackupFile({
    required this.name,
    required this.path,
    required this.createdAt,
    required this.sizeBytes,
  });

  final String name;
  final String path;
  final DateTime createdAt;
  final int sizeBytes;

  /// الحجم بصيغة مقروءة (KB / MB)
  String get sizeFormatted {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}

/// ═══════════════════════════════════════════════════════════════
/// BACKUP RESULT — نتيجة العملية
/// ═══════════════════════════════════════════════════════════════

class BackupResult {
  const BackupResult({
    required this.success,
    this.file,
    this.error,
  });

  final bool success;
  final BackupFile? file;
  final String? error;

  factory BackupResult.failure(String error) =>
      BackupResult(success: false, error: error);
}

/// ═══════════════════════════════════════════════════════════════
/// CLOUD SYNC SERVICE
/// ═══════════════════════════════════════════════════════════════
///
/// الوظائف:
/// - إنشاء نسخة احتياطية (JSON) من 15 جدول
/// - رفعها إلى bucket `backups` في Supabase Storage
/// - عرض/تحميل/حذف النسخ
/// - استرجاع من نسخة (خطر — مع تأكيد)
/// - نسخة محلية على الجهاز
///
class CloudSyncService {
  CloudSyncService({
    required SupabaseClient client,
    required AuthService authService,
    required StorageService storageService,
  })  : _client = client,
        _authService = authService,
        _storage = storageService;

  final SupabaseClient _client;
  final AuthService _authService;
  final StorageService _storage;

  /// أسماء الجداول الـ 15
  static const List<String> _tables = [
    'tenants',
    'staff',
    'suppliers',
    'inventory',
    'receipts',
    'receipt_status_history',
    'tracking_tokens',
    'supplier_invoices',
    'supplier_payments',
    'supplier_returns',
    'expenses',
    'inventory_movements',
    'activity_log',
    'settings',
    'active_devices',
  ];

  static const String _backupVersion = '1.0';
  static const int _maxBackupBytes = 100 * 1024 * 1024; // 100 MB

  // ═══════════════════════════════════════════════════════════════
  //  CREATE BACKUP
  // ═══════════════════════════════════════════════════════════════

  /// إنشاء نسخة احتياطية شاملة ورفعها إلى Supabase Storage
  Future<BackupResult> createBackup() async {
    try {
      final tenantId = await _authService.getUserTenantId();
      if (tenantId == null) {
        return BackupResult.failure('لا يوجد مستخدم مسجل');
      }

      final tablesData = await _collectAllTables(tenantId);

      final backup = <String, dynamic>{
        'version': _backupVersion,
        'exported_at': DateTime.now().toIso8601String(),
        'tenant_id': tenantId,
        'tables': tablesData,
      };

      final jsonStr = jsonEncode(backup);
      final bytes = Uint8List.fromList(utf8.encode(jsonStr));

      if (bytes.length > _maxBackupBytes) {
        final mb = (bytes.length / (1024 * 1024)).toStringAsFixed(1);
        return BackupResult.failure(
          'حجم النسخة ($mb MB) يتجاوز الحد الأقصى (100 MB)',
        );
      }

      final now = DateTime.now();
      final fileName =
          'fixhub_backup_${now.year}${_pad(now.month)}${_pad(now.day)}_'
          '${_pad(now.hour)}${_pad(now.minute)}${_pad(now.second)}.json';

      final result = await _storage.uploadBackup(
        tenantId: tenantId,
        fileName: fileName,
        bytes: bytes,
      );

      if (!result.success || result.path == null) {
        return BackupResult.failure(result.error ?? 'فشل الرفع');
      }

      final file = BackupFile(
        name: fileName,
        path: result.path!,
        createdAt: now,
        sizeBytes: bytes.length,
      );

      return BackupResult(success: true, file: file);
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('CloudSyncService.createBackup error: $e');
      }
      return BackupResult.failure('حدث خطأ أثناء إنشاء النسخة: $e');
    }
  }

  /// جمع بيانات كل الجداول (15 جدول)
  Future<Map<String, List<Map<String, dynamic>>>> _collectAllTables(
    String tenantId,
  ) async {
    final result = <String, List<Map<String, dynamic>>>{};

    for (final table in _tables) {
      try {
        final data = table == 'tenants'
            ? await _client.from(table).select().eq('id', tenantId)
            : await _client.from(table).select();

        result[table] = (data as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      } catch (e) {
        if (kDebugMode) {
          // ignore: avoid_print
          print('Collect table "$table" error: $e');
        }
        result[table] = [];
      }
    }

    return result;
  }

  // ═══════════════════════════════════════════════════════════════
  //  LIST BACKUPS
  // ═══════════════════════════════════════════════════════════════

  /// عرض كل النسخ الاحتياطية في bucket `backups`
  Future<List<BackupFile>> listCloudBackups() async {
    try {
      // ✅ الإصلاح: استخدم getUserTenantId بدل getTenantFolder
      final tenantId = await _authService.getUserTenantId();
      if (tenantId == null || tenantId.isEmpty) return const [];

      final files = await _storage.listFiles(
        bucket: StorageBucket.backups,
        folder: tenantId,
        limit: 100,
      );

      // فلترة JSON فقط + تجاهل المجلدات
      final backups = <BackupFile>[];

      for (final f in files) {
        if (!f.name.toLowerCase().endsWith('.json')) continue;

        // ✅ الإصلاح: تحويل آمن للتاريخ
        final createdAt = _parseDateTime(f.createdAt) ??
            _parseDateTime(f.updatedAt) ??
            DateTime.now();

        final sizeBytes = ((f.metadata?['size'] as num?)?.toInt()) ?? 0;

        backups.add(BackupFile(
          name: f.name,
          path: '$tenantId/${f.name}',
          createdAt: createdAt,
          sizeBytes: sizeBytes,
        ));
      }

      backups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return backups;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('CloudSyncService.listCloudBackups error: $e');
      }
      return const [];
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  DOWNLOAD BACKUP
  // ═══════════════════════════════════════════════════════════════

  Future<Uint8List?> downloadBackup(String path) async {
    try {
      final data =
          await _client.storage.from(StorageBucket.backups.name).download(path);
      return data;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('CloudSyncService.downloadBackup error: $e');
      }
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  DELETE BACKUP
  // ═══════════════════════════════════════════════════════════════

  Future<bool> deleteCloudBackup(String path) async {
    return _storage.deleteFile(
      bucket: StorageBucket.backups,
      path: path,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  RESTORE BACKUP
  // ═══════════════════════════════════════════════════════════════

  /// استرجاع نسخة (يستبدل البيانات الحالية بـ upsert)
  Future<BackupResult> restoreBackup(String path) async {
    try {
      final bytes = await downloadBackup(path);
      if (bytes == null) {
        return BackupResult.failure('فشل تحميل النسخة');
      }

      final jsonStr = utf8.decode(bytes);
      final backup = jsonDecode(jsonStr) as Map<String, dynamic>;

      final version = backup['version'] as String?;
      if (version == null || !version.startsWith('1.')) {
        return BackupResult.failure('إصدار النسخة غير مدعوم: $version');
      }

      final tables = backup['tables'] as Map<String, dynamic>?;
      if (tables == null) {
        return BackupResult.failure('النسخة تالفة (لا توجد جداول)');
      }

      for (final table in _tables) {
        final rows = tables[table] as List?;
        if (rows == null || rows.isEmpty) continue;

        try {
          final rowsList =
              rows.map((e) => Map<String, dynamic>.from(e as Map)).toList();

          await _client.from(table).upsert(rowsList);
        } catch (e) {
          if (kDebugMode) {
            // ignore: avoid_print
            print('Restore table "$table" error: $e');
          }
        }
      }

      return BackupResult(success: true);
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('CloudSyncService.restoreBackup error: $e');
      }
      return BackupResult.failure('حدث خطأ أثناء الاسترجاع: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  LOCAL BACKUP
  // ═══════════════════════════════════════════════════════════════

  Future<File?> createLocalBackup() async {
    try {
      final tenantId = await _authService.getUserTenantId();
      if (tenantId == null) return null;

      final tablesData = await _collectAllTables(tenantId);

      final backup = <String, dynamic>{
        'version': _backupVersion,
        'exported_at': DateTime.now().toIso8601String(),
        'tenant_id': tenantId,
        'tables': tablesData,
      };

      final jsonStr = jsonEncode(backup);

      final dir = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${dir.path}/fixhub_backups');
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      final now = DateTime.now();
      final fileName =
          'fixhub_local_${now.year}${_pad(now.month)}${_pad(now.day)}_'
          '${_pad(now.hour)}${_pad(now.minute)}${_pad(now.second)}.json';

      final file = File('${backupDir.path}/$fileName');
      await file.writeAsString(jsonStr);

      return file;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('CloudSyncService.createLocalBackup error: $e');
      }
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  HELPERS
  // ═══════════════════════════════════════════════════════════════

  /// ✅ إصلاح: تحويل آمن لأي قيمة تاريخ (String / DateTime / null)
  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}

// ═══════════════════════════════════════════════════════════════
//  RIVERPOD PROVIDER
// ═══════════════════════════════════════════════════════════════

final cloudSyncServiceProvider = Provider<CloudSyncService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final authService = ref.watch(authServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  return CloudSyncService(
    client: client,
    authService: authService,
    storageService: storageService,
  );
});
