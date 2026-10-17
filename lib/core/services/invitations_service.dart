// lib/core/services/invitations_service.dart

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/invitations/data/models/invitation.dart';
import 'auth_service.dart';
import 'supabase_service.dart';

// ═══════════════════════════════════════════════════════════════
//  نتيجة الدعوة المفصّلة
// ═══════════════════════════════════════════════════════════════

class InvitationDetails {
  const InvitationDetails({
    required this.id,
    required this.tenantId,
    required this.tenantName,
    required this.invitedBy,
    required this.role,
    required this.status,
    required this.expiresAt,
    required this.createdAt,
    this.inviterName,
    this.email,
    this.phone,
    this.fullName,
  });

  final String id;
  final String tenantId;
  final String tenantName;
  final String invitedBy;
  final String role;
  final String status;
  final DateTime expiresAt;
  final DateTime createdAt;
  final String? inviterName;
  final String? email;
  final String? phone;
  final String? fullName;

  bool get isUsable =>
      status == 'pending' && DateTime.now().isBefore(expiresAt);

  factory InvitationDetails.fromJson(Map<String, dynamic> json) {
    return InvitationDetails(
      id: json['id'] as String? ?? '',
      tenantId: json['tenant_id'] as String? ?? '',
      tenantName: json['tenant_name'] as String? ?? 'ورشتك',
      invitedBy: json['invited_by'] as String? ?? '',
      role: json['role'] as String? ?? 'technician',
      status: json['status'] as String? ?? 'pending',
      expiresAt: _parseDate(json['expires_at']) ?? DateTime.now(),
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      inviterName: json['inviter_name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      fullName: json['full_name'] as String?,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

// ═══════════════════════════════════════════════════════════════
//  نتيجة عملية القبول
// ═══════════════════════════════════════════════════════════════

class AcceptInvitationResult {
  const AcceptInvitationResult({
    required this.success,
    this.tenantId,
    this.role,
    this.error,
  });

  final bool success;
  final String? tenantId;
  final String? role;
  final String? error;

  String get errorMessageAr {
    switch (error) {
      case 'not_authenticated':
        return 'يجب تسجيل الدخول أولاً';
      case 'invitation_not_found':
        return 'الدعوة غير موجودة أو تم استخدامها';
      case 'invitation_expired':
        return 'انتهت صلاحية الدعوة';
      case 'already_in_another_tenant':
        return 'أنت مسجل بالفعل في ورشة أخرى';
      default:
        return 'حدث خطأ غير متوقع';
    }
  }

  factory AcceptInvitationResult.fromJson(Map<String, dynamic> json) {
    return AcceptInvitationResult(
      success: json['success'] as bool? ?? false,
      tenantId: json['tenant_id'] as String?,
      role: json['role'] as String?,
      error: json['error'] as String?,
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  خدمة الدعوات
// ═══════════════════════════════════════════════════════════════

class InvitationsService {
  InvitationsService({
    required SupabaseClient client,
    required AuthService authService,
  })  : _client = client,
        _authService = authService;

  final SupabaseClient _client;
  final AuthService _authService;

  static const String _table = 'invitations';

  /// مدة صلاحية الدعوة (افتراضياً)
  static const Duration _defaultExpiry = Duration(days: 7);

  // ─────────────────────────────────────────────────────────────
  //  قراءة
  // ─────────────────────────────────────────────────────────────

  /// جلب كل دعوات الورشة
  Future<List<Invitation>> list({
    String? status,
    int limit = 100,
  }) async {
    try {
      final tenantId = await _authService.getUserTenantId();
      if (tenantId == null) return const [];

      var query = _client.from(_table).select().eq('tenant_id', tenantId);

      if (status != null) {
        query = query.eq('status', status);
      }

      final data =
          await query.order('created_at', ascending: false).limit(limit);

      return (data as List)
          .map((e) => Invitation.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('InvitationsService.list error: $e');
      }
      return const [];
    }
  }

  /// عدد الدعوات المعلقة
  Future<int> countPending() async {
    try {
      final tenantId = await _authService.getUserTenantId();
      if (tenantId == null) return 0;

      final data = await _client
          .from(_table)
          .select('id')
          .eq('tenant_id', tenantId)
          .eq('status', 'pending');

      return (data as List).length;
    } catch (_) {
      return 0;
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  إنشاء
  // ─────────────────────────────────────────────────────────────

  /// إنشاء دعوة جديدة
  Future<Invitation?> create({
    required String role,
    String? email,
    String? phone,
    String? fullName,
    Duration? expiresIn,
  }) async {
    try {
      // تحقق من وجود email أو phone
      if ((email == null || email.isEmpty) &&
          (phone == null || phone.isEmpty)) {
        return null;
      }

      final tenantId = await _authService.getUserTenantId();
      final invitedBy = _authService.currentUser?.id;
      if (tenantId == null || invitedBy == null) return null;

      // توليد token فريد
      final token = _generateToken();
      final expiresAt = DateTime.now().add(expiresIn ?? _defaultExpiry);

      final payload = {
        'tenant_id': tenantId,
        'invited_by': invitedBy,
        'role': role,
        'token': token,
        'status': 'pending',
        'expires_at': expiresAt.toIso8601String(),
        if (email != null && email.isNotEmpty)
          'email': email.trim().toLowerCase(),
        if (phone != null && phone.isNotEmpty) 'phone': phone.trim(),
        if (fullName != null && fullName.isNotEmpty)
          'full_name': fullName.trim(),
      };

      final inserted =
          await _client.from(_table).insert(payload).select().single();

      return Invitation.fromJson(
        Map<String, dynamic>.from(inserted),
      );
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('InvitationsService.create error: $e');
      }
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  إلغاء / حذف
  // ─────────────────────────────────────────────────────────────

  /// إلغاء دعوة (status → cancelled)
  Future<bool> cancel(String invitationId) async {
    try {
      final userId = _authService.currentUser?.id;
      await _client.from(_table).update({
        'status': 'cancelled',
        'cancelled_at': DateTime.now().toIso8601String(),
        'cancelled_by': userId,
      }).eq('id', invitationId);
      return true;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('InvitationsService.cancel error: $e');
      }
      return false;
    }
  }

  /// حذف دعوة نهائياً
  Future<bool> delete(String invitationId) async {
    try {
      await _client.from(_table).delete().eq('id', invitationId);
      return true;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('InvitationsService.delete error: $e');
      }
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  جلب بواسطة Token (RPC)
  // ─────────────────────────────────────────────────────────────

  /// جلب تفاصيل دعوة بواسطة token
  Future<InvitationDetails?> getByToken(String token) async {
    try {
      final result = await _client.rpc(
        'get_invitation_by_token',
        params: {'p_token': token},
      );

      if (result == null) return null;

      final data =
          (result is List && result.isNotEmpty) ? result.first : result;

      if (data == null) return null;

      return InvitationDetails.fromJson(
        Map<String, dynamic>.from(data as Map),
      );
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('InvitationsService.getByToken error: $e');
      }
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  قبول الدعوة (RPC)
  // ─────────────────────────────────────────────────────────────

  /// قبول الدعوة (يجب أن يكون المستخدم مسجل دخول)
  Future<AcceptInvitationResult> accept(String token) async {
    try {
      final result = await _client.rpc(
        'accept_invitation',
        params: {'p_token': token},
      );

      if (result == null) {
        return const AcceptInvitationResult(
          success: false,
          error: 'unknown',
        );
      }

      return AcceptInvitationResult.fromJson(
        Map<String, dynamic>.from(result as Map),
      );
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('InvitationsService.accept error: $e');
      }
      return const AcceptInvitationResult(
        success: false,
        error: 'unknown',
      );
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  توليد token
  // ─────────────────────────────────────────────────────────────

  /// توليد token عشوائي آمن (32 حرف)
  String _generateToken() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();
    return List.generate(32, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  /// توليد رابط دعوة للويب
  String buildInviteLink(String token) {
    return 'https://fixhub.app/invite/$token';
  }
}

// ═══════════════════════════════════════════════════════════════
//  مزوّد Riverpod
// ═══════════════════════════════════════════════════════════════

final invitationsServiceProvider = Provider<InvitationsService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final authService = ref.watch(authServiceProvider);
  return InvitationsService(
    client: client,
    authService: authService,
  );
});
