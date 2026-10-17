// lib/features/auth/data/models/app_user.dart

/// ═══════════════════════════════════════════════════════════
/// AppUser — نموذج المستخدم
/// ═══════════════════════════════════════════════════════════
///
/// يمثّل المستخدم في التطبيق (owner / staff).
/// مرتبط بـ Supabase Auth (auth.users) + جدول staff.
///
enum UserRole {
  owner, // صاحب الورشة
  manager, // مدير
  technician, // فني
  receptionist, // موظف استقبال
  accountant, // محاسب
}

extension UserRoleX on UserRole {
  /// الاسم بالعربي
  String get labelAr {
    switch (this) {
      case UserRole.owner:
        return 'مالك';
      case UserRole.manager:
        return 'مدير';
      case UserRole.technician:
        return 'فني';
      case UserRole.receptionist:
        return 'موظف استقبال';
      case UserRole.accountant:
        return 'محاسب';
    }
  }

  /// الاسم بالإنجليزي
  String get labelEn {
    switch (this) {
      case UserRole.owner:
        return 'Owner';
      case UserRole.manager:
        return 'Manager';
      case UserRole.technician:
        return 'Technician';
      case UserRole.receptionist:
        return 'Receptionist';
      case UserRole.accountant:
        return 'Accountant';
    }
  }

  /// هل هو owner؟
  bool get isOwner => this == UserRole.owner;

  /// هل هو tenant admin (owner أو manager)؟
  /// يعني: صلاحيات إدارية داخل الورشة فقط
  bool get isTenantAdmin => this == UserRole.owner || this == UserRole.manager;

  /// من string
  static UserRole fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'owner':
        return UserRole.owner;
      case 'manager':
        return UserRole.manager;
      case 'technician':
        return UserRole.technician;
      case 'receptionist':
        return UserRole.receptionist;
      case 'accountant':
        return UserRole.accountant;
      default:
        return UserRole.technician;
    }
  }
}

class AppUser {
  // ─── معلومات أساسية ───
  /// staff.id (row id)
  final String id;

  /// auth.users.id (= staff.user_id) — للـ FK
  final String userId;

  final String email;
  final String? phone;
  final String fullName;
  final String? fullNameAr;
  final String? avatarUrl;

  // ─── الصلاحيات ───
  final UserRole role;
  final String? tenantId; // الورشة اللي بينتمي لها

  /// هل هو أدمن النظام؟ (يقدر يدخل Admin Dashboard)
  /// ده حقل في قاعدة البيانات: staff.is_admin
  final bool isAdmin;

  // ─── الحالة ───
  final bool isActive;
  final bool isEmailVerified;
  final bool isPhoneVerified;

  // ─── معلومات إضافية ───
  final String? bio;
  final Map<String, dynamic>? metadata;

  // ─── تواريخ ───
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;

  const AppUser({
    required this.id,
    required this.userId,
    required this.email,
    this.phone,
    required this.fullName,
    this.fullNameAr,
    this.avatarUrl,
    this.role = UserRole.technician,
    this.tenantId,
    this.isAdmin = false,
    this.isActive = true,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.bio,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
  });

  /// نسخة افتراضية
  static const AppUser empty = AppUser(
    id: '',
    userId: '',
    email: '',
    fullName: '',
  );

  // ═══════════════════════════════════════════════════════════
  // CopyWith
  // ═══════════════════════════════════════════════════════════

  AppUser copyWith({
    String? id,
    String? userId,
    String? email,
    String? phone,
    String? fullName,
    String? fullNameAr,
    String? avatarUrl,
    UserRole? role,
    String? tenantId,
    bool? isAdmin,
    bool? isActive,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    String? bio,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      fullNameAr: fullNameAr ?? this.fullNameAr,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      tenantId: tenantId ?? this.tenantId,
      isAdmin: isAdmin ?? this.isAdmin,
      isActive: isActive ?? this.isActive,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      bio: bio ?? this.bio,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // fromJson — من Supabase / API
  // ═══════════════════════════════════════════════════════════

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      fullName: json['full_name'] as String? ?? '',
      fullNameAr: json['full_name_ar'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: UserRoleX.fromString(json['role'] as String?),
      tenantId: json['tenant_id'] as String?,
      isAdmin: json['is_admin'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      isEmailVerified: json['is_email_verified'] as bool? ?? false,
      isPhoneVerified: json['is_phone_verified'] as bool? ?? false,
      bio: json['bio'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      lastLoginAt: _parseDate(json['last_login_at']),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // toJson — لـ Supabase / API
  // ═══════════════════════════════════════════════════════════

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'email': email,
      'phone': phone,
      'full_name': fullName,
      'full_name_ar': fullNameAr,
      'avatar_url': avatarUrl,
      'role': role.name,
      'tenant_id': tenantId,
      'is_admin': isAdmin,
      'is_active': isActive,
      'is_email_verified': isEmailVerified,
      'is_phone_verified': isPhoneVerified,
      'bio': bio,
      'metadata': metadata,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
    };
  }

  /// نسخة للـ insert (بدون id/timestamps)
  Map<String, dynamic> toInsertJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'full_name': fullName,
      'full_name_ar': fullNameAr,
      'avatar_url': avatarUrl,
      'role': role.name,
      'tenant_id': tenantId,
      'is_admin': isAdmin,
      'is_active': isActive,
      'bio': bio,
    };
  }

  // ═══════════════════════════════════════════════════════════
  // toMap / fromMap — لـ Hive / Local Cache
  // ═══════════════════════════════════════════════════════════

  Map<String, dynamic> toMap() => toJson();

  factory AppUser.fromMap(Map<dynamic, dynamic> map) {
    return AppUser.fromJson(Map<String, dynamic>.from(map));
  }

  // ═══════════════════════════════════════════════════════════
  // Helpers
  // ═══════════════════════════════════════════════════════════

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  // ─── Getters ───

  /// هل المستخدم owner؟
  bool get isOwner => role.isOwner;

  /// هل هو tenant admin (owner أو manager)؟
  /// ده صلاحيات داخل الورشة فقط
  bool get isTenantAdmin => role.isTenantAdmin;

  /// الاسم المعروض (عربي أو إنجليزي)
  String displayName({bool isArabic = true}) {
    if (isArabic && fullNameAr != null && fullNameAr!.isNotEmpty) {
      return fullNameAr!;
    }
    return fullName;
  }

  /// أول حرف من الاسم (للـ Avatar)
  String get initials {
    final name = fullName.trim();
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  /// هل البيانات مكتملة؟
  bool get isComplete =>
      id.isNotEmpty && email.isNotEmpty && fullName.isNotEmpty;

  // ═══════════════════════════════════════════════════════════
  // Equality
  // ═══════════════════════════════════════════════════════════

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppUser &&
        other.id == id &&
        other.userId == userId &&
        other.email == email &&
        other.phone == phone &&
        other.fullName == fullName &&
        other.fullNameAr == fullNameAr &&
        other.avatarUrl == avatarUrl &&
        other.role == role &&
        other.tenantId == tenantId &&
        other.isAdmin == isAdmin &&
        other.isActive == isActive &&
        other.isEmailVerified == isEmailVerified &&
        other.isPhoneVerified == isPhoneVerified &&
        other.bio == bio;
  }

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        email,
        phone,
        fullName,
        fullNameAr,
        avatarUrl,
        role,
        tenantId,
        isAdmin,
        isActive,
        isEmailVerified,
        isPhoneVerified,
        bio,
      );

  @override
  String toString() {
    return 'AppUser(id: $id, email: $email, name: $fullName, '
        'role: ${role.name}, isAdmin: $isAdmin)';
  }
}
