// lib/core/services/auth_service.dart

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

/// ═══════════════════════════════════════════════════════════
/// AuthService — إدارة المصادقة
/// ═══════════════════════════════════════════════════════════
class AuthService {
  AuthService(this._supabase);

  final SupabaseService _supabase;

  /// دومين داخلي للإيميلات المولّدة من الأرقام
  static const String _phoneEmailDomain = 'fixhub.app';

  // ═══════════════════════════════════════════════════════════
  // Getters
  // ═══════════════════════════════════════════════════════════

  User? get currentUser => _supabase.currentUser;
  Session? get currentSession => _supabase.auth.currentSession;
  bool get isLoggedIn => _supabase.isLoggedIn;
  String? get userId => _supabase.currentUserId;
  String? get userEmail => _supabase.currentUserEmail;
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // ═══════════════════════════════════════════════════════════
  // Identifier Detection
  // ═══════════════════════════════════════════════════════════

  /// هل النص إيميل؟
  bool isEmail(String input) => input.contains('@');

  /// هل النص رقم تليفون؟
  bool isPhone(String input) {
    if (isEmail(input)) return false;
    final cleaned = input.replaceAll(RegExp(r'[\s\-()]'), '');
    return RegExp(r'^[\+]?\d{8,15}$').hasMatch(cleaned);
  }

  /// تطبيع رقم التليفون
  String normalizePhone(String phone) {
    var cleaned = phone.replaceAll(RegExp(r'[\s\-()]'), '');

    if (cleaned.startsWith('+')) return cleaned;
    if (cleaned.startsWith('00')) return '+${cleaned.substring(2)}';

    // مصري بدون كود: 01012345678 → +201012345678
    if (cleaned.startsWith('0') && cleaned.length == 11) {
      return '+20${cleaned.substring(1)}';
    }

    // مصري بدون صفر: 1012345678 → +201012345678
    if (cleaned.length == 10 && cleaned.startsWith('1')) {
      return '+20$cleaned';
    }

    return '+$cleaned';
  }

  /// تحويل رقم التليفون لإيميل داخلي
  String phoneToAuthEmail(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    return '$digits@$_phoneEmailDomain';
  }

  /// هل الإيميل ده مولّد من رقم؟
  bool isPhoneAuthEmail(String email) {
    return email.endsWith('@$_phoneEmailDomain');
  }

  // ═══════════════════════════════════════════════════════════
  // Identifier Resolution — إيميل أو تليفون
  // ═══════════════════════════════════════════════════════════

  /// تحويل identifier (إيميل أو تليفون) إلى email للـ Supabase Auth
  Future<String> resolveIdentifier(String identifier) async {
    final trimmed = identifier.trim();

    // 1. إيميل → يرجّعه
    if (isEmail(trimmed)) {
      return trimmed.toLowerCase();
    }

    // 2. تليفون → ابحث في staff عبر RPC (آمن + بيتخطى RLS)
    if (isPhone(trimmed)) {
      final normalized = normalizePhone(trimmed);
      debugPrint(
          '🔍 [resolveIdentifier] trimmed="$trimmed" normalized="$normalized"');

      try {
        final data = await _supabase.client.rpc(
          'lookup_staff_by_phone',
          params: {'p_phone': normalized},
        );

        final dataList = data as List;

        debugPrint(
            '🔍 [resolveIdentifier] RPC returned ${dataList.length} rows');

        if (dataList.isEmpty) {
          debugPrint('🔴 [resolveIdentifier] NO ROW FOUND');
          throw const AuthException(
            'رقم التليفون غير مسجّل. جرب الإيميل أو سجّل حساب جديد.',
          );
        }

        final row = dataList.first as Map<String, dynamic>;
        final email = row['email'] as String?;

        if (email == null || email.isEmpty) {
          return phoneToAuthEmail(normalized);
        }

        return email.toLowerCase();
      } catch (e) {
        if (e is AuthException) rethrow;
        debugPrint('🔴 [resolveIdentifier] RPC error: $e');
        throw const AuthException(
          'تعذّر البحث برقم التليفون. جرب الإيميل.',
        );
      }
    }

    // 3. غير معروف
    throw const AuthException('أدخل بريد إلكتروني صحيح أو رقم تليفون.');
  }

  // ═══════════════════════════════════════════════════════════
  // Sign Up
  // ═══════════════════════════════════════════════════════════

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
    String? phone,
    Map<String, dynamic>? metadata,
  }) async {
    return await _supabase.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        if (fullName != null) 'full_name': fullName,
        if (phone != null) 'phone': phone,
        ...?metadata,
      },
    );
  }

  Future<AuthResponse> signUpWithPhone({
    required String phone,
    required String password,
    String? fullName,
    String? realEmail,
    Map<String, dynamic>? metadata,
  }) async {
    final normalized = normalizePhone(phone);
    final authEmail = phoneToAuthEmail(normalized);

    return await _supabase.auth.signUp(
      email: authEmail,
      password: password,
      data: {
        'phone': normalized,
        if (fullName != null) 'full_name': fullName,
        if (realEmail != null) 'real_email': realEmail,
        ...?metadata,
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Sign In
  // ═══════════════════════════════════════════════════════════

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<AuthResponse> signInWithPhone({
    required String phone,
    required String password,
  }) async {
    final email = await resolveIdentifier(phone);
    return await signIn(email: email, password: password);
  }

  Future<AuthResponse> signInWithIdentifier({
    required String identifier,
    required String password,
  }) async {
    final email = await resolveIdentifier(identifier);
    return await signIn(email: email, password: password);
  }

  // ═══════════════════════════════════════════════════════════
  // Sign Out
  // ═══════════════════════════════════════════════════════════

  Future<void> signOut() async {
    debugPrint('🛑 [AuthService.signOut] called!');
    debugPrint('📍 Stack trace:');
    debugPrint(StackTrace.current.toString());
    await _supabase.auth.signOut();
  }

  Future<void> signOutAll() async {
    await _supabase.auth.signOut(scope: SignOutScope.global);
  }

  Future<void> signOutOthers() async {
    await _supabase.auth.signOut(scope: SignOutScope.others);
  }

  // ═══════════════════════════════════════════════════════════
  // Password Reset
  // ═══════════════════════════════════════════════════════════

  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(
      email.trim(),
      redirectTo: 'fixhub://reset-password',
    );
  }

  Future<UserResponse> updatePassword(String newPassword) async {
    return await _supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // User Management
  // ═══════════════════════════════════════════════════════════

  Future<UserResponse> updateProfile({
    String? email,
    String? phone,
    String? fullName,
    String? avatarUrl,
    Map<String, dynamic>? metadata,
  }) async {
    return await _supabase.auth.updateUser(
      UserAttributes(
        email: email,
        phone: phone,
        data: {
          if (fullName != null) 'full_name': fullName,
          if (avatarUrl != null) 'avatar_url': avatarUrl,
          ...?metadata,
        },
      ),
    );
  }

  Future<void> sendEmailVerification() async {
    final email = userEmail;
    if (email == null) {
      throw const AuthException('لا يوجد إيميل للمستخدم الحالي');
    }
    await _supabase.auth.resend(
      type: OtpType.signup,
      email: email,
    );
  }

  Future<void> sendPhoneOtp(String phone) async {
    await _supabase.auth.signInWithOtp(phone: phone);
  }

  Future<AuthResponse> verifyPhoneOtp({
    required String phone,
    required String token,
  }) async {
    return await _supabase.auth.verifyOTP(
      type: OtpType.sms,
      phone: phone,
      token: token,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Session Management
  // ═══════════════════════════════════════════════════════════

  Future<AuthResponse> refreshSession() async {
    return await _supabase.auth.refreshSession();
  }

  String? get accessToken => currentSession?.accessToken;
  String? get refreshToken => currentSession?.refreshToken;

  bool get isSessionExpired {
    final session = currentSession;
    if (session == null) return true;
    final expiresAt = session.expiresAt;
    if (expiresAt == null) return false;
    final expiryDate = DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
    final isExpired = expiryDate.isBefore(DateTime.now());
    debugPrint(
        '⏰ [isSessionExpired] expiresAt=$expiresAt expiry=$expiryDate now=${DateTime.now()} isExpired=$isExpired');
    return isExpired;
  }

  Future<bool> ensureValidSession() async {
    if (!isLoggedIn) return false;
    if (!isSessionExpired) return true;

    try {
      await refreshSession();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // Helpers
  // ═══════════════════════════════════════════════════════════

  Future<bool> isEmailRegistered(String email) async {
    try {
      final data = await _supabase.client
          .from('staff')
          .select('id')
          .eq('email', email.trim())
          .limit(1);
      return (data as List).isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// هل الرقم مسجّل؟ (عبر RPC)
  Future<bool> isPhoneRegistered(String phone) async {
    try {
      final normalized = normalizePhone(phone);
      final data = await _supabase.client.rpc(
        'lookup_staff_by_phone',
        params: {'p_phone': normalized},
      );
      return (data as List).isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    if (!isLoggedIn) return null;
    try {
      return await _supabase.client
          .from('staff')
          .select()
          .eq('user_id', userId!)
          .maybeSingle();
    } catch (_) {
      return null;
    }
  }

  Future<String?> getUserTenantId() async {
    debugPrint('🔍 [getUserTenantId] isLoggedIn=$isLoggedIn userId=$userId');
    if (!isLoggedIn) {
      debugPrint('🔴 [getUserTenantId] NOT logged in');
      return null;
    }
    try {
      final data = await _supabase.client
          .from('staff')
          .select('tenant_id')
          .eq('user_id', userId!)
          .maybeSingle();
      debugPrint('🔍 [getUserTenantId] data=$data');
      return data?['tenant_id'] as String?;
    } catch (e) {
      debugPrint('🔴 [getUserTenantId] error: $e');
      return null;
    }
  }

  bool get isEmailVerified => currentUser?.emailConfirmedAt != null;
  bool get isPhoneVerified => currentUser?.phoneConfirmedAt != null;
}

// ═══════════════════════════════════════════════════════════
// Riverpod Providers
// ═══════════════════════════════════════════════════════════

final authServiceProvider = Provider<AuthService>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);
  return AuthService(supabase);
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  final auth = ref.watch(authServiceProvider);
  return auth.authStateChanges;
});

final currentUserStreamProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(authServiceProvider);
  return auth.authStateChanges.map((state) => state.session?.user);
});

final isLoggedInProvider = Provider<bool>((ref) {
  final auth = ref.watch(authServiceProvider);
  return auth.isLoggedIn;
});
