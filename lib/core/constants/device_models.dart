// lib/core/constants/device_models.dart

/// ═══════════════════════════════════════════════════════════
/// DeviceModel — موديل جهاز
/// ═══════════════════════════════════════════════════════════
class DeviceModel {
  final String brandId;
  final String name;

  const DeviceModel({required this.brandId, required this.name});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceModel &&
          runtimeType == other.runtimeType &&
          brandId == other.brandId &&
          name == other.name;

  @override
  int get hashCode => Object.hash(brandId, name);
}

/// ═══════════════════════════════════════════════════════════
/// قائمة الموديلات لكل شركة
/// ═══════════════════════════════════════════════════════════
const List<DeviceModel> deviceModels = [
  // ═══════════════════════════════════════════════
  //  Apple
  // ═══════════════════════════════════════════════
  // iPhone 17 series
  DeviceModel(brandId: 'apple', name: 'iPhone 17 Pro Max'),
  DeviceModel(brandId: 'apple', name: 'iPhone 17 Pro'),
  DeviceModel(brandId: 'apple', name: 'iPhone 17 Plus'),
  DeviceModel(brandId: 'apple', name: 'iPhone 17'),
  DeviceModel(brandId: 'apple', name: 'iPhone Air'),
  // iPhone 16 series
  DeviceModel(brandId: 'apple', name: 'iPhone 16 Pro Max'),
  DeviceModel(brandId: 'apple', name: 'iPhone 16 Pro'),
  DeviceModel(brandId: 'apple', name: 'iPhone 16 Plus'),
  DeviceModel(brandId: 'apple', name: 'iPhone 16'),
  DeviceModel(brandId: 'apple', name: 'iPhone 16e'),
  // iPhone 15 series
  DeviceModel(brandId: 'apple', name: 'iPhone 15 Pro Max'),
  DeviceModel(brandId: 'apple', name: 'iPhone 15 Pro'),
  DeviceModel(brandId: 'apple', name: 'iPhone 15 Plus'),
  DeviceModel(brandId: 'apple', name: 'iPhone 15'),
  // iPhone 14 series
  DeviceModel(brandId: 'apple', name: 'iPhone 14 Pro Max'),
  DeviceModel(brandId: 'apple', name: 'iPhone 14 Pro'),
  DeviceModel(brandId: 'apple', name: 'iPhone 14 Plus'),
  DeviceModel(brandId: 'apple', name: 'iPhone 14'),
  // iPhone 13 series
  DeviceModel(brandId: 'apple', name: 'iPhone 13 Pro Max'),
  DeviceModel(brandId: 'apple', name: 'iPhone 13 Pro'),
  DeviceModel(brandId: 'apple', name: 'iPhone 13 mini'),
  DeviceModel(brandId: 'apple', name: 'iPhone 13'),
  // iPhone 12 series
  DeviceModel(brandId: 'apple', name: 'iPhone 12 Pro Max'),
  DeviceModel(brandId: 'apple', name: 'iPhone 12 Pro'),
  DeviceModel(brandId: 'apple', name: 'iPhone 12 mini'),
  DeviceModel(brandId: 'apple', name: 'iPhone 12'),
  // iPhone 11 series
  DeviceModel(brandId: 'apple', name: 'iPhone 11 Pro Max'),
  DeviceModel(brandId: 'apple', name: 'iPhone 11 Pro'),
  DeviceModel(brandId: 'apple', name: 'iPhone 11'),
  // iPhone X/SE
  DeviceModel(brandId: 'apple', name: 'iPhone XS Max'),
  DeviceModel(brandId: 'apple', name: 'iPhone XS'),
  DeviceModel(brandId: 'apple', name: 'iPhone XR'),
  DeviceModel(brandId: 'apple', name: 'iPhone X'),
  DeviceModel(brandId: 'apple', name: 'iPhone SE (3rd gen)'),
  DeviceModel(brandId: 'apple', name: 'iPhone SE (2nd gen)'),
  DeviceModel(brandId: 'apple', name: 'iPhone SE (1st gen)'),
  // iPhone 8/7/6
  DeviceModel(brandId: 'apple', name: 'iPhone 8 Plus'),
  DeviceModel(brandId: 'apple', name: 'iPhone 8'),
  DeviceModel(brandId: 'apple', name: 'iPhone 7 Plus'),
  DeviceModel(brandId: 'apple', name: 'iPhone 7'),
  DeviceModel(brandId: 'apple', name: 'iPhone 6s Plus'),
  DeviceModel(brandId: 'apple', name: 'iPhone 6s'),
  DeviceModel(brandId: 'apple', name: 'iPhone 6 Plus'),
  DeviceModel(brandId: 'apple', name: 'iPhone 6'),
  // iPad
  DeviceModel(brandId: 'apple', name: 'iPad Pro 13" (M4)'),
  DeviceModel(brandId: 'apple', name: 'iPad Pro 11" (M4)'),
  DeviceModel(brandId: 'apple', name: 'iPad Air 13" (M2)'),
  DeviceModel(brandId: 'apple', name: 'iPad Air 11" (M2)'),
  DeviceModel(brandId: 'apple', name: 'iPad 10th gen'),
  DeviceModel(brandId: 'apple', name: 'iPad 9th gen'),
  DeviceModel(brandId: 'apple', name: 'iPad mini 6'),
  // MacBook
  DeviceModel(brandId: 'apple', name: 'MacBook Pro 14" M3'),
  DeviceModel(brandId: 'apple', name: 'MacBook Pro 16" M3'),
  DeviceModel(brandId: 'apple', name: 'MacBook Air 13" M3'),
  DeviceModel(brandId: 'apple', name: 'MacBook Air 15" M3'),
  // Apple Watch
  DeviceModel(brandId: 'apple', name: 'Apple Watch Series 10'),
  DeviceModel(brandId: 'apple', name: 'Apple Watch Series 9'),
  DeviceModel(brandId: 'apple', name: 'Apple Watch Ultra 2'),
  DeviceModel(brandId: 'apple', name: 'Apple Watch SE'),

  // ═══════════════════════════════════════════════
  //  Samsung
  // ═══════════════════════════════════════════════
  // S Series
  DeviceModel(brandId: 'samsung', name: 'Galaxy S25 Ultra'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy S25+'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy S25'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy S24 Ultra'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy S24+'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy S24'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy S24 FE'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy S23 Ultra'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy S23+'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy S23'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy S22 Ultra'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy S22+'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy S22'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy S21 FE'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy S21 Ultra'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy S21+'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy S21'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy S20 FE'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy S20 Ultra'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy S20+'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy S20'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy S10+'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy S10'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy S10e'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy S9+'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy S9'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy S8+'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy S8'),
  // Note Series
  DeviceModel(brandId: 'samsung', name: 'Galaxy Note 20 Ultra'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy Note 20'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy Note 10+'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy Note 10'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy Note 9'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy Note 8'),
  // Z Fold/Flip
  DeviceModel(brandId: 'samsung', name: 'Galaxy Z Fold 6'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy Z Fold 5'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy Z Fold 4'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy Z Fold 3'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy Z Flip 6'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy Z Flip 5'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy Z Flip 4'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy Z Flip 3'),
  // A Series
  DeviceModel(brandId: 'samsung', name: 'Galaxy A55'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy A54'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy A53'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy A52'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy A51'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy A50'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy A35'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy A34'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy A33'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy A32'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy A25'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy A24'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy A23'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy A15'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy A14'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy A13'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy A12'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy A05'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy A04'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy A03'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy A02'),
  // M Series
  DeviceModel(brandId: 'samsung', name: 'Galaxy M55'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy M54'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy M53'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy M34'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy M33'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy M32'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy M14'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy M13'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy M12'),
  // Tab Series
  DeviceModel(brandId: 'samsung', name: 'Galaxy Tab S10 Ultra'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy Tab S9 Ultra'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy Tab S9+'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy Tab S9'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy Tab S9 FE'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy Tab S8 Ultra'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy Tab S8+'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy Tab S8'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy Tab A9+'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy Tab A9'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy Tab A8'),
  DeviceModel(brandId: 'samsung', name: 'Galaxy Tab A7'),

  // ═══════════════════════════════════════════════
  //  Xiaomi
  // ═══════════════════════════════════════════════
  // Xiaomi flagship
  DeviceModel(brandId: 'xiaomi', name: 'Xiaomi 15 Ultra'),
  DeviceModel(brandId: 'xiaomi', name: 'Xiaomi 15 Pro'),
  DeviceModel(brandId: 'xiaomi', name: 'Xiaomi 15'),
  DeviceModel(brandId: 'xiaomi', name: 'Xiaomi 14 Ultra'),
  DeviceModel(brandId: 'xiaomi', name: 'Xiaomi 14 Pro'),
  DeviceModel(brandId: 'xiaomi', name: 'Xiaomi 14'),
  DeviceModel(brandId: 'xiaomi', name: 'Xiaomi 13 Ultra'),
  DeviceModel(brandId: 'xiaomi', name: 'Xiaomi 13 Pro'),
  DeviceModel(brandId: 'xiaomi', name: 'Xiaomi 13'),
  DeviceModel(brandId: 'xiaomi', name: 'Xiaomi 13 Lite'),
  DeviceModel(brandId: 'xiaomi', name: 'Xiaomi 12 Pro'),
  DeviceModel(brandId: 'xiaomi', name: 'Xiaomi 12'),
  DeviceModel(brandId: 'xiaomi', name: 'Xiaomi 12X'),
  DeviceModel(brandId: 'xiaomi', name: 'Xiaomi 12 Lite'),
  DeviceModel(brandId: 'xiaomi', name: 'Xiaomi 11T Pro'),
  DeviceModel(brandId: 'xiaomi', name: 'Xiaomi 11T'),
  DeviceModel(brandId: 'xiaomi', name: 'Xiaomi 11 Lite 5G NE'),
  // Xiaomi Pad
  DeviceModel(brandId: 'xiaomi', name: 'Xiaomi Pad 7 Pro'),
  DeviceModel(brandId: 'xiaomi', name: 'Xiaomi Pad 7'),
  DeviceModel(brandId: 'xiaomi', name: 'Xiaomi Pad 6'),
  DeviceModel(brandId: 'xiaomi', name: 'Xiaomi Pad 6 Pro'),
  DeviceModel(brandId: 'xiaomi', name: 'Xiaomi Pad 5'),

  // ═══════════════════════════════════════════════
  //  Redmi
  // ═══════════════════════════════════════════════
  DeviceModel(brandId: 'redmi', name: 'Redmi Note 14 Pro+'),
  DeviceModel(brandId: 'redmi', name: 'Redmi Note 14 Pro'),
  DeviceModel(brandId: 'redmi', name: 'Redmi Note 14'),
  DeviceModel(brandId: 'redmi', name: 'Redmi Note 13 Pro+'),
  DeviceModel(brandId: 'redmi', name: 'Redmi Note 13 Pro'),
  DeviceModel(brandId: 'redmi', name: 'Redmi Note 13'),
  DeviceModel(brandId: 'redmi', name: 'Redmi Note 12 Pro+'),
  DeviceModel(brandId: 'redmi', name: 'Redmi Note 12 Pro'),
  DeviceModel(brandId: 'redmi', name: 'Redmi Note 12'),
  DeviceModel(brandId: 'redmi', name: 'Redmi Note 12S'),
  DeviceModel(brandId: 'redmi', name: 'Redmi Note 11 Pro+'),
  DeviceModel(brandId: 'redmi', name: 'Redmi Note 11 Pro'),
  DeviceModel(brandId: 'redmi', name: 'Redmi Note 11'),
  DeviceModel(brandId: 'redmi', name: 'Redmi Note 11S'),
  DeviceModel(brandId: 'redmi', name: 'Redmi Note 10 Pro'),
  DeviceModel(brandId: 'redmi', name: 'Redmi Note 10'),
  DeviceModel(brandId: 'redmi', name: 'Redmi Note 10S'),
  DeviceModel(brandId: 'redmi', name: 'Redmi Note 9 Pro'),
  DeviceModel(brandId: 'redmi', name: 'Redmi Note 9'),
  DeviceModel(brandId: 'redmi', name: 'Redmi Note 9S'),
  DeviceModel(brandId: 'redmi', name: 'Redmi Note 8 Pro'),
  DeviceModel(brandId: 'redmi', name: 'Redmi Note 8'),
  DeviceModel(brandId: 'redmi', name: 'Redmi 14C'),
  DeviceModel(brandId: 'redmi', name: 'Redmi 13C'),
  DeviceModel(brandId: 'redmi', name: 'Redmi 13'),
  DeviceModel(brandId: 'redmi', name: 'Redmi 12C'),
  DeviceModel(brandId: 'redmi', name: 'Redmi 12'),
  DeviceModel(brandId: 'redmi', name: 'Redmi 10C'),
  DeviceModel(brandId: 'redmi', name: 'Redmi 10'),
  DeviceModel(brandId: 'redmi', name: 'Redmi 10A'),
  DeviceModel(brandId: 'redmi', name: 'Redmi 9C'),
  DeviceModel(brandId: 'redmi', name: 'Redmi 9A'),
  DeviceModel(brandId: 'redmi', name: 'Redmi 9'),
  DeviceModel(brandId: 'redmi', name: 'Redmi 9T'),
  DeviceModel(brandId: 'redmi', name: 'Redmi 8'),
  DeviceModel(brandId: 'redmi', name: 'Redmi 8A'),
  // Redmi Pad
  DeviceModel(brandId: 'redmi', name: 'Redmi Pad Pro'),
  DeviceModel(brandId: 'redmi', name: 'Redmi Pad SE'),
  DeviceModel(brandId: 'redmi', name: 'Redmi Pad'),

  // ═══════════════════════════════════════════════
  //  Poco
  // ═══════════════════════════════════════════════
  DeviceModel(brandId: 'poco', name: 'Poco X7 Pro'),
  DeviceModel(brandId: 'poco', name: 'Poco X7'),
  DeviceModel(brandId: 'poco', name: 'Poco X6 Pro'),
  DeviceModel(brandId: 'poco', name: 'Poco X6'),
  DeviceModel(brandId: 'poco', name: 'Poco X5 Pro'),
  DeviceModel(brandId: 'poco', name: 'Poco X5'),
  DeviceModel(brandId: 'poco', name: 'Poco X4 Pro'),
  DeviceModel(brandId: 'poco', name: 'Poco X4 GT'),
  DeviceModel(brandId: 'poco', name: 'Poco X3 Pro'),
  DeviceModel(brandId: 'poco', name: 'Poco X3 NFC'),
  DeviceModel(brandId: 'poco', name: 'Poco X3'),
  DeviceModel(brandId: 'poco', name: 'Poco M7 Pro'),
  DeviceModel(brandId: 'poco', name: 'Poco M7'),
  DeviceModel(brandId: 'poco', name: 'Poco M6 Pro'),
  DeviceModel(brandId: 'poco', name: 'Poco M6'),
  DeviceModel(brandId: 'poco', name: 'Poco M5'),
  DeviceModel(brandId: 'poco', name: 'Poco M4 Pro'),
  DeviceModel(brandId: 'poco', name: 'Poco M3'),
  DeviceModel(brandId: 'poco', name: 'Poco F7'),
  DeviceModel(brandId: 'poco', name: 'Poco F6 Pro'),
  DeviceModel(brandId: 'poco', name: 'Poco F6'),
  DeviceModel(brandId: 'poco', name: 'Poco F5 Pro'),
  DeviceModel(brandId: 'poco', name: 'Poco F5'),
  DeviceModel(brandId: 'poco', name: 'Poco F4'),
  DeviceModel(brandId: 'poco', name: 'Poco F3'),
  DeviceModel(brandId: 'poco', name: 'Poco C75'),
  DeviceModel(brandId: 'poco', name: 'Poco C65'),
  DeviceModel(brandId: 'poco', name: 'Poco C55'),
  DeviceModel(brandId: 'poco', name: 'Poco C40'),

  // ═══════════════════════════════════════════════
  //  Oppo
  // ═══════════════════════════════════════════════
  DeviceModel(brandId: 'oppo', name: 'Oppo Find X8 Pro'),
  DeviceModel(brandId: 'oppo', name: 'Oppo Find X8'),
  DeviceModel(brandId: 'oppo', name: 'Oppo Find X7 Ultra'),
  DeviceModel(brandId: 'oppo', name: 'Oppo Find X7'),
  DeviceModel(brandId: 'oppo', name: 'Oppo Find X6 Pro'),
  DeviceModel(brandId: 'oppo', name: 'Oppo Find X6'),
  DeviceModel(brandId: 'oppo', name: 'Oppo Find X5 Pro'),
  DeviceModel(brandId: 'oppo', name: 'Oppo Find X5'),
  DeviceModel(brandId: 'oppo', name: 'Oppo Find X3 Pro'),
  DeviceModel(brandId: 'oppo', name: 'Oppo Reno 13 Pro'),
  DeviceModel(brandId: 'oppo', name: 'Oppo Reno 13'),
  DeviceModel(brandId: 'oppo', name: 'Oppo Reno 12 Pro'),
  DeviceModel(brandId: 'oppo', name: 'Oppo Reno 12'),
  DeviceModel(brandId: 'oppo', name: 'Oppo Reno 11 Pro'),
  DeviceModel(brandId: 'oppo', name: 'Oppo Reno 11'),
  DeviceModel(brandId: 'oppo', name: 'Oppo Reno 10 Pro+'),
  DeviceModel(brandId: 'oppo', name: 'Oppo Reno 10 Pro'),
  DeviceModel(brandId: 'oppo', name: 'Oppo Reno 10'),
  DeviceModel(brandId: 'oppo', name: 'Oppo Reno 8 Pro'),
  DeviceModel(brandId: 'oppo', name: 'Oppo Reno 8'),
  DeviceModel(brandId: 'oppo', name: 'Oppo Reno 8T'),
  DeviceModel(brandId: 'oppo', name: 'Oppo Reno 7'),
  DeviceModel(brandId: 'oppo', name: 'Oppo Reno 6'),
  DeviceModel(brandId: 'oppo', name: 'Oppo Reno 5'),
  DeviceModel(brandId: 'oppo', name: 'Oppo Reno 4'),
  DeviceModel(brandId: 'oppo', name: 'Oppo A98'),
  DeviceModel(brandId: 'oppo', name: 'Oppo A96'),
  DeviceModel(brandId: 'oppo', name: 'Oppo A95'),
  DeviceModel(brandId: 'oppo', name: 'Oppo A78'),
  DeviceModel(brandId: 'oppo', name: 'Oppo A77'),
  DeviceModel(brandId: 'oppo', name: 'Oppo A76'),
  DeviceModel(brandId: 'oppo', name: 'Oppo A74'),
  DeviceModel(brandId: 'oppo', name: 'Oppo A58'),
  DeviceModel(brandId: 'oppo', name: 'Oppo A57'),
  DeviceModel(brandId: 'oppo', name: 'Oppo A54'),
  DeviceModel(brandId: 'oppo', name: 'Oppo A53'),
  DeviceModel(brandId: 'oppo', name: 'Oppo A38'),
  DeviceModel(brandId: 'oppo', name: 'Oppo A18'),
  DeviceModel(brandId: 'oppo', name: 'Oppo A17'),
  DeviceModel(brandId: 'oppo', name: 'Oppo A16'),
  DeviceModel(brandId: 'oppo', name: 'Oppo A15'),
  DeviceModel(brandId: 'oppo', name: 'Oppo A12'),
  DeviceModel(brandId: 'oppo', name: 'Oppo A5s'),

  // ═══════════════════════════════════════════════
  //  Honor
  // ═══════════════════════════════════════════════
  DeviceModel(brandId: 'honor', name: 'Honor Magic 7 Pro'),
  DeviceModel(brandId: 'honor', name: 'Honor Magic 7'),
  DeviceModel(brandId: 'honor', name: 'Honor Magic 6 Pro'),
  DeviceModel(brandId: 'honor', name: 'Honor Magic 6'),
  DeviceModel(brandId: 'honor', name: 'Honor Magic 5 Pro'),
  DeviceModel(brandId: 'honor', name: 'Honor Magic 5'),
  DeviceModel(brandId: 'honor', name: 'Honor Magic V3'),
  DeviceModel(brandId: 'honor', name: 'Honor Magic Vs'),
  DeviceModel(brandId: 'honor', name: 'Honor 200 Pro'),
  DeviceModel(brandId: 'honor', name: 'Honor 200'),
  DeviceModel(brandId: 'honor', name: 'Honor 200 Lite'),
  DeviceModel(brandId: 'honor', name: 'Honor 100 Pro'),
  DeviceModel(brandId: 'honor', name: 'Honor 100'),
  DeviceModel(brandId: 'honor', name: 'Honor 90 Pro'),
  DeviceModel(brandId: 'honor', name: 'Honor 90'),
  DeviceModel(brandId: 'honor', name: 'Honor 90 Lite'),
  DeviceModel(brandId: 'honor', name: 'Honor 70 Pro'),
  DeviceModel(brandId: 'honor', name: 'Honor 70'),
  DeviceModel(brandId: 'honor', name: 'Honor 50'),
  DeviceModel(brandId: 'honor', name: 'Honor X9c'),
  DeviceModel(brandId: 'honor', name: 'Honor X9b'),
  DeviceModel(brandId: 'honor', name: 'Honor X9a'),
  DeviceModel(brandId: 'honor', name: 'Honor X8b'),
  DeviceModel(brandId: 'honor', name: 'Honor X8a'),
  DeviceModel(brandId: 'honor', name: 'Honor X8'),
  DeviceModel(brandId: 'honor', name: 'Honor X7b'),
  DeviceModel(brandId: 'honor', name: 'Honor X7a'),
  DeviceModel(brandId: 'honor', name: 'Honor X7'),
  DeviceModel(brandId: 'honor', name: 'Honor X6b'),
  DeviceModel(brandId: 'honor', name: 'Honor X6a'),
  DeviceModel(brandId: 'honor', name: 'Honor X6'),
  DeviceModel(brandId: 'honor', name: 'Honor X5 Plus'),
  DeviceModel(brandId: 'honor', name: 'Honor X5'),
  // Honor Pad
  DeviceModel(brandId: 'honor', name: 'Honor Pad 9'),
  DeviceModel(brandId: 'honor', name: 'Honor Pad 8'),
  DeviceModel(brandId: 'honor', name: 'Honor Pad X9'),
  DeviceModel(brandId: 'honor', name: 'Honor Pad X8'),

  // ═══════════════════════════════════════════════
  //  Realme
  // ═══════════════════════════════════════════════
  DeviceModel(brandId: 'realme', name: 'Realme GT 7 Pro'),
  DeviceModel(brandId: 'realme', name: 'Realme GT 7'),
  DeviceModel(brandId: 'realme', name: 'Realme GT 6'),
  DeviceModel(brandId: 'realme', name: 'Realme GT 5 Pro'),
  DeviceModel(brandId: 'realme', name: 'Realme GT 5'),
  DeviceModel(brandId: 'realme', name: 'Realme GT 2 Pro'),
  DeviceModel(brandId: 'realme', name: 'Realme GT Neo 6'),
  DeviceModel(brandId: 'realme', name: 'Realme GT Neo 5'),
  DeviceModel(brandId: 'realme', name: 'Realme GT Neo 3'),
  DeviceModel(brandId: 'realme', name: 'Realme 14 Pro+'),
  DeviceModel(brandId: 'realme', name: 'Realme 14 Pro'),
  DeviceModel(brandId: 'realme', name: 'Realme 13 Pro+'),
  DeviceModel(brandId: 'realme', name: 'Realme 13 Pro'),
  DeviceModel(brandId: 'realme', name: 'Realme 13+'),
  DeviceModel(brandId: 'realme', name: 'Realme 13'),
  DeviceModel(brandId: 'realme', name: 'Realme 12 Pro+'),
  DeviceModel(brandId: 'realme', name: 'Realme 12 Pro'),
  DeviceModel(brandId: 'realme', name: 'Realme 12+'),
  DeviceModel(brandId: 'realme', name: 'Realme 12'),
  DeviceModel(brandId: 'realme', name: 'Realme 11 Pro+'),
  DeviceModel(brandId: 'realme', name: 'Realme 11 Pro'),
  DeviceModel(brandId: 'realme', name: 'Realme 11'),
  DeviceModel(brandId: 'realme', name: 'Realme 10 Pro+'),
  DeviceModel(brandId: 'realme', name: 'Realme 10 Pro'),
  DeviceModel(brandId: 'realme', name: 'Realme 10'),
  DeviceModel(brandId: 'realme', name: 'Realme 9 Pro+'),
  DeviceModel(brandId: 'realme', name: 'Realme 9 Pro'),
  DeviceModel(brandId: 'realme', name: 'Realme 9'),
  DeviceModel(brandId: 'realme', name: 'Realme 8 Pro'),
  DeviceModel(brandId: 'realme', name: 'Realme 8'),
  DeviceModel(brandId: 'realme', name: 'Realme 7 Pro'),
  DeviceModel(brandId: 'realme', name: 'Realme 7'),
  DeviceModel(brandId: 'realme', name: 'Realme 6 Pro'),
  DeviceModel(brandId: 'realme', name: 'Realme 6'),
  DeviceModel(brandId: 'realme', name: 'Realme C67'),
  DeviceModel(brandId: 'realme', name: 'Realme C65'),
  DeviceModel(brandId: 'realme', name: 'Realme C61'),
  DeviceModel(brandId: 'realme', name: 'Realme C55'),
  DeviceModel(brandId: 'realme', name: 'Realme C53'),
  DeviceModel(brandId: 'realme', name: 'Realme C51'),
  DeviceModel(brandId: 'realme', name: 'Realme C35'),
  DeviceModel(brandId: 'realme', name: 'Realme C33'),
  DeviceModel(brandId: 'realme', name: 'Realme C31'),
  DeviceModel(brandId: 'realme', name: 'Realme C25'),
  DeviceModel(brandId: 'realme', name: 'Realme C21'),
  DeviceModel(brandId: 'realme', name: 'Realme C15'),
  DeviceModel(brandId: 'realme', name: 'Realme C11'),
  DeviceModel(brandId: 'realme', name: 'Realme Narzo 70 Pro'),
  DeviceModel(brandId: 'realme', name: 'Realme Narzo 70'),
  DeviceModel(brandId: 'realme', name: 'Realme Narzo 60'),
  DeviceModel(brandId: 'realme', name: 'Realme Narzo 50'),

  // ═══════════════════════════════════════════════
  //  Vivo
  // ═══════════════════════════════════════════════
  DeviceModel(brandId: 'vivo', name: 'Vivo X200 Pro'),
  DeviceModel(brandId: 'vivo', name: 'Vivo X200'),
  DeviceModel(brandId: 'vivo', name: 'Vivo X100 Pro'),
  DeviceModel(brandId: 'vivo', name: 'Vivo X100'),
  DeviceModel(brandId: 'vivo', name: 'Vivo X90 Pro'),
  DeviceModel(brandId: 'vivo', name: 'Vivo X90'),
  DeviceModel(brandId: 'vivo', name: 'Vivo X80 Pro'),
  DeviceModel(brandId: 'vivo', name: 'Vivo X80'),
  DeviceModel(brandId: 'vivo', name: 'Vivo X70 Pro'),
  DeviceModel(brandId: 'vivo', name: 'Vivo X70'),
  DeviceModel(brandId: 'vivo', name: 'Vivo V40 Pro'),
  DeviceModel(brandId: 'vivo', name: 'Vivo V40'),
  DeviceModel(brandId: 'vivo', name: 'Vivo V40 SE'),
  DeviceModel(brandId: 'vivo', name: 'Vivo V30 Pro'),
  DeviceModel(brandId: 'vivo', name: 'Vivo V30'),
  DeviceModel(brandId: 'vivo', name: 'Vivo V30 Lite'),
  DeviceModel(brandId: 'vivo', name: 'Vivo V29 Pro'),
  DeviceModel(brandId: 'vivo', name: 'Vivo V29'),
  DeviceModel(brandId: 'vivo', name: 'Vivo V29e'),
  DeviceModel(brandId: 'vivo', name: 'Vivo V27 Pro'),
  DeviceModel(brandId: 'vivo', name: 'Vivo V27'),
  DeviceModel(brandId: 'vivo', name: 'Vivo V25 Pro'),
  DeviceModel(brandId: 'vivo', name: 'Vivo V25'),
  DeviceModel(brandId: 'vivo', name: 'Vivo V23 Pro'),
  DeviceModel(brandId: 'vivo', name: 'Vivo V23'),
  DeviceModel(brandId: 'vivo', name: 'Vivo V21'),
  DeviceModel(brandId: 'vivo', name: 'Vivo V20'),
  DeviceModel(brandId: 'vivo', name: 'Vivo V19'),
  DeviceModel(brandId: 'vivo', name: 'Vivo Y100'),
  DeviceModel(brandId: 'vivo', name: 'Vivo Y78+'),
  DeviceModel(brandId: 'vivo', name: 'Vivo Y78'),
  DeviceModel(brandId: 'vivo', name: 'Vivo Y77'),
  DeviceModel(brandId: 'vivo', name: 'Vivo Y76'),
  DeviceModel(brandId: 'vivo', name: 'Vivo Y75'),
  DeviceModel(brandId: 'vivo', name: 'Vivo Y73'),
  DeviceModel(brandId: 'vivo', name: 'Vivo Y72'),
  DeviceModel(brandId: 'vivo', name: 'Vivo Y70'),
  DeviceModel(brandId: 'vivo', name: 'Vivo Y56'),
  DeviceModel(brandId: 'vivo', name: 'Vivo Y55'),
  DeviceModel(brandId: 'vivo', name: 'Vivo Y53s'),
  DeviceModel(brandId: 'vivo', name: 'Vivo Y53'),
  DeviceModel(brandId: 'vivo', name: 'Vivo Y52'),
  DeviceModel(brandId: 'vivo', name: 'Vivo Y51'),
  DeviceModel(brandId: 'vivo', name: 'Vivo Y50'),
  DeviceModel(brandId: 'vivo', name: 'Vivo Y36'),
  DeviceModel(brandId: 'vivo', name: 'Vivo Y35'),
  DeviceModel(brandId: 'vivo', name: 'Vivo Y33s'),
  DeviceModel(brandId: 'vivo', name: 'Vivo Y33'),
  DeviceModel(brandId: 'vivo', name: 'Vivo Y31'),
  DeviceModel(brandId: 'vivo', name: 'Vivo Y30'),
  DeviceModel(brandId: 'vivo', name: 'Vivo Y28'),
  DeviceModel(brandId: 'vivo', name: 'Vivo Y27'),
  DeviceModel(brandId: 'vivo', name: 'Vivo Y22'),
  DeviceModel(brandId: 'vivo', name: 'Vivo Y21'),
  DeviceModel(brandId: 'vivo', name: 'Vivo Y20'),
  DeviceModel(brandId: 'vivo', name: 'Vivo Y17s'),
  DeviceModel(brandId: 'vivo', name: 'Vivo Y17'),
  DeviceModel(brandId: 'vivo', name: 'Vivo Y16'),
  DeviceModel(brandId: 'vivo', name: 'Vivo Y15'),
  DeviceModel(brandId: 'vivo', name: 'Vivo Y12'),
  DeviceModel(brandId: 'vivo', name: 'Vivo Y11'),
  DeviceModel(brandId: 'vivo', name: 'Vivo Y02'),

  // ═══════════════════════════════════════════════
  //  Infinix
  // ═══════════════════════════════════════════════
  DeviceModel(brandId: 'infinix', name: 'Infinix Zero 40 5G'),
  DeviceModel(brandId: 'infinix', name: 'Infinix Zero 40 4G'),
  DeviceModel(brandId: 'infinix', name: 'Infinix Zero 30 5G'),
  DeviceModel(brandId: 'infinix', name: 'Infinix Zero 30 4G'),
  DeviceModel(brandId: 'infinix', name: 'Infinix Zero 20'),
  DeviceModel(brandId: 'infinix', name: 'Infinix Note 50 Pro+'),
  DeviceModel(brandId: 'infinix', name: 'Infinix Note 50 Pro'),
  DeviceModel(brandId: 'infinix', name: 'Infinix Note 50'),
  DeviceModel(brandId: 'infinix', name: 'Infinix Note 40 Pro+'),
  DeviceModel(brandId: 'infinix', name: 'Infinix Note 40 Pro'),
  DeviceModel(brandId: 'infinix', name: 'Infinix Note 40'),
  DeviceModel(brandId: 'infinix', name: 'Infinix Note 40X'),
  DeviceModel(brandId: 'infinix', name: 'Infinix Note 30 Pro'),
  DeviceModel(brandId: 'infinix', name: 'Infinix Note 30'),
  DeviceModel(brandId: 'infinix', name: 'Infinix Note 30 VIP'),
  DeviceModel(brandId: 'infinix', name: 'Infinix Note 12 Pro'),
  DeviceModel(brandId: 'infinix', name: 'Infinix Note 12'),
  DeviceModel(brandId: 'infinix', name: 'Infinix Note 11'),
  DeviceModel(brandId: 'infinix', name: 'Infinix Note 10 Pro'),
  DeviceModel(brandId: 'infinix', name: 'Infinix Note 10'),
  DeviceModel(brandId: 'infinix', name: 'Infinix Note 8'),
  DeviceModel(brandId: 'infinix', name: 'Infinix Note 7'),
  DeviceModel(brandId: 'infinix', name: 'Infinix Hot 50 Pro+'),
  DeviceModel(brandId: 'infinix', name: 'Infinix Hot 50 Pro'),
  DeviceModel(brandId: 'infinix', name: 'Infinix Hot 50'),
  DeviceModel(brandId: 'infinix', name: 'Infinix Hot 50i'),
  DeviceModel(brandId: 'infinix', name: 'Infinix Hot 40 Pro'),
  DeviceModel(brandId: 'infinix', name: 'Infinix Hot 40'),
  DeviceModel(brandId: 'infinix', name: 'Infinix Hot 40i'),
  DeviceModel(brandId: 'infinix', name: 'Infinix Hot 30'),
  DeviceModel(brandId: 'infinix', name: 'Infinix Hot 30i'),
  DeviceModel(brandId: 'infinix', name: 'Infinix Hot 30 Play'),
  DeviceModel(brandId: 'infinix', name: 'Infinix Hot 20'),
  DeviceModel(brandId: 'infinix', name: 'Infinix Hot 20i'),
  DeviceModel(brandId: 'infinix', name: 'Infinix Hot 20 Play'),
  DeviceModel(brandId: 'infinix', name: 'Infinix Hot 12'),
  DeviceModel(brandId: 'infinix', name: 'Infinix Hot 12i'),
  DeviceModel(brandId: 'infinix', name: 'Infinix Hot 11'),
  DeviceModel(brandId: 'infinix', name: 'Infinix Hot 10'),
  DeviceModel(brandId: 'infinix', name: 'Infinix Hot 9'),
  DeviceModel(brandId: 'infinix', name: 'Infinix Smart 9'),
  DeviceModel(brandId: 'infinix', name: 'Infinix Smart 8'),
  DeviceModel(brandId: 'infinix', name: 'Infinix Smart 7'),
  DeviceModel(brandId: 'infinix', name: 'Infinix Smart 6'),
  DeviceModel(brandId: 'infinix', name: 'Infinix Smart 5'),

  // ═══════════════════════════════════════════════
  //  Tecno
  // ═══════════════════════════════════════════════
  DeviceModel(brandId: 'tecno', name: 'Tecno Phantom V Fold 2'),
  DeviceModel(brandId: 'tecno', name: 'Tecno Phantom V Flip 2'),
  DeviceModel(brandId: 'tecno', name: 'Tecno Phantom X2 Pro'),
  DeviceModel(brandId: 'tecno', name: 'Tecno Phantom X2'),
  DeviceModel(brandId: 'tecno', name: 'Tecno Camon 30 Pro'),
  DeviceModel(brandId: 'tecno', name: 'Tecno Camon 30'),
  DeviceModel(brandId: 'tecno', name: 'Tecno Camon 30S'),
  DeviceModel(brandId: 'tecno', name: 'Tecno Camon 20 Pro'),
  DeviceModel(brandId: 'tecno', name: 'Tecno Camon 20'),
  DeviceModel(brandId: 'tecno', name: 'Tecno Camon 19 Pro'),
  DeviceModel(brandId: 'tecno', name: 'Tecno Camon 19'),
  DeviceModel(brandId: 'tecno', name: 'Tecno Camon 18'),
  DeviceModel(brandId: 'tecno', name: 'Tecno Camon 17'),
  DeviceModel(brandId: 'tecno', name: 'Tecno Camon 16'),
  DeviceModel(brandId: 'tecno', name: 'Tecno Spark 20 Pro+'),
  DeviceModel(brandId: 'tecno', name: 'Tecno Spark 20 Pro'),
  DeviceModel(brandId: 'tecno', name: 'Tecno Spark 20'),
  DeviceModel(brandId: 'tecno', name: 'Tecno Spark 20C'),
  DeviceModel(brandId: 'tecno', name: 'Tecno Spark 10 Pro'),
  DeviceModel(brandId: 'tecno', name: 'Tecno Spark 10'),
  DeviceModel(brandId: 'tecno', name: 'Tecno Spark 9'),
  DeviceModel(brandId: 'tecno', name: 'Tecno Spark 8'),
  DeviceModel(brandId: 'tecno', name: 'Tecno Spark 7'),
  DeviceModel(brandId: 'tecno', name: 'Tecno Pova 6 Pro'),
  DeviceModel(brandId: 'tecno', name: 'Tecno Pova 6'),
  DeviceModel(brandId: 'tecno', name: 'Tecno Pova 5 Pro'),
  DeviceModel(brandId: 'tecno', name: 'Tecno Pova 5'),
  DeviceModel(brandId: 'tecno', name: 'Tecno Pova 4'),
  DeviceModel(brandId: 'tecno', name: 'Tecno Pova 3'),
  DeviceModel(brandId: 'tecno', name: 'Tecno Pova 2'),

  // ═══════════════════════════════════════════════
  //  Itel
  // ═══════════════════════════════════════════════
  DeviceModel(brandId: 'itel', name: 'Itel S24'),
  DeviceModel(brandId: 'itel', name: 'Itel S23+'),
  DeviceModel(brandId: 'itel', name: 'Itel S23'),
  DeviceModel(brandId: 'itel', name: 'Itel P55+'),
  DeviceModel(brandId: 'itel', name: 'Itel P55'),
  DeviceModel(brandId: 'itel', name: 'Itel P40'),
  DeviceModel(brandId: 'itel', name: 'Itel P38'),
  DeviceModel(brandId: 'itel', name: 'Itel A70'),
  DeviceModel(brandId: 'itel', name: 'Itel A60'),
  DeviceModel(brandId: 'itel', name: 'Itel A49'),

  // ═══════════════════════════════════════════════
  //  Nokia
  // ═══════════════════════════════════════════════
  DeviceModel(brandId: 'nokia', name: 'Nokia X30'),
  DeviceModel(brandId: 'nokia', name: 'Nokia X20'),
  DeviceModel(brandId: 'nokia', name: 'Nokia X10'),
  DeviceModel(brandId: 'nokia', name: 'Nokia G60'),
  DeviceModel(brandId: 'nokia', name: 'Nokia G50'),
  DeviceModel(brandId: 'nokia', name: 'Nokia G42'),
  DeviceModel(brandId: 'nokia', name: 'Nokia G21'),
  DeviceModel(brandId: 'nokia', name: 'Nokia G20'),
  DeviceModel(brandId: 'nokia', name: 'Nokia C32'),
  DeviceModel(brandId: 'nokia', name: 'Nokia C31'),
  DeviceModel(brandId: 'nokia', name: 'Nokia C21'),
  DeviceModel(brandId: 'nokia', name: 'Nokia C12'),
  DeviceModel(brandId: 'nokia', name: 'Nokia 8.3 5G'),
  DeviceModel(brandId: 'nokia', name: 'Nokia 7.2'),
  DeviceModel(brandId: 'nokia', name: 'Nokia 6.2'),
  DeviceModel(brandId: 'nokia', name: 'Nokia 5.4'),
  DeviceModel(brandId: 'nokia', name: 'Nokia 3.4'),
  DeviceModel(brandId: 'nokia', name: 'Nokia 2.4'),
  DeviceModel(brandId: 'nokia', name: 'Nokia 1.4'),
  DeviceModel(brandId: 'nokia', name: 'Nokia 105'),
  DeviceModel(brandId: 'nokia', name: 'Nokia 110'),
  DeviceModel(brandId: 'nokia', name: 'Nokia 225'),

  // ═══════════════════════════════════════════════
  //  Huawei
  // ═══════════════════════════════════════════════
  DeviceModel(brandId: 'huawei', name: 'Huawei Mate 70 Pro'),
  DeviceModel(brandId: 'huawei', name: 'Huawei Mate 70'),
  DeviceModel(brandId: 'huawei', name: 'Huawei Mate 60 Pro'),
  DeviceModel(brandId: 'huawei', name: 'Huawei Mate 60'),
  DeviceModel(brandId: 'huawei', name: 'Huawei Mate 50 Pro'),
  DeviceModel(brandId: 'huawei', name: 'Huawei Mate 50'),
  DeviceModel(brandId: 'huawei', name: 'Huawei Mate 40 Pro'),
  DeviceModel(brandId: 'huawei', name: 'Huawei Mate 40'),
  DeviceModel(brandId: 'huawei', name: 'Huawei P70 Pro'),
  DeviceModel(brandId: 'huawei', name: 'Huawei P70'),
  DeviceModel(brandId: 'huawei', name: 'Huawei P60 Pro'),
  DeviceModel(brandId: 'huawei', name: 'Huawei P60'),
  DeviceModel(brandId: 'huawei', name: 'Huawei P50 Pro'),
  DeviceModel(brandId: 'huawei', name: 'Huawei P50'),
  DeviceModel(brandId: 'huawei', name: 'Huawei P40 Pro'),
  DeviceModel(brandId: 'huawei', name: 'Huawei P40'),
  DeviceModel(brandId: 'huawei', name: 'Huawei P30 Pro'),
  DeviceModel(brandId: 'huawei', name: 'Huawei P30'),
  DeviceModel(brandId: 'huawei', name: 'Huawei Nova 13 Pro'),
  DeviceModel(brandId: 'huawei', name: 'Huawei Nova 13'),
  DeviceModel(brandId: 'huawei', name: 'Huawei Nova 12'),
  DeviceModel(brandId: 'huawei', name: 'Huawei Nova 11'),
  DeviceModel(brandId: 'huawei', name: 'Huawei Nova 10'),
  DeviceModel(brandId: 'huawei', name: 'Huawei Nova 9'),
  DeviceModel(brandId: 'huawei', name: 'Huawei Nova 8'),
  DeviceModel(brandId: 'huawei', name: 'Huawei Nova 7'),
  DeviceModel(brandId: 'huawei', name: 'Huawei Y9 Prime'),
  DeviceModel(brandId: 'huawei', name: 'Huawei Y9'),
  DeviceModel(brandId: 'huawei', name: 'Huawei Y7'),
  DeviceModel(brandId: 'huawei', name: 'Huawei Y6'),
  DeviceModel(brandId: 'huawei', name: 'Huawei Y5'),
  // Huawei MatePad
  DeviceModel(brandId: 'huawei', name: 'Huawei MatePad Pro 13.2'),
  DeviceModel(brandId: 'huawei', name: 'Huawei MatePad 11.5'),
  DeviceModel(brandId: 'huawei', name: 'Huawei MatePad SE 11'),
  DeviceModel(brandId: 'huawei', name: 'Huawei MatePad 10.4'),

  // ═══════════════════════════════════════════════
  //  OnePlus
  // ═══════════════════════════════════════════════
  DeviceModel(brandId: 'oneplus', name: 'OnePlus 13'),
  DeviceModel(brandId: 'oneplus', name: 'OnePlus 13R'),
  DeviceModel(brandId: 'oneplus', name: 'OnePlus 12'),
  DeviceModel(brandId: 'oneplus', name: 'OnePlus 12R'),
  DeviceModel(brandId: 'oneplus', name: 'OnePlus 11'),
  DeviceModel(brandId: 'oneplus', name: 'OnePlus 10 Pro'),
  DeviceModel(brandId: 'oneplus', name: 'OnePlus 10T'),
  DeviceModel(brandId: 'oneplus', name: 'OnePlus 9 Pro'),
  DeviceModel(brandId: 'oneplus', name: 'OnePlus 9'),
  DeviceModel(brandId: 'oneplus', name: 'OnePlus 8 Pro'),
  DeviceModel(brandId: 'oneplus', name: 'OnePlus 8'),
  DeviceModel(brandId: 'oneplus', name: 'OnePlus 8T'),
  DeviceModel(brandId: 'oneplus', name: 'OnePlus 7 Pro'),
  DeviceModel(brandId: 'oneplus', name: 'OnePlus 7T Pro'),
  DeviceModel(brandId: 'oneplus', name: 'OnePlus Nord 4'),
  DeviceModel(brandId: 'oneplus', name: 'OnePlus Nord 3'),
  DeviceModel(brandId: 'oneplus', name: 'OnePlus Nord CE 4'),
  DeviceModel(brandId: 'oneplus', name: 'OnePlus Nord CE 3'),
  DeviceModel(brandId: 'oneplus', name: 'OnePlus Nord 2'),
  DeviceModel(brandId: 'oneplus', name: 'OnePlus Nord N30'),

  // ═══════════════════════════════════════════════
  //  Motorola
  // ═══════════════════════════════════════════════
  DeviceModel(brandId: 'motorola', name: 'Motorola Edge 50 Ultra'),
  DeviceModel(brandId: 'motorola', name: 'Motorola Edge 50 Pro'),
  DeviceModel(brandId: 'motorola', name: 'Motorola Edge 50 Fusion'),
  DeviceModel(brandId: 'motorola', name: 'Motorola Edge 40 Pro'),
  DeviceModel(brandId: 'motorola', name: 'Motorola Edge 40'),
  DeviceModel(brandId: 'motorola', name: 'Motorola Edge 40 Neo'),
  DeviceModel(brandId: 'motorola', name: 'Motorola Edge 30 Ultra'),
  DeviceModel(brandId: 'motorola', name: 'Motorola Edge 30 Pro'),
  DeviceModel(brandId: 'motorola', name: 'Motorola Edge 30'),
  DeviceModel(brandId: 'motorola', name: 'Motorola Edge 20'),
  DeviceModel(brandId: 'motorola', name: 'Moto G85'),
  DeviceModel(brandId: 'motorola', name: 'Moto G84'),
  DeviceModel(brandId: 'motorola', name: 'Moto G73'),
  DeviceModel(brandId: 'motorola', name: 'Moto G72'),
  DeviceModel(brandId: 'motorola', name: 'Moto G62'),
  DeviceModel(brandId: 'motorola', name: 'Moto G52'),
  DeviceModel(brandId: 'motorola', name: 'Moto G42'),
  DeviceModel(brandId: 'motorola', name: 'Moto G32'),
  DeviceModel(brandId: 'motorola', name: 'Moto G31'),
  DeviceModel(brandId: 'motorola', name: 'Moto G22'),
  DeviceModel(brandId: 'motorola', name: 'Moto G Power'),
  DeviceModel(brandId: 'motorola', name: 'Moto E13'),
  DeviceModel(brandId: 'motorola', name: 'Moto E22'),

  // ═══════════════════════════════════════════════
  //  Google
  // ═══════════════════════════════════════════════
  DeviceModel(brandId: 'google', name: 'Google Pixel 9 Pro XL'),
  DeviceModel(brandId: 'google', name: 'Google Pixel 9 Pro'),
  DeviceModel(brandId: 'google', name: 'Google Pixel 9'),
  DeviceModel(brandId: 'google', name: 'Google Pixel 9 Pro Fold'),
  DeviceModel(brandId: 'google', name: 'Google Pixel 8 Pro'),
  DeviceModel(brandId: 'google', name: 'Google Pixel 8'),
  DeviceModel(brandId: 'google', name: 'Google Pixel 8a'),
  DeviceModel(brandId: 'google', name: 'Google Pixel 7 Pro'),
  DeviceModel(brandId: 'google', name: 'Google Pixel 7'),
  DeviceModel(brandId: 'google', name: 'Google Pixel 7a'),
  DeviceModel(brandId: 'google', name: 'Google Pixel 6 Pro'),
  DeviceModel(brandId: 'google', name: 'Google Pixel 6'),
  DeviceModel(brandId: 'google', name: 'Google Pixel 6a'),

  // ═══════════════════════════════════════════════
  //  Nothing
  // ═══════════════════════════════════════════════
  DeviceModel(brandId: 'nothing', name: 'Nothing Phone (2a) Plus'),
  DeviceModel(brandId: 'nothing', name: 'Nothing Phone (2a)'),
  DeviceModel(brandId: 'nothing', name: 'Nothing Phone (2)'),
  DeviceModel(brandId: 'nothing', name: 'Nothing Phone (1)'),

  // ═══════════════════════════════════════════════
  //  Lenovo (Tablets + Laptops)
  // ═══════════════════════════════════════════════
  DeviceModel(brandId: 'lenovo', name: 'Lenovo Tab P12'),
  DeviceModel(brandId: 'lenovo', name: 'Lenovo Tab P11 Pro'),
  DeviceModel(brandId: 'lenovo', name: 'Lenovo Tab P11'),
  DeviceModel(brandId: 'lenovo', name: 'Lenovo Tab M11'),
  DeviceModel(brandId: 'lenovo', name: 'Lenovo Tab M10'),
  DeviceModel(brandId: 'lenovo', name: 'Lenovo Tab M9'),
  DeviceModel(brandId: 'lenovo', name: 'Lenovo Tab M8'),
  DeviceModel(brandId: 'lenovo', name: 'Lenovo Yoga 9i'),
  DeviceModel(brandId: 'lenovo', name: 'Lenovo Yoga 7i'),
  DeviceModel(brandId: 'lenovo', name: 'Lenovo Yoga Slim 7'),
  DeviceModel(brandId: 'lenovo', name: 'Lenovo ThinkPad X1 Carbon'),
  DeviceModel(brandId: 'lenovo', name: 'Lenovo ThinkPad T14'),
  DeviceModel(brandId: 'lenovo', name: 'Lenovo ThinkPad E14'),
  DeviceModel(brandId: 'lenovo', name: 'Lenovo IdeaPad 3'),
  DeviceModel(brandId: 'lenovo', name: 'Lenovo IdeaPad 5'),
  DeviceModel(brandId: 'lenovo', name: 'Lenovo Legion 5'),
  DeviceModel(brandId: 'lenovo', name: 'Lenovo Legion 7'),

  // ═══════════════════════════════════════════════
  //  HP
  // ═══════════════════════════════════════════════
  DeviceModel(brandId: 'hp', name: 'HP Spectre x360 14'),
  DeviceModel(brandId: 'hp', name: 'HP Spectre x360 16'),
  DeviceModel(brandId: 'hp', name: 'HP Envy x360 13'),
  DeviceModel(brandId: 'hp', name: 'HP Envy x360 15'),
  DeviceModel(brandId: 'hp', name: 'HP Pavilion 14'),
  DeviceModel(brandId: 'hp', name: 'HP Pavilion 15'),
  DeviceModel(brandId: 'hp', name: 'HP Pavilion Gaming 15'),
  DeviceModel(brandId: 'hp', name: 'HP EliteBook 840'),
  DeviceModel(brandId: 'hp', name: 'HP EliteBook 850'),
  DeviceModel(brandId: 'hp', name: 'HP ProBook 450'),
  DeviceModel(brandId: 'hp', name: 'HP ProBook 440'),
  DeviceModel(brandId: 'hp', name: 'HP Omen 15'),
  DeviceModel(brandId: 'hp', name: 'HP Omen 16'),
  DeviceModel(brandId: 'hp', name: 'HP Victus 15'),
  DeviceModel(brandId: 'hp', name: 'HP Victus 16'),
  DeviceModel(brandId: 'hp', name: 'HP 15s'),
  DeviceModel(brandId: 'hp', name: 'HP 14s'),

  // ═══════════════════════════════════════════════
  //  Dell
  // ═══════════════════════════════════════════════
  DeviceModel(brandId: 'dell', name: 'Dell XPS 13'),
  DeviceModel(brandId: 'dell', name: 'Dell XPS 15'),
  DeviceModel(brandId: 'dell', name: 'Dell XPS 17'),
  DeviceModel(brandId: 'dell', name: 'Dell Latitude 3420'),
  DeviceModel(brandId: 'dell', name: 'Dell Latitude 5420'),
  DeviceModel(brandId: 'dell', name: 'Dell Latitude 7420'),
  DeviceModel(brandId: 'dell', name: 'Dell Inspiron 15'),
  DeviceModel(brandId: 'dell', name: 'Dell Inspiron 14'),
  DeviceModel(brandId: 'dell', name: 'Dell Inspiron 13'),
  DeviceModel(brandId: 'dell', name: 'Dell Vostro 3400'),
  DeviceModel(brandId: 'dell', name: 'Dell Vostro 3500'),
  DeviceModel(brandId: 'dell', name: 'Dell Vostro 5410'),
  DeviceModel(brandId: 'dell', name: 'Dell G15'),
  DeviceModel(brandId: 'dell', name: 'Dell G16'),
  DeviceModel(brandId: 'dell', name: 'Dell Alienware m15'),
  DeviceModel(brandId: 'dell', name: 'Dell Alienware m16'),
  DeviceModel(brandId: 'dell', name: 'Dell Alienware x14'),
  DeviceModel(brandId: 'dell', name: 'Dell Alienware x16'),

  // ═══════════════════════════════════════════════
  //  Asus
  // ═══════════════════════════════════════════════
  DeviceModel(brandId: 'asus', name: 'Asus ZenBook 14'),
  DeviceModel(brandId: 'asus', name: 'Asus ZenBook 15'),
  DeviceModel(brandId: 'asus', name: 'Asus ZenBook Duo'),
  DeviceModel(brandId: 'asus', name: 'Asus VivoBook 15'),
  DeviceModel(brandId: 'asus', name: 'Asus VivoBook 14'),
  DeviceModel(brandId: 'asus', name: 'Asus VivoBook S14'),
  DeviceModel(brandId: 'asus', name: 'Asus VivoBook S15'),
  DeviceModel(brandId: 'asus', name: 'Asus TUF Gaming F15'),
  DeviceModel(brandId: 'asus', name: 'Asus TUF Gaming F17'),
  DeviceModel(brandId: 'asus', name: 'Asus TUF Gaming A15'),
  DeviceModel(brandId: 'asus', name: 'Asus ROG Strix G15'),
  DeviceModel(brandId: 'asus', name: 'Asus ROG Strix G16'),
  DeviceModel(brandId: 'asus', name: 'Asus ROG Zephyrus G14'),
  DeviceModel(brandId: 'asus', name: 'Asus ROG Zephyrus G15'),
  DeviceModel(brandId: 'asus', name: 'Asus ROG Zephyrus G16'),
  DeviceModel(brandId: 'asus', name: 'Asus ROG Flow X13'),

  // ═══════════════════════════════════════════════
  //  Acer
  // ═══════════════════════════════════════════════
  DeviceModel(brandId: 'acer', name: 'Acer Swift 3'),
  DeviceModel(brandId: 'acer', name: 'Acer Swift 5'),
  DeviceModel(brandId: 'acer', name: 'Acer Swift X'),
  DeviceModel(brandId: 'acer', name: 'Acer Aspire 3'),
  DeviceModel(brandId: 'acer', name: 'Acer Aspire 5'),
  DeviceModel(brandId: 'acer', name: 'Acer Aspire 7'),
  DeviceModel(brandId: 'acer', name: 'Acer Nitro 5'),
  DeviceModel(brandId: 'acer', name: 'Acer Nitro 7'),
  DeviceModel(brandId: 'acer', name: 'Acer Predator Helios 300'),
  DeviceModel(brandId: 'acer', name: 'Acer Predator Helios 16'),
  DeviceModel(brandId: 'acer', name: 'Acer Predator Triton 300'),
  DeviceModel(brandId: 'acer', name: 'Acer Predator Triton 500'),

  // ═══════════════════════════════════════════════
  //  MSI
  // ═══════════════════════════════════════════════
  DeviceModel(brandId: 'msi', name: 'MSI Modern 14'),
  DeviceModel(brandId: 'msi', name: 'MSI Modern 15'),
  DeviceModel(brandId: 'msi', name: 'MSI Prestige 14'),
  DeviceModel(brandId: 'msi', name: 'MSI Prestige 15'),
  DeviceModel(brandId: 'msi', name: 'MSI GF63 Thin'),
  DeviceModel(brandId: 'msi', name: 'MSI GF65 Thin'),
  DeviceModel(brandId: 'msi', name: 'MSI GF75 Thin'),
  DeviceModel(brandId: 'msi', name: 'MSI Katana GF66'),
  DeviceModel(brandId: 'msi', name: 'MSI Katana GF76'),
  DeviceModel(brandId: 'msi', name: 'MSI Pulse GL66'),
  DeviceModel(brandId: 'msi', name: 'MSI Pulse GL76'),
  DeviceModel(brandId: 'msi', name: 'MSI Stealth 15M'),
  DeviceModel(brandId: 'msi', name: 'MSI Stealth 16'),
  DeviceModel(brandId: 'msi', name: 'MSI Raider GE66'),
  DeviceModel(brandId: 'msi', name: 'MSI Raider GE76'),

  // ═══════════════════════════════════════════════
  //  Toshiba
  // ═══════════════════════════════════════════════
  DeviceModel(brandId: 'toshiba', name: 'Toshiba Satellite C55'),
  DeviceModel(brandId: 'toshiba', name: 'Toshiba Satellite L50'),
  DeviceModel(brandId: 'toshiba', name: 'Toshiba Satellite Pro'),
  DeviceModel(brandId: 'toshiba', name: 'Toshiba Portege'),
  DeviceModel(brandId: 'toshiba', name: 'Toshiba Tecra'),

  // ═══════════════════════════════════════════════
  //  Microsoft Surface
  // ═══════════════════════════════════════════════
  DeviceModel(brandId: 'microsoft', name: 'Surface Pro 11'),
  DeviceModel(brandId: 'microsoft', name: 'Surface Pro 10'),
  DeviceModel(brandId: 'microsoft', name: 'Surface Pro 9'),
  DeviceModel(brandId: 'microsoft', name: 'Surface Pro 8'),
  DeviceModel(brandId: 'microsoft', name: 'Surface Pro 7'),
  DeviceModel(brandId: 'microsoft', name: 'Surface Laptop 7'),
  DeviceModel(brandId: 'microsoft', name: 'Surface Laptop 6'),
  DeviceModel(brandId: 'microsoft', name: 'Surface Laptop 5'),
  DeviceModel(brandId: 'microsoft', name: 'Surface Laptop Studio'),
  DeviceModel(brandId: 'microsoft', name: 'Surface Go 4'),
  DeviceModel(brandId: 'microsoft', name: 'Surface Go 3'),
];

// ═══════════════════════════════════════════════════════════
//  Helpers
// ═══════════════════════════════════════════════════════════

/// موديلات شركة معينة
List<DeviceModel> modelsByBrand(String brandId) {
  return deviceModels.where((m) => m.brandId == brandId).toList();
}

/// أسماء موديلات شركة معينة (مرتبة)
List<String> modelNamesByBrand(String brandId) {
  final list = modelsByBrand(brandId).map((m) => m.name).toList();
  list.sort();
  return list;
}

/// بحث في موديلات شركة معينة (Autocomplete)
List<String> searchModels(
  String query, {
  String? brandId,
}) {
  final q = query.trim().toLowerCase();
  final source = brandId != null
      ? deviceModels.where((m) => m.brandId == brandId)
      : deviceModels;

  if (q.isEmpty) {
    final list = source.map((m) => m.name).toList();
    list.sort();
    return list;
  }

  final list = source
      .where((m) => m.name.toLowerCase().contains(q))
      .map((m) => m.name)
      .toList();
  list.sort();
  return list;
}

/// هل الموديل موجود؟
bool modelExists(String brandId, String modelName) {
  final lower = modelName.toLowerCase().trim();
  return deviceModels.any(
    (m) => m.brandId == brandId && m.name.toLowerCase() == lower,
  );
}
