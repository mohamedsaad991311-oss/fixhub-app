// lib/features/auth/data/models/tenant.dart

/// ═══════════════════════════════════════════════════════════
/// Tenant — نموذج الورشة (Multi-tenant)
/// ═══════════════════════════════════════════════════════════
///
/// بيمثّل ورشة صيانة واحدة. كل ورشة ليها:
/// - owner_id (المستخدم اللي أنشأها)
/// - staff (موظفين)
/// - receipts, inventory, suppliers, expenses, ...
///
/// الـ RLS بيضمن إن كل ورشة تشوف بياناتها بس.
///
enum SubscriptionPlan {
  free,
  basic,
  pro,
  enterprise,
}

extension SubscriptionPlanX on SubscriptionPlan {
  String get labelAr {
    switch (this) {
      case SubscriptionPlan.free:
        return 'مجاني';
      case SubscriptionPlan.basic:
        return 'أساسي';
      case SubscriptionPlan.pro:
        return 'احترافي';
      case SubscriptionPlan.enterprise:
        return 'متقدم';
    }
  }

  String get labelEn {
    switch (this) {
      case SubscriptionPlan.free:
        return 'Free';
      case SubscriptionPlan.basic:
        return 'Basic';
      case SubscriptionPlan.pro:
        return 'Pro';
      case SubscriptionPlan.enterprise:
        return 'Enterprise';
    }
  }

  /// هل هي خطة مدفوعة؟
  bool get isPaid => this != SubscriptionPlan.free;

  /// السعر الشهري (بالجنيه المصري)
  double get monthlyPrice {
    switch (this) {
      case SubscriptionPlan.free:
        return 0;
      case SubscriptionPlan.basic:
        return 99;
      case SubscriptionPlan.pro:
        return 199;
      case SubscriptionPlan.enterprise:
        return 499;
    }
  }

  /// الحد الأقصى للموظفين
  int get maxStaff {
    switch (this) {
      case SubscriptionPlan.free:
        return 1;
      case SubscriptionPlan.basic:
        return 3;
      case SubscriptionPlan.pro:
        return 10;
      case SubscriptionPlan.enterprise:
        return 999;
    }
  }

  /// الحد الأقصى للإيصالات شهرياً
  int get maxReceiptsPerMonth {
    switch (this) {
      case SubscriptionPlan.free:
        return 50;
      case SubscriptionPlan.basic:
        return 300;
      case SubscriptionPlan.pro:
        return 2000;
      case SubscriptionPlan.enterprise:
        return 999999;
    }
  }

  static SubscriptionPlan fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'free':
        return SubscriptionPlan.free;
      case 'basic':
        return SubscriptionPlan.basic;
      case 'pro':
        return SubscriptionPlan.pro;
      case 'enterprise':
        return SubscriptionPlan.enterprise;
      default:
        return SubscriptionPlan.free;
    }
  }
}

class Tenant {
  // ─── معلومات أساسية ───
  final String id;
  final String name;
  final String? nameAr;
  final String ownerId; // UUID من auth.users

  // ─── معلومات الاتصال ───
  final String? phone;
  final String? email;
  final String? address;
  final String? logoUrl;

  // ─── إعدادات ───
  final String currency; // 'EGP'
  final String timezone; // 'Africa/Cairo'

  // ─── الاشتراك ───
  final SubscriptionPlan subscriptionPlan;
  final DateTime? subscriptionExpiresAt;

  // ─── الحالة ───
  final bool isActive;

  // ─── تواريخ ───
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Tenant({
    required this.id,
    required this.name,
    this.nameAr,
    required this.ownerId,
    this.phone,
    this.email,
    this.address,
    this.logoUrl,
    this.currency = 'EGP',
    this.timezone = 'Africa/Cairo',
    this.subscriptionPlan = SubscriptionPlan.free,
    this.subscriptionExpiresAt,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  /// نسخة افتراضية
  static const Tenant empty = Tenant(
    id: '',
    name: '',
    ownerId: '',
  );

  // ═══════════════════════════════════════════════════════════
  // CopyWith
  // ═══════════════════════════════════════════════════════════

  Tenant copyWith({
    String? id,
    String? name,
    String? nameAr,
    String? ownerId,
    String? phone,
    String? email,
    String? address,
    String? logoUrl,
    String? currency,
    String? timezone,
    SubscriptionPlan? subscriptionPlan,
    DateTime? subscriptionExpiresAt,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Tenant(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      ownerId: ownerId ?? this.ownerId,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      logoUrl: logoUrl ?? this.logoUrl,
      currency: currency ?? this.currency,
      timezone: timezone ?? this.timezone,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      subscriptionExpiresAt:
          subscriptionExpiresAt ?? this.subscriptionExpiresAt,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // fromJson — من Supabase
  // ═══════════════════════════════════════════════════════════

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nameAr: json['name_ar'] as String?,
      ownerId: json['owner_id'] as String? ?? '',
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      logoUrl: json['logo_url'] as String?,
      currency: json['currency'] as String? ?? 'EGP',
      timezone: json['timezone'] as String? ?? 'Africa/Cairo',
      subscriptionPlan: SubscriptionPlanX.fromString(
        json['subscription_plan'] as String?,
      ),
      subscriptionExpiresAt: _parseDate(json['subscription_expires_at']),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // toJson — لـ Supabase
  // ═══════════════════════════════════════════════════════════

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_ar': nameAr,
      'owner_id': ownerId,
      'phone': phone,
      'email': email,
      'address': address,
      'logo_url': logoUrl,
      'currency': currency,
      'timezone': timezone,
      'subscription_plan': subscriptionPlan.name,
      'subscription_expires_at': subscriptionExpiresAt?.toIso8601String(),
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// نسخة للـ insert (بدون timestamps)
  Map<String, dynamic> toInsertJson() {
    return {
      'name': name,
      'name_ar': nameAr,
      'owner_id': ownerId,
      'phone': phone,
      'email': email,
      'address': address,
      'logo_url': logoUrl,
      'currency': currency,
      'timezone': timezone,
      'subscription_plan': subscriptionPlan.name,
      'is_active': isActive,
    };
  }

  // ═══════════════════════════════════════════════════════════
  // toMap / fromMap — لـ Hive
  // ═══════════════════════════════════════════════════════════

  Map<String, dynamic> toMap() => toJson();

  factory Tenant.fromMap(Map<dynamic, dynamic> map) {
    return Tenant.fromJson(Map<String, dynamic>.from(map));
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

  /// الاسم المعروض (عربي/إنجليزي)
  String displayName({bool isArabic = true}) {
    if (isArabic && nameAr != null && nameAr!.isNotEmpty) {
      return nameAr!;
    }
    return name;
  }

  /// أول حرفين من الاسم (للـ Avatar)
  String get initials {
    final n = name.trim();
    if (n.isEmpty) return '?';
    final parts = n.split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  /// هل الاشتراك منتهي؟
  bool get isSubscriptionExpired {
    if (subscriptionExpiresAt == null) return false;
    return subscriptionExpiresAt!.isBefore(DateTime.now());
  }

  /// الأيام المتبقية في الاشتراك
  int get subscriptionDaysLeft {
    if (subscriptionExpiresAt == null) return 0;
    final diff = subscriptionExpiresAt!.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  /// هل الاشتراك فعّال؟
  bool get hasActiveSubscription {
    if (subscriptionPlan == SubscriptionPlan.free) return true;
    if (subscriptionExpiresAt == null) return false;
    return subscriptionExpiresAt!.isAfter(DateTime.now());
  }

  /// هل البيانات مكتملة؟
  bool get isComplete => id.isNotEmpty && name.isNotEmpty && ownerId.isNotEmpty;

  // ═══════════════════════════════════════════════════════════
  // Equality
  // ═══════════════════════════════════════════════════════════

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Tenant &&
        other.id == id &&
        other.name == name &&
        other.nameAr == nameAr &&
        other.ownerId == ownerId &&
        other.phone == phone &&
        other.email == email &&
        other.address == address &&
        other.logoUrl == logoUrl &&
        other.currency == currency &&
        other.timezone == timezone &&
        other.subscriptionPlan == subscriptionPlan &&
        other.subscriptionExpiresAt == subscriptionExpiresAt &&
        other.isActive == isActive;
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        nameAr,
        ownerId,
        phone,
        email,
        address,
        logoUrl,
        currency,
        timezone,
        subscriptionPlan,
        subscriptionExpiresAt,
        isActive,
      );

  @override
  String toString() {
    return 'Tenant(id: $id, name: $name, owner: $ownerId, plan: ${subscriptionPlan.name})';
  }
}
