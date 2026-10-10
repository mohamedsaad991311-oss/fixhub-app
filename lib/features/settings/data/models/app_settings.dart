// lib/features/settings/data/models/app_settings.dart

// ═══════════════════════════════════════════════════════════
// Helper Functions — دوال مساعدة عامة
// ═══════════════════════════════════════════════════════════
DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

double _parseDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

// ═══════════════════════════════════════════════════════════
// WhatsApp Templates — قوالب رسائل الواتساب
// ═══════════════════════════════════════════════════════════

class WhatsappTemplates {
  final String welcome;
  final String statusUpdate;
  final String ready;
  final String delivered;
  final String reminder;
  final String warranty;

  const WhatsappTemplates({
    this.welcome = defaultWelcome,
    this.statusUpdate = defaultStatusUpdate,
    this.ready = defaultReady,
    this.delivered = defaultDelivered,
    this.reminder = defaultReminder,
    this.warranty = defaultWarranty,
  });

  // ─── القوالب الافتراضية ───

  static const String defaultWelcome = 'مرحباً {customer_name} 👋\n'
      'شكراً لاختيارك {shop_name}.\n'
      'تم استلام جهازك: {device_name}\n'
      'رقم الإيصال: {receipt_number}\n'
      'يمكنك متابعة حالة الجهاز عبر الرابط:\n'
      '{tracking_url}';

  static const String defaultStatusUpdate = 'مرحباً {customer_name} 👋\n'
      'تحديث بخصوص جهازك: {device_name}\n'
      'الحالة الجديدة: {status}\n'
      'رقم الإيصال: {receipt_number}\n'
      '{notes}';

  static const String defaultReady = 'مرحباً {customer_name} 👋\n'
      'خبر سعيد! جهازك جاهز للاستلام ✅\n'
      'الجهاز: {device_name}\n'
      'المبلغ المطلوب: {amount}\n'
      'رقم الإيصال: {receipt_number}\n'
      'في انتظارك في {shop_name} 🏪';

  static const String defaultDelivered =
      'شكراً لتعاملك معنا {customer_name} 🙏\n'
      'تم تسليم جهازك: {device_name}\n'
      'نتمنى لك تجربة ممتازة!';

  static const String defaultReminder = 'مرحباً {customer_name} 👋\n'
      'تذكير بخصوص جهازك: {device_name}\n'
      'رقم الإيصال: {receipt_number}\n'
      'في انتظارك في {shop_name} 🏪';

  static const String defaultWarranty = 'مرحباً {customer_name} 👋\n'
      'ضمان جهازك: {device_name}\n'
      'ينتهي في: {warranty_end}\n'
      'رقم الإيصال: {receipt_number}';

  Map<String, dynamic> toJson() => {
        'welcome': welcome,
        'status_update': statusUpdate,
        'ready': ready,
        'delivered': delivered,
        'reminder': reminder,
        'warranty': warranty,
      };

  factory WhatsappTemplates.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const WhatsappTemplates();
    return WhatsappTemplates(
      welcome: json['welcome'] as String? ?? defaultWelcome,
      statusUpdate: json['status_update'] as String? ?? defaultStatusUpdate,
      ready: json['ready'] as String? ?? defaultReady,
      delivered: json['delivered'] as String? ?? defaultDelivered,
      reminder: json['reminder'] as String? ?? defaultReminder,
      warranty: json['warranty'] as String? ?? defaultWarranty,
    );
  }

  WhatsappTemplates copyWith({
    String? welcome,
    String? statusUpdate,
    String? ready,
    String? delivered,
    String? reminder,
    String? warranty,
  }) {
    return WhatsappTemplates(
      welcome: welcome ?? this.welcome,
      statusUpdate: statusUpdate ?? this.statusUpdate,
      ready: ready ?? this.ready,
      delivered: delivered ?? this.delivered,
      reminder: reminder ?? this.reminder,
      warranty: warranty ?? this.warranty,
    );
  }
}

// ═══════════════════════════════════════════════════════════
// Notification Settings — إعدادات الإشعارات
// ═══════════════════════════════════════════════════════════

class NotificationSettings {
  final bool newReceipt;
  final bool statusChange;
  final bool lowStock;
  final bool paymentDue;
  final bool dailyReport;
  final bool sound;
  final bool vibration;

  const NotificationSettings({
    this.newReceipt = true,
    this.statusChange = true,
    this.lowStock = true,
    this.paymentDue = true,
    this.dailyReport = false,
    this.sound = true,
    this.vibration = true,
  });

  Map<String, dynamic> toJson() => {
        'new_receipt': newReceipt,
        'status_change': statusChange,
        'low_stock': lowStock,
        'payment_due': paymentDue,
        'daily_report': dailyReport,
        'sound': sound,
        'vibration': vibration,
      };

  factory NotificationSettings.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const NotificationSettings();
    return NotificationSettings(
      newReceipt: json['new_receipt'] as bool? ?? true,
      statusChange: json['status_change'] as bool? ?? true,
      lowStock: json['low_stock'] as bool? ?? true,
      paymentDue: json['payment_due'] as bool? ?? true,
      dailyReport: json['daily_report'] as bool? ?? false,
      sound: json['sound'] as bool? ?? true,
      vibration: json['vibration'] as bool? ?? true,
    );
  }

  NotificationSettings copyWith({
    bool? newReceipt,
    bool? statusChange,
    bool? lowStock,
    bool? paymentDue,
    bool? dailyReport,
    bool? sound,
    bool? vibration,
  }) {
    return NotificationSettings(
      newReceipt: newReceipt ?? this.newReceipt,
      statusChange: statusChange ?? this.statusChange,
      lowStock: lowStock ?? this.lowStock,
      paymentDue: paymentDue ?? this.paymentDue,
      dailyReport: dailyReport ?? this.dailyReport,
      sound: sound ?? this.sound,
      vibration: vibration ?? this.vibration,
    );
  }
}

// ═══════════════════════════════════════════════════════════
// AppSettings — النموذج الرئيسي
// ═══════════════════════════════════════════════════════════

class AppSettings {
  final String id;
  final String tenantId;

  // ─── معلومات الورشة ───
  final String? shopName;
  final String? shopPhone;
  final String? shopWhatsapp;
  final String? shopAddress;
  final String? shopLogoUrl;

  // ─── المالية ───
  final double taxRate;
  final String currency;

  // ─── الواتساب ───
  final WhatsappTemplates whatsappTemplates;

  // ─── الإيصالات ───
  final String? receiptFooter;
  final String? termsConditions;

  // ─── الإشعارات ───
  final NotificationSettings notificationSettings;

  // ─── التواريخ ───
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AppSettings({
    this.id = '',
    this.tenantId = '',
    this.shopName,
    this.shopPhone,
    this.shopWhatsapp,
    this.shopAddress,
    this.shopLogoUrl,
    this.taxRate = 0,
    this.currency = 'EGP',
    this.whatsappTemplates = const WhatsappTemplates(),
    this.receiptFooter,
    this.termsConditions,
    this.notificationSettings = const NotificationSettings(),
    this.createdAt,
    this.updatedAt,
  });

  static const AppSettings empty = AppSettings();

  AppSettings copyWith({
    String? id,
    String? tenantId,
    String? shopName,
    String? shopPhone,
    String? shopWhatsapp,
    String? shopAddress,
    String? shopLogoUrl,
    double? taxRate,
    String? currency,
    WhatsappTemplates? whatsappTemplates,
    String? receiptFooter,
    String? termsConditions,
    NotificationSettings? notificationSettings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppSettings(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      shopName: shopName ?? this.shopName,
      shopPhone: shopPhone ?? this.shopPhone,
      shopWhatsapp: shopWhatsapp ?? this.shopWhatsapp,
      shopAddress: shopAddress ?? this.shopAddress,
      shopLogoUrl: shopLogoUrl ?? this.shopLogoUrl,
      taxRate: taxRate ?? this.taxRate,
      currency: currency ?? this.currency,
      whatsappTemplates: whatsappTemplates ?? this.whatsappTemplates,
      receiptFooter: receiptFooter ?? this.receiptFooter,
      termsConditions: termsConditions ?? this.termsConditions,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      id: json['id'] as String? ?? '',
      tenantId: json['tenant_id'] as String? ?? '',
      shopName: json['shop_name'] as String?,
      shopPhone: json['shop_phone'] as String?,
      shopWhatsapp: json['shop_whatsapp'] as String?,
      shopAddress: json['shop_address'] as String?,
      shopLogoUrl: json['shop_logo_url'] as String?,
      taxRate: _parseDouble(json['tax_rate']),
      currency: json['currency'] as String? ?? 'EGP',
      whatsappTemplates: WhatsappTemplates.fromJson(
        json['whatsapp_templates'] as Map<String, dynamic>?,
      ),
      receiptFooter: json['receipt_footer'] as String?,
      termsConditions: json['terms_conditions'] as String?,
      notificationSettings: NotificationSettings.fromJson(
        json['notification_settings'] as Map<String, dynamic>?,
      ),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'shop_name': shopName,
      'shop_phone': shopPhone,
      'shop_whatsapp': shopWhatsapp,
      'shop_address': shopAddress,
      'shop_logo_url': shopLogoUrl,
      'tax_rate': taxRate,
      'currency': currency,
      'whatsapp_templates': whatsappTemplates.toJson(),
      'receipt_footer': receiptFooter,
      'terms_conditions': termsConditions,
      'notification_settings': notificationSettings.toJson(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    final json = toJson();
    json.remove('id');
    json.remove('created_at');
    json.remove('updated_at');
    return json;
  }

  Map<String, dynamic> toMap() => toJson();

  factory AppSettings.fromMap(Map<dynamic, dynamic> map) {
    return AppSettings.fromJson(Map<String, dynamic>.from(map));
  }

  // ─── Getters ───

  /// هل الإعدادات مكتملة؟
  bool get isComplete {
    return shopName != null &&
        shopName!.isNotEmpty &&
        shopPhone != null &&
        shopPhone!.isNotEmpty;
  }

  /// هل الواتساب متظبط؟
  bool get hasWhatsapp {
    return shopWhatsapp != null && shopWhatsapp!.isNotEmpty;
  }

  /// هل فيه ضريبة؟
  bool get hasTax => taxRate > 0;

  /// نسبة الضريبة (0.14 بدل 14)
  double get taxRateDecimal => taxRate / 100;

  // ─── Methods ───

  /// تعبئة قالب برسالة
  String fillTemplate(
    String template,
    Map<String, String> values,
  ) {
    var result = template;
    values.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }

  /// قالب الترحيب معبّى
  String buildWelcomeMessage({
    required String customerName,
    required String deviceName,
    required String receiptNumber,
    required String trackingUrl,
  }) {
    return fillTemplate(whatsappTemplates.welcome, {
      'customer_name': customerName,
      'shop_name': shopName ?? 'الورشة',
      'device_name': deviceName,
      'receipt_number': receiptNumber,
      'tracking_url': trackingUrl,
    });
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettings &&
        other.id == id &&
        other.tenantId == tenantId &&
        other.shopName == shopName &&
        other.shopPhone == shopPhone &&
        other.shopWhatsapp == shopWhatsapp &&
        other.taxRate == taxRate &&
        other.currency == currency;
  }

  @override
  int get hashCode => Object.hash(
        id,
        tenantId,
        shopName,
        shopPhone,
        shopWhatsapp,
        taxRate,
        currency,
      );

  @override
  String toString() {
    return 'AppSettings(shop: $shopName, currency: $currency, tax: $taxRate%)';
  }
}
