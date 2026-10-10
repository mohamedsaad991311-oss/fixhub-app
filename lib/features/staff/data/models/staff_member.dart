// lib/features/staff/data/models/staff_member.dart

import '../../../auth/data/models/app_user.dart' show UserRole, UserRoleX;

/// ═══════════════════════════════════════════════════════════
/// StaffMember — نموذج الموظف
/// ═══════════════════════════════════════════════════════════
///
/// بيمثّل موظف في الورشة. ممكن يكون:
/// - **مرتبط بحساب** (user_id موجود) → عنده login
/// - **مش مرتبط** (user_id = null) → موظف عادي بدون login
///
/// مثال: فني شغال في الورشة بس مش مسجّل في التطبيق.
///
class StaffPermissions {
  final bool canManageReceipts;
  final bool canManageInventory;
  final bool canManageSuppliers;
  final bool canManageExpenses;
  final bool canViewReports;
  final bool canManageStaff;
  final bool canManageSettings;

  const StaffPermissions({
    this.canManageReceipts = false,
    this.canManageInventory = false,
    this.canManageSuppliers = false,
    this.canManageExpenses = false,
    this.canViewReports = false,
    this.canManageStaff = false,
    this.canManageSettings = false,
  });

  /// كل الصلاحيات (للمالك)
  static const StaffPermissions all = StaffPermissions(
    canManageReceipts: true,
    canManageInventory: true,
    canManageSuppliers: true,
    canManageExpenses: true,
    canViewReports: true,
    canManageStaff: true,
    canManageSettings: true,
  );

  /// بدون صلاحيات (للموظف الجديد)
  static const StaffPermissions none = StaffPermissions();

  /// صلاحيات الفني
  static const StaffPermissions technician = StaffPermissions(
    canManageReceipts: true,
    canManageInventory: true,
  );

  /// صلاحيات الاستقبال
  static const StaffPermissions receptionist = StaffPermissions(
    canManageReceipts: true,
  );

  /// صلاحيات المدير
  static const StaffPermissions manager = StaffPermissions(
    canManageReceipts: true,
    canManageInventory: true,
    canManageSuppliers: true,
    canManageExpenses: true,
    canViewReports: true,
  );

  Map<String, dynamic> toJson() => {
        'can_manage_receipts': canManageReceipts,
        'can_manage_inventory': canManageInventory,
        'can_manage_suppliers': canManageSuppliers,
        'can_manage_expenses': canManageExpenses,
        'can_view_reports': canViewReports,
        'can_manage_staff': canManageStaff,
        'can_manage_settings': canManageSettings,
      };

  factory StaffPermissions.fromJson(Map<String, dynamic>? json) {
    if (json == null) return none;
    return StaffPermissions(
      canManageReceipts: json['can_manage_receipts'] as bool? ?? false,
      canManageInventory: json['can_manage_inventory'] as bool? ?? false,
      canManageSuppliers: json['can_manage_suppliers'] as bool? ?? false,
      canManageExpenses: json['can_manage_expenses'] as bool? ?? false,
      canViewReports: json['can_view_reports'] as bool? ?? false,
      canManageStaff: json['can_manage_staff'] as bool? ?? false,
      canManageSettings: json['can_manage_settings'] as bool? ?? false,
    );
  }

  StaffPermissions copyWith({
    bool? canManageReceipts,
    bool? canManageInventory,
    bool? canManageSuppliers,
    bool? canManageExpenses,
    bool? canViewReports,
    bool? canManageStaff,
    bool? canManageSettings,
  }) {
    return StaffPermissions(
      canManageReceipts: canManageReceipts ?? this.canManageReceipts,
      canManageInventory: canManageInventory ?? this.canManageInventory,
      canManageSuppliers: canManageSuppliers ?? this.canManageSuppliers,
      canManageExpenses: canManageExpenses ?? this.canManageExpenses,
      canViewReports: canViewReports ?? this.canViewReports,
      canManageStaff: canManageStaff ?? this.canManageStaff,
      canManageSettings: canManageSettings ?? this.canManageSettings,
    );
  }
}

class StaffMember {
  // ─── معلومات أساسية ───
  final String id;
  final String tenantId;
  final String? userId; // null لو مش مرتبط بحساب
  final String fullName;
  final String? fullNameAr;
  final String? email;
  final String? phone;
  final String? avatarUrl;

  // ─── الدور والصلاحيات ───
  final UserRole role;
  final StaffPermissions permissions;

  // ─── معلومات الوظيفة ───
  final DateTime? hireDate;
  final double? salary;

  // ─── الحالة ───
  final bool isActive;
  final String? notes;

  // ─── تواريخ ───
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StaffMember({
    required this.id,
    required this.tenantId,
    this.userId,
    required this.fullName,
    this.fullNameAr,
    this.email,
    this.phone,
    this.avatarUrl,
    this.role = UserRole.technician,
    this.permissions = StaffPermissions.none,
    this.hireDate,
    this.salary,
    this.isActive = true,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  /// نسخة افتراضية
  static const StaffMember empty = StaffMember(
    id: '',
    tenantId: '',
    fullName: '',
  );

  // ═══════════════════════════════════════════════════════════
  // CopyWith
  // ═══════════════════════════════════════════════════════════

  StaffMember copyWith({
    String? id,
    String? tenantId,
    String? userId,
    String? fullName,
    String? fullNameAr,
    String? email,
    String? phone,
    String? avatarUrl,
    UserRole? role,
    StaffPermissions? permissions,
    DateTime? hireDate,
    double? salary,
    bool? isActive,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StaffMember(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      fullNameAr: fullNameAr ?? this.fullNameAr,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      hireDate: hireDate ?? this.hireDate,
      salary: salary ?? this.salary,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // fromJson
  // ═══════════════════════════════════════════════════════════

  factory StaffMember.fromJson(Map<String, dynamic> json) {
    return StaffMember(
      id: json['id'] as String? ?? '',
      tenantId: json['tenant_id'] as String? ?? '',
      userId: json['user_id'] as String?,
      fullName: json['full_name'] as String? ?? '',
      fullNameAr: json['full_name_ar'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: UserRoleX.fromString(json['role'] as String?),
      permissions: StaffPermissions.fromJson(
        json['permissions'] as Map<String, dynamic>?,
      ),
      hireDate: _parseDate(json['hire_date']),
      salary: _parseDouble(json['salary']),
      isActive: json['is_active'] as bool? ?? true,
      notes: json['notes'] as String?,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // toJson
  // ═══════════════════════════════════════════════════════════

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'user_id': userId,
      'full_name': fullName,
      'full_name_ar': fullNameAr,
      'email': email,
      'phone': phone,
      'avatar_url': avatarUrl,
      'role': role.name,
      'permissions': permissions.toJson(),
      'hire_date': hireDate?.toIso8601String().split('T').first,
      'salary': salary,
      'is_active': isActive,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// نسخة للـ insert
  Map<String, dynamic> toInsertJson() {
    return {
      'tenant_id': tenantId,
      'user_id': userId,
      'full_name': fullName,
      'full_name_ar': fullNameAr,
      'email': email,
      'phone': phone,
      'avatar_url': avatarUrl,
      'role': role.name,
      'permissions': permissions.toJson(),
      'hire_date': hireDate?.toIso8601String().split('T').first,
      'salary': salary,
      'is_active': isActive,
      'notes': notes,
    };
  }

  // ═══════════════════════════════════════════════════════════
  // toMap / fromMap
  // ═══════════════════════════════════════════════════════════

  Map<String, dynamic> toMap() => toJson();

  factory StaffMember.fromMap(Map<dynamic, dynamic> map) {
    return StaffMember.fromJson(Map<String, dynamic>.from(map));
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

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  // ─── Getters ───

  /// الاسم المعروض
  String displayName({bool isArabic = true}) {
    if (isArabic && fullNameAr != null && fullNameAr!.isNotEmpty) {
      return fullNameAr!;
    }
    return fullName;
  }

  /// أول حرفين
  String get initials {
    final n = fullName.trim();
    if (n.isEmpty) return '?';
    final parts = n.split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  /// هل الموظف مرتبط بحساب؟
  bool get hasAccount => userId != null && userId!.isNotEmpty;

  /// هل هو مالك؟
  bool get isOwner => role.isOwner;

  /// هل هو مدير أو أعلى؟
  bool get isAdmin => role.isAdmin;

  /// سنوات الخدمة
  int get yearsOfService {
    if (hireDate == null) return 0;
    return DateTime.now().difference(hireDate!).inDays ~/ 365;
  }

  /// هل البيانات مكتملة؟
  bool get isComplete =>
      id.isNotEmpty && tenantId.isNotEmpty && fullName.isNotEmpty;

  // ═══════════════════════════════════════════════════════════
  // Equality
  // ═══════════════════════════════════════════════════════════

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StaffMember &&
        other.id == id &&
        other.tenantId == tenantId &&
        other.userId == userId &&
        other.fullName == fullName &&
        other.fullNameAr == fullNameAr &&
        other.email == email &&
        other.phone == phone &&
        other.avatarUrl == avatarUrl &&
        other.role == role &&
        other.hireDate == hireDate &&
        other.salary == salary &&
        other.isActive == isActive &&
        other.notes == notes;
  }

  @override
  int get hashCode => Object.hash(
        id,
        tenantId,
        userId,
        fullName,
        fullNameAr,
        email,
        phone,
        avatarUrl,
        role,
        hireDate,
        salary,
        isActive,
        notes,
      );

  @override
  String toString() {
    return 'StaffMember(id: $id, name: $fullName, role: ${role.name}, tenant: $tenantId)';
  }
}
