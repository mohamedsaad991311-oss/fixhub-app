// lib/core/services/auth_service.dart

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

/// ═══════════════════════════════════════════════════════════
/// AuthService — إدارة المصادقة
/// ═══════════════════════════════════════════════════════════
///
/// بيعتمد على SupabaseService للوصول لـ Supabase Auth.
///
/// المميزات:
/// - Sign Up / Sign In / Sign Out
/// - Reset Password
/// - Update Profile
/// - Stream لتغييرات Auth
///
class AuthService {
  AuthService(this._supabase);

  final SupabaseService _supabase;

  // ═══════════════════════════════════════════════════════════
  // Getters
  // ═══════════════════════════════════════════════════════════

  /// المستخدم الحالي
  User? get currentUser => _supabase.currentUser;

  /// الجلسة الحالية
  Session? get currentSession => _supabase.auth.currentSession;

  /// هل مسجّل دخول؟
  bool get isLoggedIn => _supabase.isLoggedIn;

  /// ID المستخدم
  String? get userId => _supabase.currentUserId;

  /// الإيميل
  String? get userEmail => _supabase.currentUserEmail;

  /// Stream لتغييرات Auth
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // ═══════════════════════════════════════════════════════════
  // Sign Up
  // ═══════════════════════════════════════════════════════════

  /// إنشاء حساب جديد
  ///
  /// Returns: `AuthResponse` لو نجح
  /// Throws: `AuthException` لو فشل
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
    String? phone,
    Map<String, dynamic>? metadata,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        if (fullName != null) 'full_name': fullName,
        if (phone != null) 'phone': phone,
        ...?metadata,
      },
    );
    return response;
  }

  // ═══════════════════════════════════════════════════════════
  // Sign In
  // ═══════════════════════════════════════════════════════════

  /// تسجيل دخول بالإيميل وكلمة المرور
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Sign Out
  // ═══════════════════════════════════════════════════════════

  /// تسجيل خروج
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// تسجيل خروج من كل الأجهزة
  Future<void> signOutAll() async {
    await _supabase.auth.signOut(scope: SignOutScope.global);
  }

  /// تسجيل خروج من الأجهزة التانية (ما عدا الحالي)
  Future<void> signOutOthers() async {
    await _supabase.auth.signOut(scope: SignOutScope.others);
  }

  // ═══════════════════════════════════════════════════════════
  // Password Reset
  // ═══════════════════════════════════════════════════════════

  /// إرسال إيميل لإعادة تعيين كلمة المرور
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(
      email.trim(),
      redirectTo: 'fixhub://reset-password',
    );
  }

  /// تغيير كلمة المرور (للمستخدم الحالي)
  Future<UserResponse> updatePassword(String newPassword) async {
    return await _supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // User Management
  // ═══════════════════════════════════════════════════════════

  /// تحديث بيانات المستخدم
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

  /// إرسال تحقق الإيميل
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

  /// إرسال OTP للتليفون
  Future<void> sendPhoneOtp(String phone) async {
    await _supabase.auth.signInWithOtp(phone: phone);
  }

  /// تحقق OTP للتليفون
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

  /// تحديث الجلسة الحالية
  Future<AuthResponse> refreshSession() async {
    return await _supabase.auth.refreshSession();
  }

  /// إرجاع Access Token
  String? get accessToken => currentSession?.accessToken;

  /// إرجاع Refresh Token
  String? get refreshToken => currentSession?.refreshToken;

  /// هل الجلسة منتهية؟
  bool get isSessionExpired {
    final session = currentSession;
    if (session == null) return true;
    final expiresAt = session.expiresAt;
    if (expiresAt == null) return false;
    return DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000)
        .isBefore(DateTime.now());
  }

  /// التأكد من إن الجلسة صالحة
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

  /// هل الإيميل مسجّل؟
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

  /// إرجاع بيانات المستخدم من staff
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

  /// إرجاع tenant_id للمستخدم الحالي
  Future<String?> getUserTenantId() async {
    if (!isLoggedIn) return null;
    try {
      final data = await _supabase.client
          .from('staff')
          .select('tenant_id')
          .eq('user_id', userId!)
          .maybeSingle();
      return data?['tenant_id'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// هل الإيميل موثّق؟
  bool get isEmailVerified => currentUser?.emailConfirmedAt != null;

  /// هل التليفون موثّق؟
  bool get isPhoneVerified => currentUser?.phoneConfirmedAt != null;
}

// ═══════════════════════════════════════════════════════════
// Riverpod Providers
// ═══════════════════════════════════════════════════════════

/// Provider للـ AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);
  return AuthService(supabase);
});

/// Provider لحالة المصادقة (Stream)
///
/// الاستخدام:
/// ```dart
/// final authState = ref.watch(authStateProvider);
/// authState.when(
///   data: (state) => ...,
///   loading: () => ...,
///   error: (e, st) => ...,
/// )
/// ```
final authStateProvider = StreamProvider<AuthState>((ref) {
  final auth = ref.watch(authServiceProvider);
  return auth.authStateChanges;
});

/// Provider للمستخدم الحالي (Stream)
final currentUserStreamProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(authServiceProvider);
  return auth.authStateChanges.map((state) => state.session?.user);
});

/// Provider لحالة تسجيل الدخول (bool)
final isLoggedInProvider = Provider<bool>((ref) {
  final auth = ref.watch(authServiceProvider);
  return auth.isLoggedIn;
});
