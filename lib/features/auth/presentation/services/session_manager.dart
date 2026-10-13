// lib/features/auth/presentation/services/session_manager.dart

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/auth_service.dart';
import '../../../../core/services/device_info_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../providers/auth_provider.dart';

// ═══════════════════════════════════════════════════════════════
//  SESSION CONFIG
// ═══════════════════════════════════════════════════════════════

class SessionConfig {
  const SessionConfig({
    this.refreshInterval = const Duration(minutes: 5),
    this.expiryThreshold = const Duration(minutes: 2),
    this.idleTimeout = Duration.zero, // 0 = disabled
    this.autoSignOutOnExpiry = true,
  });

  final Duration refreshInterval;
  final Duration expiryThreshold;
  final Duration idleTimeout;
  final bool autoSignOutOnExpiry;

  SessionConfig copyWith({
    Duration? refreshInterval,
    Duration? expiryThreshold,
    Duration? idleTimeout,
    bool? autoSignOutOnExpiry,
  }) {
    return SessionConfig(
      refreshInterval: refreshInterval ?? this.refreshInterval,
      expiryThreshold: expiryThreshold ?? this.expiryThreshold,
      idleTimeout: idleTimeout ?? this.idleTimeout,
      autoSignOutOnExpiry: autoSignOutOnExpiry ?? this.autoSignOutOnExpiry,
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SESSION MANAGER
// ═══════════════════════════════════════════════════════════════

class SessionManager {
  SessionManager({
    required AuthService authService,
    required Ref ref,
    SessionConfig config = const SessionConfig(),
  })  : _auth = authService,
        _ref = ref,
        _config = config;

  final AuthService _auth;
  final Ref _ref;
  SessionConfig _config;

  Timer? _refreshTimer;
  Timer? _idleTimer;
  DateTime? _lastActivity;
  bool _isRunning = false;
  bool _isRefreshing = false;

  static const String _devicesTable = 'active_devices';

  // ─── Getters ───

  bool get isRunning => _isRunning;
  SessionConfig get config => _config;
  DateTime? get lastActivity => _lastActivity;

  int? get secondsUntilExpiry {
    final session = _auth.currentSession;
    if (session == null) return null;
    final expiresAt = session.expiresAt;
    if (expiresAt == null) return null;
    final expiry = DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
    return expiry.difference(DateTime.now()).inSeconds;
  }

  // ─────────────────────────────────────────────────────────────
  //  LIFECYCLE
  // ─────────────────────────────────────────────────────────────

  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _lastActivity = DateTime.now();

    _refreshTimer = Timer.periodic(
      _config.refreshInterval,
      (_) => _checkAndRefresh(),
    );

    if (_config.idleTimeout > Duration.zero) {
      _idleTimer = Timer.periodic(
        const Duration(minutes: 1),
        (_) => _checkIdle(),
      );
    }

    if (kDebugMode) {
      // ignore: avoid_print
      print(
          '🔄 SessionManager started (every ${_config.refreshInterval.inMinutes}m)');
    }
  }

  void stop() {
    _refreshTimer?.cancel();
    _idleTimer?.cancel();
    _refreshTimer = null;
    _idleTimer = null;
    _isRunning = false;

    if (kDebugMode) {
      // ignore: avoid_print
      print('⏹️  SessionManager stopped');
    }
  }

  void configure(SessionConfig config) {
    final wasRunning = _isRunning;
    stop();
    _config = config;
    if (wasRunning) start();
  }

  void dispose() {
    stop();
    _lastActivity = null;
  }

  // ─────────────────────────────────────────────────────────────
  //  EVENTS
  // ─────────────────────────────────────────────────────────────

  Future<void> handleAppResume() async {
    if (!_auth.isLoggedIn) return;

    if (kDebugMode) {
      // ignore: avoid_print
      print('📱 App resumed — checking session');
    }

    // حدّث آخر ظهور للجهاز
    await updateLastSeen();

    if (_auth.isSessionExpired) {
      await _handleExpiry();
    } else if (_isExpiringSoon) {
      await _checkAndRefresh();
    }
  }

  void handleAppPause() {
    if (kDebugMode) {
      // ignore: avoid_print
      print('⏸️  App paused');
    }
  }

  void onUserActivity() {
    _lastActivity = DateTime.now();
  }

  // ─────────────────────────────────────────────────────────────
  //  DEVICE BINDING — Single Device Policy
  // ─────────────────────────────────────────────────────────────

  /// فحص هل الجهاز مسموح له بالدخول
  ///
  /// - لو مفيش جهاز نشط → مسموح (أول دخول)
  /// - لو الجهاز الحالي نشط → مسموح
  /// - لو فيه جهاز تاني نشط → ممنوع
  Future<DeviceCheckResult> checkDeviceAllowed({
    required String userId,
  }) async {
    try {
      final deviceService = _ref.read(deviceInfoServiceProvider);
      final deviceInfo = await deviceService.getInfo();

      final client = _ref.read(supabaseClientProvider);

      // 1. اجلب الأجهزة النشطة للمستخدم
      final data = await client
          .from(_devicesTable)
          .select()
          .eq('user_id', userId)
          .eq('is_active', true);

      final activeDevices = (data as List).cast<Map<String, dynamic>>();
      debugPrint('📱 [checkDeviceAllowed] userId=$userId');
      debugPrint('📱 [checkDeviceAllowed] deviceId=${deviceInfo.deviceId}');
      debugPrint(
          '📱 [checkDeviceAllowed] activeDevicesCount=${activeDevices.length}');
      for (final d in activeDevices) {
        debugPrint(
            '   - row: user_id=${d['user_id']} device_id=${d['device_id']} is_active=${d['is_active']}');
      }
      // 2. مفيش أجهزة → مسموح (أول دخول)
      if (activeDevices.isEmpty) {
        return DeviceCheckResult.allowed(
          deviceInfo: deviceInfo,
          isFirstDevice: true,
        );
      }

      // 3. فيه أجهزة → نشوف هل ده منهم
      final currentDevice = activeDevices.firstWhere(
        (d) => d['device_id'] == deviceInfo.deviceId,
        orElse: () => <String, dynamic>{},
      );

      if (currentDevice.isNotEmpty) {
        // ✅ الجهاز الحالي مسموح
        return DeviceCheckResult.allowed(
          deviceInfo: deviceInfo,
          isFirstDevice: false,
          existingDevice: currentDevice,
        );
      }

      // ❌ فيه جهاز تاني نشط → ممنوع
      final otherDevice = activeDevices.first;
      return DeviceCheckResult.blocked(
        deviceInfo: deviceInfo,
        activeDevice: otherDevice,
      );
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('checkDeviceAllowed error: $e');
      }
      // في حالة خطأ — نسمح (عشان ما نمنعش المستخدم بسبب مشكلة شبكة)
      final fallbackDevice =
          await _ref.read(deviceInfoServiceProvider).getInfo();
      return DeviceCheckResult.allowed(
        deviceInfo: fallbackDevice,
        isFirstDevice: false,
      );
    }
  }

  /// تسجيل الجهاز الحالي (بعد signIn ناجح)
  Future<bool> registerDevice({
    required String userId,
    required String tenantId,
  }) async {
    try {
      final deviceService = _ref.read(deviceInfoServiceProvider);
      final deviceInfo = await deviceService.getInfo();
      final client = _ref.read(supabaseClientProvider);

      // ابحث عن الجهاز
      final existing = await client
          .from(_devicesTable)
          .select('id')
          .eq('user_id', userId)
          .eq('device_id', deviceInfo.deviceId)
          .maybeSingle();

      if (existing != null) {
        // موجود → حدّث last_seen + إعادة تفعيل
        await client.from(_devicesTable).update({
          'last_seen_at': DateTime.now().toIso8601String(),
          'is_active': true,
          'revoked_at': null,
          'revoked_by': null,
          'device_name': deviceInfo.deviceName,
          'device_model': deviceInfo.deviceModel,
          'platform': deviceInfo.platform,
          'os_version': deviceInfo.osVersion,
          'app_version': deviceInfo.appVersion,
          'app_build_number': deviceInfo.appBuildNumber,
        }).eq('id', existing['id']);

        if (kDebugMode) {
          // ignore: avoid_print
          print('📱 Device re-registered: ${deviceInfo.displayName}');
        }
        return true;
      }

      // جديد → أنشئ
      await client.from(_devicesTable).insert({
        'user_id': userId,
        'tenant_id': tenantId,
        'device_id': deviceInfo.deviceId,
        'device_name': deviceInfo.deviceName,
        'device_model': deviceInfo.deviceModel,
        'platform': deviceInfo.platform,
        'os_version': deviceInfo.osVersion,
        'app_version': deviceInfo.appVersion,
        'app_build_number': deviceInfo.appBuildNumber,
        'is_active': true,
      });

      if (kDebugMode) {
        // ignore: avoid_print
        print('📱 Device registered: ${deviceInfo.displayName}');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('registerDevice error: $e');
      }
      return false;
    }
  }

  /// تحديث آخر ظهور (للاستخدام الدوري)
  Future<void> updateLastSeen() async {
    try {
      if (!_auth.isLoggedIn) return;
      final userId = _auth.currentUser?.id;
      if (userId == null) return;

      final deviceService = _ref.read(deviceInfoServiceProvider);
      final deviceId = await deviceService.getDeviceId();
      final client = _ref.read(supabaseClientProvider);

      await client
          .from(_devicesTable)
          .update({'last_seen_at': DateTime.now().toIso8601String()})
          .eq('user_id', userId)
          .eq('device_id', deviceId);
    } catch (_) {
      // silent fail
    }
  }

  /// جلب كل أجهزة الورشة (للأدمن)
  Future<List<Map<String, dynamic>>> getTenantDevices(
    String tenantId,
  ) async {
    try {
      final client = _ref.read(supabaseClientProvider);
      final data = await client
          .from(_devicesTable)
          .select()
          .eq('tenant_id', tenantId)
          .eq('is_active', true)
          .order('last_seen_at', ascending: false);
      return (data as List).cast<Map<String, dynamic>>();
    } catch (_) {
      return const [];
    }
  }

  /// إلغاء تفعيل جهاز (للأدمن)
  Future<bool> revokeDevice({
    required String deviceRowId,
    required String byUserId,
  }) async {
    try {
      final client = _ref.read(supabaseClientProvider);
      await client.from(_devicesTable).update({
        'is_active': false,
        'revoked_at': DateTime.now().toIso8601String(),
        'revoked_by': byUserId,
      }).eq('id', deviceRowId);

      if (kDebugMode) {
        // ignore: avoid_print
        print('🚫 Device revoked: $deviceRowId');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('revokeDevice error: $e');
      }
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  INTERNAL
  // ─────────────────────────────────────────────────────────────

  bool get _isExpiringSoon {
    final seconds = secondsUntilExpiry;
    if (seconds == null) return false;
    return seconds <= _config.expiryThreshold.inSeconds;
  }

  Future<void> _checkAndRefresh() async {
    if (_isRefreshing) return;
    if (!_auth.isLoggedIn) return;

    if (!_auth.isSessionExpired && !_isExpiringSoon) {
      return;
    }

    _isRefreshing = true;
    try {
      final success = await _auth.ensureValidSession();
      if (!success) {
        await _handleExpiry();
      } else if (kDebugMode) {
        // ignore: avoid_print
        print('✅ Session refreshed');
      }
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('❌ Session refresh failed: $e');
      }
      await _handleExpiry();
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _handleExpiry() async {
    if (!_config.autoSignOutOnExpiry) return;

    if (kDebugMode) {
      // ignore: avoid_print
      print('🚪 Session expired — signing out');
    }

    try {
      await _ref.read(authProvider.notifier).signOut();
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('Sign out error: $e');
      }
    }
  }

  Future<void> _checkIdle() async {
    if (_config.idleTimeout <= Duration.zero) return;
    if (!_auth.isLoggedIn) return;
    if (_lastActivity == null) return;

    final idle = DateTime.now().difference(_lastActivity!);
    if (idle >= _config.idleTimeout) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('💤 Idle timeout reached (${idle.inMinutes}m) — signing out');
      }
      await _ref.read(authProvider.notifier).signOut();
    }
  }
}

// ═══════════════════════════════════════════════════════════════
//  DEVICE CHECK RESULT
// ═══════════════════════════════════════════════════════════════

class DeviceCheckResult {
  const DeviceCheckResult._({
    required this.isAllowed,
    required this.deviceInfo,
    this.isFirstDevice = false,
    this.existingDevice,
    this.activeDevice,
    this.reason,
  });

  factory DeviceCheckResult.allowed({
    required DeviceInfo deviceInfo,
    bool isFirstDevice = false,
    Map<String, dynamic>? existingDevice,
  }) =>
      DeviceCheckResult._(
        isAllowed: true,
        deviceInfo: deviceInfo,
        isFirstDevice: isFirstDevice,
        existingDevice: existingDevice,
      );

  factory DeviceCheckResult.blocked({
    required DeviceInfo deviceInfo,
    required Map<String, dynamic> activeDevice,
  }) =>
      DeviceCheckResult._(
        isAllowed: false,
        deviceInfo: deviceInfo,
        activeDevice: activeDevice,
        reason: 'الحساب مرتبط بجهاز آخر',
      );

  final bool isAllowed;
  final DeviceInfo deviceInfo;
  final bool isFirstDevice;
  final Map<String, dynamic>? existingDevice;
  final Map<String, dynamic>? activeDevice;
  final String? reason;

  /// اسم الجهاز الآخر المسجّل
  String? get blockedByName =>
      activeDevice?['device_name'] as String? ??
      activeDevice?['device_model'] as String?;

  /// منصّة الجهاز الآخر
  String? get blockedByPlatform => activeDevice?['platform'] as String?;

  /// آخر ظهور للجهاز الآخر
  DateTime? get blockedByLastSeen {
    final raw = activeDevice?['last_seen_at'] as String?;
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }
}

// ═══════════════════════════════════════════════════════════════
//  PROVIDERS
// ═══════════════════════════════════════════════════════════════

final sessionConfigProvider =
    Provider<SessionConfig>((ref) => const SessionConfig());

final sessionManagerProvider = Provider<SessionManager>((ref) {
  final auth = ref.watch(authServiceProvider);
  final config = ref.watch(sessionConfigProvider);
  final manager = SessionManager(
    authService: auth,
    ref: ref,
    config: config,
  );
  ref.onDispose(manager.dispose);
  return manager;
});

// ═══════════════════════════════════════════════════════════════
//  WIDGET WRAPPER
// ═══════════════════════════════════════════════════════════════

class SessionManagerWidget extends ConsumerStatefulWidget {
  const SessionManagerWidget({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  ConsumerState<SessionManagerWidget> createState() =>
      _SessionManagerWidgetState();
}

class _SessionManagerWidgetState extends ConsumerState<SessionManagerWidget>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sessionManagerProvider).start();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final manager = ref.read(sessionManagerProvider);

    switch (state) {
      case AppLifecycleState.resumed:
        manager.handleAppResume();
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        manager.handleAppPause();
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => ref.read(sessionManagerProvider).onUserActivity(),
      onPointerMove: (_) => ref.read(sessionManagerProvider).onUserActivity(),
      child: widget.child,
    );
  }
}
