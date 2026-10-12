// lib/features/auth/presentation/providers/auth_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import '../../../../core/services/auth_service.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../../data/models/app_user.dart';
import '../../data/models/tenant.dart';
import '../services/session_manager.dart';

// ═══════════════════════════════════════════════════════════════
//  AUTH STATUS
// ═══════════════════════════════════════════════════════════════

enum AuthStatus { unknown, loading, authenticated, unauthenticated }

// ═══════════════════════════════════════════════════════════════
//  DEVICE BLOCKED INFO
// ═══════════════════════════════════════════════════════════════

class DeviceBlockedInfo {
  const DeviceBlockedInfo({
    this.blockedByName,
    this.blockedByPlatform,
    this.blockedByLastSeen,
  });

  factory DeviceBlockedInfo.fromCheck(DeviceCheckResult check) {
    return DeviceBlockedInfo(
      blockedByName: check.blockedByName,
      blockedByPlatform: check.blockedByPlatform,
      blockedByLastSeen: check.blockedByLastSeen,
    );
  }

  final String? blockedByName;
  final String? blockedByPlatform;
  final DateTime? blockedByLastSeen;

  String get description {
    final buffer = StringBuffer('الحساب نشط على جهاز آخر');
    if (blockedByName != null && blockedByName!.isNotEmpty) {
      buffer.write(': $blockedByName');
    }
    if (blockedByPlatform != null) {
      buffer.write(' (${blockedByPlatform!.toUpperCase()})');
    }
    return buffer.toString();
  }
}

// ═══════════════════════════════════════════════════════════════
//  AUTH STATE
// ═══════════════════════════════════════════════════════════════

class AuthState {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.tenant,
    this.errorMessage,
    this.lastSyncAt,
    this.deviceBlockedInfo,
  });

  final AuthStatus status;
  final AppUser? user;
  final Tenant? tenant;
  final String? errorMessage;
  final DateTime? lastSyncAt;
  final DeviceBlockedInfo? deviceBlockedInfo;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
  bool get isUnknown => status == AuthStatus.unknown;
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;
  bool get isDeviceBlocked => deviceBlockedInfo != null;
  bool get isOwner => user?.role == UserRole.owner;
  bool get isManagerOrOwner =>
      user?.role == UserRole.owner || user?.role == UserRole.manager;
  bool get isTechnician => user?.role == UserRole.technician;
  bool get isTenantActive => tenant?.isActive ?? false;

  bool get isSubscriptionExpired {
    final expires = tenant?.subscriptionExpiresAt;
    if (expires == null) return false;
    return DateTime.now().isAfter(expires);
  }

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
    DeviceBlockedInfo? deviceBlockedInfo,
    bool clearDeviceBlocked = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      tenant: clearTenant ? null : (tenant ?? this.tenant),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      deviceBlockedInfo: clearDeviceBlocked
          ? null
          : (deviceBlockedInfo ?? this.deviceBlockedInfo),
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
        other.errorMessage == errorMessage &&
        other.deviceBlockedInfo == deviceBlockedInfo;
  }

  @override
  int get hashCode =>
      Object.hash(status, user, tenant, errorMessage, deviceBlockedInfo);

  @override
  String toString() =>
      'AuthState(status: ${status.name}, user: ${user?.email}, tenant: ${tenant?.name})';
}

// ═══════════════════════════════════════════════════════════════
//  AUTH NOTIFIER
// ═══════════════════════════════════════════════════════════════

class AuthNotifier extends AsyncNotifier<AuthState> {
  AuthService get _auth => ref.read(authServiceProvider);

  @override
  Future<AuthState> build() async {
    final sub = _auth.authStateChanges.listen((event) {
      _handleAuthEvent(event);
    });
    ref.onDispose(sub.cancel);
    return await _loadCurrentSession();
  }

  // ─────────────────────────────────────────────────────────────
  //  LOAD
  // ─────────────────────────────────────────────────────────────

  Future<AuthState> _loadCurrentSession() async {
    try {
      if (!_auth.isLoggedIn) {
        debugPrint('⚪ [_loadCurrentSession] not logged in');
        return AuthState.unauthenticated;
      }

      debugPrint('🔵 [_loadCurrentSession] userId=${_auth.userId}');

      final user = await _fetchAppUser();
      if (user == null) {
        debugPrint('🟡 [_loadCurrentSession] user not found, ensuring staff');
        final created = await _ensureStaffRecord();
        if (created == null) {
          debugPrint('🔴 [_loadCurrentSession] staff creation failed');
          return AuthState.unauthenticated;
        }
        return await _loadCurrentSession();
      }

      final tenant = await _fetchTenant(user.tenantId);

      debugPrint(
          '🟢 [_loadCurrentSession] OK user=${user.email} tenant=${tenant?.name}');

      return AuthState(
        status: AuthStatus.authenticated,
        user: user,
        tenant: tenant,
        lastSyncAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('🔴 [_loadCurrentSession] error: $e');
      return AuthState.unauthenticated;
    }
  }

  void _handleAuthEvent(dynamic event) {
    try {
      final session = event.session as Session?;
      final eventType = event.event;

      debugPrint(
          '📡 [_handleAuthEvent] type=$eventType hasSession=${session != null}');

      if (session == null) {
        final oldState = state.valueOrNull;
        if (oldState?.isAuthenticated ?? false) {
          state = const AsyncData(AuthState.unauthenticated);
        }
        return;
      }

      if (eventType == AuthChangeEvent.tokenRefreshed) return;

      if (eventType == AuthChangeEvent.signedIn ||
          eventType == AuthChangeEvent.initialSession) {
        _reload();
      }
    } catch (e) {
      debugPrint('_handleAuthEvent error: $e');
    }
  }

  Future<void> _reload() async {
    final fresh = await _loadCurrentSession();
    state = AsyncData(fresh);
  }

  // ─────────────────────────────────────────────────────────────
  //  SIGN IN
  // ─────────────────────────────────────────────────────────────

  Future<bool> signIn({
    required String identifier,
    required String password,
  }) async {
    debugPrint('🔵 [signIn] START identifier=$identifier');
    state = const AsyncData(AuthState.loading);

    try {
      await _auth.signInWithIdentifier(
        identifier: identifier,
        password: password,
      );

      debugPrint('🟢 [signIn] Supabase returned success');

      // ═══ فحص الجهاز ═══
      final userId = _auth.currentUser?.id;
      if (userId != null) {
        final manager = ref.read(sessionManagerProvider);
        final deviceCheck = await manager.checkDeviceAllowed(userId: userId);

        if (!deviceCheck.isAllowed) {
          await _auth.signOut();
          state = AsyncData(
            AuthState(
              status: AuthStatus.unauthenticated,
              errorMessage:
                  'الحساب مرتبط بجهاز آخر. تواصل مع مدير الورشة لإعادة التعيين.',
              deviceBlockedInfo: DeviceBlockedInfo.fromCheck(deviceCheck),
            ),
          );
          return false;
        }
      }

      // ═══ تحميل البيانات ═══
      final fresh = await _loadCurrentSession();

      debugPrint('🟢 [signIn] fresh.isAuthenticated=${fresh.isAuthenticated}');

      // ═══ سجّل الجهاز ═══
      if (fresh.isAuthenticated && fresh.user != null && fresh.tenant != null) {
        try {
          final manager = ref.read(sessionManagerProvider);
          await manager.registerDevice(
            userId: fresh.user!.userId,
            tenantId: fresh.tenant!.id,
          );
        } catch (_) {}
      }

      state = AsyncData(fresh);
      return fresh.isAuthenticated;
    } on AuthException catch (e) {
      debugPrint('🔴 [signIn] AuthException: ${e.message}');
      state = AsyncData(
        AuthState(
          status: AuthStatus.unauthenticated,
          errorMessage: _translateAuthError(e.message),
        ),
      );
      return false;
    } catch (e) {
      debugPrint('🔴 [signIn] Generic error: $e');
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

  Future<bool> signUp({
    required String phone,
    required String password,
    required String fullName,
    String? email,
    String? tenantName,
    bool createTenant = false,
  }) async {
    debugPrint('🔵 [signUp] START phone=$phone');
    state = const AsyncData(AuthState.loading);

    try {
      await _auth.signUpWithPhone(
        phone: phone,
        password: password,
        fullName: fullName,
        realEmail: email,
        metadata: {
          if (createTenant) 'create_tenant': true,
          if (tenantName != null) 'tenant_name': tenantName,
        },
      );

      debugPrint(
          '🟢 [signUp] Supabase signUp done, isLoggedIn=${_auth.isLoggedIn}');

      if (!_auth.isLoggedIn) {
        state = const AsyncData(
          AuthState(
            status: AuthStatus.unauthenticated,
            errorMessage: 'تم إنشاء الحساب. راجع بياناتك لتأكيد الدخول.',
          ),
        );
        return false;
      }

      final staffCreated = await _ensureStaffRecord(
        createTenant: createTenant,
        tenantName: tenantName,
        fullName: fullName,
        phone: phone,
        realEmail: email,
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

      if (fresh.isAuthenticated && fresh.user != null && fresh.tenant != null) {
        try {
          final manager = ref.read(sessionManagerProvider);
          await manager.registerDevice(
            userId: fresh.user!.userId,
            tenantId: fresh.tenant!.id,
          );
        } catch (_) {}
      }

      state = AsyncData(fresh);
      return fresh.isAuthenticated;
    } on AuthException catch (e) {
      debugPrint('🔴 [signUp] AuthException: ${e.message}');
      state = AsyncData(
        AuthState(
          status: AuthStatus.unauthenticated,
          errorMessage: _translateAuthError(e.message),
        ),
      );
      return false;
    } catch (e) {
      debugPrint('🔴 [signUp] Generic error: $e');
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
      ref.read(settingsServiceProvider).clearCache();
      state = const AsyncData(AuthState.unauthenticated);
    } catch (e) {
      debugPrint('signOut error: $e');
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
      debugPrint('resetPassword error: $e');
      return false;
    }
  }

  Future<bool> updatePassword(String newPassword) async {
    try {
      await _auth.updatePassword(newPassword);
      return true;
    } catch (e) {
      debugPrint('updatePassword error: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  PROFILE
  // ─────────────────────────────────────────────────────────────

  Future<bool> updateProfile({
    String? fullName,
    String? phone,
    String? email,
    String? avatarUrl,
  }) async {
    final current = state.valueOrNull;
    if (current?.user == null) return false;

    try {
      await _auth.updateProfile(
        fullName: fullName,
        phone: phone,
        email: email,
        avatarUrl: avatarUrl,
      );

      final client = ref.read(supabaseClientProvider);
      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (phone != null) updates['phone'] = phone;
      if (email != null) updates['email'] = email;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      if (updates.isNotEmpty) {
        await client
            .from('staff')
            .update(updates)
            .eq('user_id', current!.user!.id);
      }

      final updatedUser = current!.user!.copyWith(
        fullName: fullName,
        phone: phone,
        avatarUrl: avatarUrl,
      );
      state = AsyncData(current.copyWith(user: updatedUser));
      return true;
    } catch (e) {
      debugPrint('updateProfile error: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  REFRESH
  // ─────────────────────────────────────────────────────────────

  Future<void> refresh() async {
    state = const AsyncData(AuthState.loading);
    final fresh = await _loadCurrentSession();
    state = AsyncData(fresh);
  }

  void clearError() {
    final current = state.valueOrNull;
    if (current == null) return;
    state =
        AsyncData(current.copyWith(clearError: true, clearDeviceBlocked: true));
  }

  // ─────────────────────────────────────────────────────────────
  //  INTERNAL
  // ─────────────────────────────────────────────────────────────

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
      debugPrint('_fetchAppUser error: $e');
      return null;
    }
  }

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
      debugPrint('_fetchTenant error: $e');
      return null;
    }
  }

  Future<AppUser?> _ensureStaffRecord({
    bool createTenant = false,
    String? tenantName,
    String? fullName,
    String? phone,
    String? realEmail,
    UserRole role = UserRole.technician,
  }) async {
    try {
      final client = ref.read(supabaseClientProvider);
      final userId = _auth.userId!;
      final authEmail = _auth.userEmail ?? '';

      final staffEmail = (realEmail != null && realEmail.isNotEmpty)
          ? realEmail.trim().toLowerCase()
          : authEmail;

      String? tenantId;

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

      final staffPayload = {
        'user_id': userId,
        'email': staffEmail,
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
      debugPrint('_ensureStaffRecord error: $e');
      return null;
    }
  }

  String _translateAuthError(String? message) {
    if (message == null) return 'حدث خطأ غير متوقع';
    final msg = message.toLowerCase();
    if (msg.contains('invalid login')) {
      return 'الرقم/الإيميل أو كلمة المرور غير صحيحة';
    }
    if (msg.contains('email not confirmed')) {
      return 'الحساب غير مؤكد. تواصل مع الدعم.';
    }
    if (msg.contains('user already registered') ||
        msg.contains('already been registered')) {
      return 'الحساب مسجّل بالفعل';
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

final authProvider =
    AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

final currentAppUserProvider = Provider<AppUser?>((ref) {
  return ref.watch(authProvider).valueOrNull?.user;
});

final currentTenantProvider = Provider<Tenant?>((ref) {
  return ref.watch(authProvider).valueOrNull?.tenant;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).valueOrNull?.isAuthenticated ?? false;
});

final userRoleProvider = Provider<UserRole?>((ref) {
  return ref.watch(authProvider).valueOrNull?.user?.role;
});

final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).valueOrNull?.isLoading ?? false;
});

final isOwnerProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).valueOrNull?.isOwner ?? false;
});

final isManagerOrOwnerProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).valueOrNull?.isManagerOrOwner ?? false;
});

final isDeviceBlockedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).valueOrNull?.isDeviceBlocked ?? false;
});

final deviceBlockedInfoProvider = Provider<DeviceBlockedInfo?>((ref) {
  return ref.watch(authProvider).valueOrNull?.deviceBlockedInfo;
});
