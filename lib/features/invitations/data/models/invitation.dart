// lib/features/invitations/data/models/invitation.dart

/// ═══════════════════════════════════════════════════════════════
/// Invitation — نموذج دعوة موظف جديد
/// ═══════════════════════════════════════════════════════════════
///
/// يطابق جدول `invitations` في Supabase:
/// id, tenant_id, invited_by, email, phone, full_name, role,
/// token, status, expires_at, accepted_at, accepted_by,
/// cancelled_at, cancelled_by, created_at
///
class Invitation {
  const Invitation({
    required this.id,
    required this.tenantId,
    required this.invitedBy,
    required this.role,
    required this.token,
    required this.status,
    required this.expiresAt,
    this.email,
    this.phone,
    this.fullName,
    this.acceptedAt,
    this.acceptedBy,
    this.cancelledAt,
    this.cancelledBy,
    this.createdAt,
  });

  final String id;
  final String tenantId;
  final String invitedBy;
  final String role;
  final String token;
  final String status;
  final DateTime expiresAt;
  final String? email;
  final String? phone;
  final String? fullName;
  final DateTime? acceptedAt;
  final String? acceptedBy;
  final DateTime? cancelledAt;
  final String? cancelledBy;
  final DateTime? createdAt;

  // ═══════════════════════════════════════════════════════════════
  //  getters
  // ═══════════════════════════════════════════════════════════════

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isExpired => status == 'expired';
  bool get isCancelled => status == 'cancelled';

  /// هل انتهت صلاحيتها بالتاريخ؟
  bool get isExpiredByDate => DateTime.now().isAfter(expiresAt);

  /// هل هي صالحة للاستخدام؟
  bool get isUsable => isPending && !isExpiredByDate;

  /// الحالة بالعربي
  String get statusLabelAr {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'accepted':
        return 'مقبولة';
      case 'expired':
        return 'منتهية';
      case 'cancelled':
        return 'ملغاة';
      default:
        return status;
    }
  }

  /// الدور بالعربي
  String get roleLabelAr {
    switch (role) {
      case 'owner':
        return 'مالك';
      case 'manager':
        return 'مدير';
      case 'technician':
        return 'فني';
      case 'receptionist':
        return 'موظف استقبال';
      case 'accountant':
        return 'محاسب';
      default:
        return role;
    }
  }

  /// الأيام المتبقية قبل الانتهاء
  int get remainingDays {
    final diff = expiresAt.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  /// تاريخ الإنشاء بصيغة نسبية
  String get relativeCreatedAt {
    if (createdAt == null) return 'غير معروف';
    final now = DateTime.now();
    final diff = now.difference(createdAt!);

    if (diff.inSeconds < 60) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    if (diff.inDays < 30) return 'منذ ${(diff.inDays / 7).floor()} أسبوع';
    return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}';
  }

  /// عرض الهدف (email أو phone)
  String get target {
    if (email != null && email!.isNotEmpty) return email!;
    if (phone != null && phone!.isNotEmpty) return phone!;
    return 'غير محدد';
  }

  /// هل هو بالبريد؟
  bool get isEmailInvite => email != null && email!.isNotEmpty;

  /// هل هو بالتليفون؟
  bool get isPhoneInvite => phone != null && phone!.isNotEmpty;

  // ═══════════════════════════════════════════════════════════════
  //  fromJson / toJson
  // ═══════════════════════════════════════════════════════════════

  factory Invitation.fromJson(Map<String, dynamic> json) {
    return Invitation(
      id: json['id'] as String? ?? '',
      tenantId: json['tenant_id'] as String? ?? '',
      invitedBy: json['invited_by'] as String? ?? '',
      role: json['role'] as String? ?? 'technician',
      token: json['token'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      expiresAt: _parseDate(json['expires_at']) ?? DateTime.now(),
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      fullName: json['full_name'] as String?,
      acceptedAt: _parseDate(json['accepted_at']),
      acceptedBy: json['accepted_by'] as String?,
      cancelledAt: _parseDate(json['cancelled_at']),
      cancelledBy: json['cancelled_by'] as String?,
      createdAt: _parseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tenant_id': tenantId,
        'invited_by': invitedBy,
        'role': role,
        'token': token,
        'status': status,
        'expires_at': expiresAt.toIso8601String(),
        'email': email,
        'phone': phone,
        'full_name': fullName,
        'accepted_at': acceptedAt?.toIso8601String(),
        'accepted_by': acceptedBy,
        'cancelled_at': cancelledAt?.toIso8601String(),
        'cancelled_by': cancelledBy,
        'created_at': createdAt?.toIso8601String(),
      };

  /// للـ insert (بدون timestamps)
  Map<String, dynamic> toInsertJson() => {
        'tenant_id': tenantId,
        'invited_by': invitedBy,
        'role': role,
        'token': token,
        'status': status,
        'expires_at': expiresAt.toIso8601String(),
        'email': email,
        'phone': phone,
        'full_name': fullName,
      };

  // ═══════════════════════════════════════════════════════════════
  //  copyWith
  // ═══════════════════════════════════════════════════════════════

  Invitation copyWith({
    String? id,
    String? tenantId,
    String? invitedBy,
    String? role,
    String? token,
    String? status,
    DateTime? expiresAt,
    String? email,
    String? phone,
    String? fullName,
    DateTime? acceptedAt,
    String? acceptedBy,
    DateTime? cancelledAt,
    String? cancelledBy,
    DateTime? createdAt,
  }) {
    return Invitation(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      invitedBy: invitedBy ?? this.invitedBy,
      role: role ?? this.role,
      token: token ?? this.token,
      status: status ?? this.status,
      expiresAt: expiresAt ?? this.expiresAt,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      acceptedBy: acceptedBy ?? this.acceptedBy,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancelledBy: cancelledBy ?? this.cancelledBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  مساعدات
  // ═══════════════════════════════════════════════════════════════

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  @override
  String toString() => 'Invitation($target, $roleLabelAr, $statusLabelAr)';
}
