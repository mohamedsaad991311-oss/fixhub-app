// lib/features/auth/presentation/providers/auth_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import '../../../../core/services/auth_service.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../../data/models/app_user.dart';
import '../../data/models/tenant.dart';

enum AuthStatus {
  /// لسه بنتحقق من الجلسة
  unknown,

  /// جاري عملية (sign in/up/out)
  loading,

  /// مسجّل دخول بنجاح
  authenticated,

  /// غير مسجّل
  unauthenticated,
}

// ═══════════════════════════════════════════════════════════════
//  AUTH STATE — الحالة الكاملة
// ═══════════════════════════════════════════════════════════════

class AuthState {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.tenant,
    this.errorMessage,
    this.lastSyncAt,
  });

  final AuthStatus status;
  final AppUser? user;
  final Tenant? tenant;
  final String? errorMessage;
  final DateTime? lastSyncAt;

  // ─── Getters ───

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
  bool get isUnknown => status == AuthStatus.unknown;
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  /// هل المستخدم owner؟
  bool get isOwner => user?.role == UserRole.owner;

  /// هل مدير أو مالك؟
  bool get isManagerOrOwner =>
      user?.role == UserRole.owner || user?.role == UserRole.manager;

  /// هل فني؟
  bool get isTechnician => user?.role == UserRole.technician;

  /// هل الورشة فعّالة؟
  bool get isTenantActive => tenant?.isActive ?? false;

  /// هل الاشتراك منتهي؟
  bool get isSubscriptionExpired {
    final expires = tenant?.subscriptionExpiresAt;
    if (expires == null) return false;
    return DateTime.now().isAfter(expires);
  }

  /// رقم أيام الاشتراك المتبقية
  int? get subscriptionDaysLeft {
    final expires = tenant?.subscriptionExpiresAt;
    if (expires == null) return null;
    final diff = expires.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    bool clearUser = false,
    Tenant? tenant,
    bool clearTenant = false,
    String? errorMessage,
    bool clearError = false,
    DateTime? lastSyncAt,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      tenant: clearTenant ? null : (tenant ?? this.tenant),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }

  static const AuthState initial = AuthState();
  static const AuthState unauthenticated =
      AuthState(status: AuthStatus.unauthenticated);
  static const AuthState loading = AuthState(status: AuthStatus.loading);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.status == status &&
        other.user == user &&
        other.tenant == tenant &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hash(status, user, tenant, errorMessage);

  @override
  String toString() =>
      'AuthState(status: ${status.name}, user: ${user?.email}, tenant: ${tenant?.name})';
}

// ═══════════════════════════════════════════════════════════════
//  AUTH NOTIFIER — إدارة الحالة
// ═══════════════════════════════════════════════════════════════

class AuthNotifier extends AsyncNotifier<AuthState> {
  AuthService get _auth => ref.read(authServiceProvider);

  @override
  Future<AuthState> build() async {
    // مراقبة authStateChanges
    final sub = _auth.authStateChanges.listen((event) {
      _handleAuthEvent(event);
    });
    ref.onDispose(sub.cancel);

    // حالة أولية
    return await _loadCurrentSession();
  }

  // ─────────────────────────────────────────────────────────────
  //  LOAD
  // ─────────────────────────────────────────────────────────────

  /// تحميل الجلسة الحالية (user + tenant)
  Future<AuthState> _loadCurrentSession() async {
    try {
      if (!_auth.isLoggedIn) {
        return AuthState.unauthenticated;
      }

      final user = await _fetchAppUser();
      if (user == null) {
        // موجود في auth بس مش في staff → أنشئه
        final created = await _ensureStaffRecord();
        if (created == null) return AuthState.unauthenticated;
        return await _loadCurrentSession();
      }

      final tenant = await _fetchTenant(user.tenantId);

      return AuthState(
        status: AuthStatus.authenticated,
        user: user,
        tenant: tenant,
        lastSyncAt: DateTime.now(),
      );
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('AuthNotifier._loadCurrentSession error: $e');
      }
      return AuthState.unauthenticated;
    }
  }

  /// معالج تغييرات auth من Supabase
  void _handleAuthEvent(dynamic event) {
    try {
      // event من نوع AuthState (Supabase) — بنوصلها كـ dynamic
      final session = event.session as Session?;
      final eventType = event.event;

      if (session == null) {
        // تسجيل خروج
        final oldState = state.valueOrNull;
        if (oldState?.isAuthenticated ?? false) {
          state = const AsyncData(AuthState.unauthenticated);
        }
        return;
      }

      // تغيير في التوكن (auto-refresh) — ما نعملش حاجة
      if (eventType == AuthChangeEvent.tokenRefreshed) return;

      // sign in جديد
      if (eventType == AuthChangeEvent.signedIn ||
          eventType == AuthChangeEvent.initialSession) {
        _reload();
      }
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('_handleAuthEvent error: $e');
      }
    }
  }

  /// إعادة تحميل الحالة
  Future<void> _reload() async {
    final fresh = await _loadCurrentSession();
    state = AsyncData(fresh);
  }

  // ─────────────────────────────────────────────────────────────
  //  SIGN IN
  // ─────────────────────────────────────────────────────────────

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncData(AuthState.loading);
    try {
      await _auth.signIn(email: email, password: password);
      final fresh = await _loadCurrentSession();
      state = AsyncData(fresh);
      return fresh.isAuthenticated;
    } on AuthException catch (e) {
      state = AsyncData(
        AuthState(
          status: AuthStatus.unauthenticated,
          errorMessage: _translateAuthError(e.message),
        ),
      );
      return false;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('signIn error: $e');
      }
      state = const AsyncData(
        AuthState(
          status: AuthStatus.unauthenticated,
          errorMessage: 'حدث خطأ غير متوقع. حاول مرة أخرى.',
        ),
      );
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  SIGN UP
  // ─────────────────────────────────────────────────────────────

  /// إنشاء حساب جديد
  ///
  /// - لو [createTenant] == true → ينشئ tenant + staff (owner)
  /// - لو false → ينشئ staff فقط (بانتظار دعوة من مالك)
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String? tenantName,
    bool createTenant = false,
  }) async {
    state = const AsyncData(AuthState.loading);
    try {
      await _auth.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        metadata: {
          if (createTenant) 'create_tenant': true,
          if (tenantName != null) 'tenant_name': tenantName,
        },
      );

      // بعد signUp، Supabase بيعمل session تلقائي (لو Email confirmation معطّل)
      if (!_auth.isLoggedIn) {
        // محتاج تأكيد إيميل
        state = const AsyncData(
          AuthState(
            status: AuthStatus.unauthenticated,
            errorMessage: 'تم إنشاء الحساب. راجع إيميلك للتأكيد.',
          ),
        );
        return false;
      }

      // أنشئ staff record (والـ tenant لو مطلوب)
      final staffCreated = await _ensureStaffRecord(
        createTenant: createTenant,
        tenantName: tenantName,
        fullName: fullName,
        phone: phone,
        role: createTenant ? UserRole.owner : UserRole.technician,
      );

      if (staffCreated == null) {
        state = const AsyncData(
          AuthState(
            status: AuthStatus.unauthenticated,
            errorMessage: 'فشل إنشاء ملف المستخدم',
          ),
        );
        return false;
      }

      final fresh = await _loadCurrentSession();
      state = AsyncData(fresh);
      return fresh.isAuthenticated;
    } on AuthException catch (e) {
      state = AsyncData(
        AuthState(
          status: AuthStatus.unauthenticated,
          errorMessage: _translateAuthError(e.message),
        ),
      );
      return false;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('signUp error: $e');
      }
      state = const AsyncData(
        AuthState(
          status: AuthStatus.unauthenticated,
          errorMessage: 'فشل إنشاء الحساب. حاول مرة أخرى.',
        ),
      );
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  SIGN OUT
  // ─────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    state = const AsyncData(AuthState.loading);
    try {
      await _auth.signOut();
      // امسح cache الإعدادات
      ref.read(settingsServiceProvider).clearCache();
      state = const AsyncData(AuthState.unauthenticated);
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('signOut error: $e');
      }
      state = const AsyncData(AuthState.unauthenticated);
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  PASSWORD RESET
  // ─────────────────────────────────────────────────────────────

  Future<bool> resetPassword(String email) async {
    try {
      await _auth.resetPassword(email);
      return true;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('resetPassword error: $e');
      }
      return false;
    }
  }

  Future<bool> updatePassword(String newPassword) async {
    try {
      await _auth.updatePassword(newPassword);
      return true;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('updatePassword error: $e');
      }
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  PROFILE
  // ─────────────────────────────────────────────────────────────

  /// تحديث بيانات المستخدم (fullName, phone, avatar)
  Future<bool> updateProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    final current = state.valueOrNull;
    if (current?.user == null) return false;

    try {
      // 1. حدّث Supabase Auth
      await _auth.updateProfile(
        fullName: fullName,
        phone: phone,
        avatarUrl: avatarUrl,
      );

      // 2. حدّث جدول staff
      final client = ref.read(supabaseClientProvider);
      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (phone != null) updates['phone'] = phone;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      if (updates.isNotEmpty) {
        await client
            .from('staff')
            .update(updates)
            .eq('user_id', current!.user!.id);
      }

      // 3. حدّث الحالة
      final updatedUser = current!.user!.copyWith(
        fullName: fullName,
        phone: phone,
        avatarUrl: avatarUrl,
      );
      state = AsyncData(current.copyWith(user: updatedUser));
      return true;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('updateProfile error: $e');
      }
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  REFRESH
  // ─────────────────────────────────────────────────────────────

  /// إعادة تحميل الحالة من Supabase
  Future<void> refresh() async {
    state = const AsyncData(AuthState.loading);
    final fresh = await _loadCurrentSession();
    state = AsyncData(fresh);
  }

  /// مسح الخطأ
  void clearError() {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(clearError: true));
  }

  // ─────────────────────────────────────────────────────────────
  //  INTERNAL — fetch & ensure
  // ─────────────────────────────────────────────────────────────

  /// جلب بيانات المستخدم من جدول staff
  Future<AppUser?> _fetchAppUser() async {
    try {
      final client = ref.read(supabaseClientProvider);
      final data = await client
          .from('staff')
          .select()
          .eq('user_id', _auth.userId!)
          .maybeSingle();
      if (data == null) return null;
      return AppUser.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('_fetchAppUser error: $e');
      }
      return null;
    }
  }

  /// جلب بيانات الورشة
  Future<Tenant?> _fetchTenant(String? tenantId) async {
    if (tenantId == null || tenantId.isEmpty) return null;
    try {
      final client = ref.read(supabaseClientProvider);
      final data = await client
          .from('tenants')
          .select()
          .eq('id', tenantId)
          .maybeSingle();
      if (data == null) return null;
      return Tenant.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('_fetchTenant error: $e');
      }
      return null;
    }
  }

  /// إنشاء tenant + staff record (لو مش موجود)
  Future<AppUser?> _ensureStaffRecord({
    bool createTenant = false,
    String? tenantName,
    String? fullName,
    String? phone,
    UserRole role = UserRole.technician,
  }) async {
    try {
      final client = ref.read(supabaseClientProvider);
      final userId = _auth.userId!;
      final userEmail = _auth.userEmail ?? '';

      String? tenantId;

      // 1. أنشئ tenant لو مطلوب
      if (createTenant) {
        final tenantPayload = {
          'name': (tenantName ?? 'ورشتك').trim(),
          'owner_id': userId,
          'currency': 'EGP',
          'timezone': 'Africa/Cairo',
          'subscription_plan': SubscriptionPlan.free.name,
          'is_active': true,
        };
        final tenantData = await client
            .from('tenants')
            .insert(tenantPayload)
            .select('id')
            .single();
        tenantId = tenantData['id'] as String?;
      }

      // 2. أنشئ staff record
      final staffPayload = {
        'user_id': userId,
        'email': userEmail,
        if (fullName != null) 'full_name': fullName,
        if (phone != null) 'phone': phone,
        'role': role.name,
        if (tenantId != null) 'tenant_id': tenantId,
        'is_active': true,
      };

      final staffData =
          await client.from('staff').insert(staffPayload).select().single();

      return AppUser.fromJson(Map<String, dynamic>.from(staffData));
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('_ensureStaffRecord error: $e');
      }
      return null;
    }
  }

  /// ترجمة أخطاء Supabase Auth للعربي
  String _translateAuthError(String? message) {
    if (message == null) return 'حدث خطأ غير متوقع';
    final msg = message.toLowerCase();
    if (msg.contains('invalid login')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    }
    if (msg.contains('email not confirmed')) {
      return 'البريد الإلكتروني غير مؤكد. راجع إيميلك.';
    }
    if (msg.contains('user already registered') ||
        msg.contains('already been registered')) {
      return 'البريد الإلكتروني مسجّل بالفعل';
    }
    if (msg.contains('password should be')) {
      return 'كلمة المرور ضعيفة (6 أحرف على الأقل)';
    }
    if (msg.contains('unable to validate email')) {
      return 'صيغة البريد الإلكتروني غير صحيحة';
    }
    if (msg.contains('rate limit')) {
      return 'عدد المحاولات كبير. حاول بعد قليل.';
    }
    if (msg.contains('network')) {
      return 'تحقق من اتصال الإنترنت';
    }
    return message;
  }
}

// ═══════════════════════════════════════════════════════════════
//  RIVERPOD PROVIDERS
// ═══════════════════════════════════════════════════════════════

/// الـ provider الرئيسي لحالة المصادقة
final authProvider =
    AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

// ─── Convenience providers (اختصارات) ───

/// المستخدم الحالي (AppUser)
final currentAppUserProvider = Provider<AppUser?>((ref) {
  return ref.watch(authProvider).valueOrNull?.user;
});

/// الورشة الحالية (Tenant)
final currentTenantProvider = Provider<Tenant?>((ref) {
  return ref.watch(authProvider).valueOrNull?.tenant;
});

/// هل مسجّل دخول؟
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).valueOrNull?.isAuthenticated ?? false;
});

/// دور المستخدم
final userRoleProvider = Provider<UserRole?>((ref) {
  return ref.watch(authProvider).valueOrNull?.user?.role;
});

/// حالة التحميل
final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).valueOrNull?.isLoading ?? false;
});

/// هل المستخدم owner؟
final isOwnerProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).valueOrNull?.isOwner ?? false;
});

/// هل مدير أو owner؟
final isManagerOrOwnerProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).valueOrNull?.isManagerOrOwner ?? false;
});
