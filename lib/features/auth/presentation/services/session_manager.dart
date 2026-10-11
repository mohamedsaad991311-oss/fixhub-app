// lib/features/auth/presentation/services/session_manager.dart

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/auth_service.dart';
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

  /// كل قد إيه نفحص الجلسة
  final Duration refreshInterval;

  /// نجدّد قبل انتهاء الجلسة بـ قد إيه
  final Duration expiryThreshold;

  /// لو المستخدم مش نشط لمدة كذا → sign out
  /// Duration.zero = معطّل
  final Duration idleTimeout;

  /// لما الجلسة تنتهي — نعمل signOut تلقائي
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

/// مسؤول عن:
/// - تجديد الجلسة دوريّاً (auto-refresh)
/// - sign out لما الجلسة تنتهي
/// - sign out لما المستخدم مش نشط (idle timeout)
/// - فحص الجلسة عند رجوع التطبيق من background
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

  // ─── Getters ───

  bool get isRunning => _isRunning;
  SessionConfig get config => _config;
  DateTime? get lastActivity => _lastActivity;

  /// ثواني متبقية للجلسة
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

  /// بدء المراقبة
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

  /// إيقاف المراقبة
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

  /// تحديث الإعدادات
  void configure(SessionConfig config) {
    final wasRunning = _isRunning;
    stop();
    _config = config;
    if (wasRunning) start();
  }

  /// تنظيف كامل
  void dispose() {
    stop();
    _lastActivity = null;
  }

  // ─────────────────────────────────────────────────────────────
  //  EVENTS
  // ─────────────────────────────────────────────────────────────

  /// لما التطبيق يرجع من background
  Future<void> handleAppResume() async {
    if (!_auth.isLoggedIn) return;

    if (kDebugMode) {
      // ignore: avoid_print
      print('📱 App resumed — checking session');
    }

    // فحص فوري
    if (_auth.isSessionExpired) {
      await _handleExpiry();
    } else if (_isExpiringSoon) {
      await _checkAndRefresh();
    }
  }

  /// لما التطبيق يروح background
  void handleAppPause() {
    // نوقف الـ timer عشان ما يشتغلش في الخلفية (توفير موارد)
    // بس ما نوقفش الـ refresh تماماً لأن الـ auth change events شغالة
    if (kDebugMode) {
      // ignore: avoid_print
      print('⏸️  App paused');
    }
  }

  /// تسجيل نشاط المستخدم (يتنادى من الـ UI)
  void onUserActivity() {
    _lastActivity = DateTime.now();
  }

  // ─────────────────────────────────────────────────────────────
  //  INTERNAL
  // ─────────────────────────────────────────────────────────────

  /// هل الجلسة هتنتهي قريباً؟
  bool get _isExpiringSoon {
    final seconds = secondsUntilExpiry;
    if (seconds == null) return false;
    return seconds <= _config.expiryThreshold.inSeconds;
  }

  /// فحص وتجديد الجلسة
  Future<void> _checkAndRefresh() async {
    if (_isRefreshing) return;
    if (!_auth.isLoggedIn) return;

    // لو مش محتاج refresh دلوقتي → خروج
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

  /// معالجة انتهاء الجلسة
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

  /// فحص الـ idle timeout
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
//  PROVIDERS
// ═══════════════════════════════════════════════════════════════

/// config للـ session
final sessionConfigProvider =
    Provider<SessionConfig>((ref) => const SessionConfig());

/// الـ SessionManager (singleton)
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
//  WIDGET WRAPPER — لربط lifecycle التطبيق
// ═══════════════════════════════════════════════════════════════

/// غلاف يربط `SessionManager` بدورة حياة التطبيق + نشاط المستخدم
///
/// الاستخدام:
/// ```dart
/// ProviderScope(
///   child: SessionManagerWidget(
///     child: FixHubApp(),
///   ),
/// )
/// ```
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

    // شغّل الـ manager بعد أول frame
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
    // Listener لأي نشاط من المستخدم
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => ref.read(sessionManagerProvider).onUserActivity(),
      onPointerMove: (_) => ref.read(sessionManagerProvider).onUserActivity(),
      child: widget.child,
    );
  }
}
