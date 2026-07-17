import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSettings {
  final bool notificationsEnabled;
  final bool emailNotifications;
  final bool pushNotifications;
  final bool maintenanceMode;
  final bool newUserApprovalRequired;
  final bool carModerationEnabled;
  final String selectedLanguage;
  final String selectedTheme;
  final int itemsPerPage;
  final double commissionRate;
  final String? bannerUrl;
  final List<String> supportedCountries;
  final List<String> categories;
  final DateTime? updatedAt;

  const AdminSettings({
    this.notificationsEnabled = true,
    this.emailNotifications = true,
    this.pushNotifications = false,
    this.maintenanceMode = false,
    this.newUserApprovalRequired = false,
    this.carModerationEnabled = true,
    this.selectedLanguage = 'ru',
    this.selectedTheme = 'system',
    this.itemsPerPage = 20,
    this.commissionRate = 0.05,
    this.bannerUrl,
    this.supportedCountries = const ['TJ', 'UZ', 'KG', 'KZ'],
    this.categories = const ['Седан', 'Внедорожник', 'Хэтчбек', 'Купе', 'Кабриолет'],
    this.updatedAt,
  });

  factory AdminSettings.defaults() {
    return const AdminSettings();
  }

  factory AdminSettings.fromMap(Map<String, dynamic> map) {
    return AdminSettings(
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      emailNotifications: map['emailNotifications'] ?? true,
      pushNotifications: map['pushNotifications'] ?? false,
      maintenanceMode: map['maintenanceMode'] ?? false,
      newUserApprovalRequired: map['newUserApprovalRequired'] ?? false,
      carModerationEnabled: map['carModerationEnabled'] ?? true,
      selectedLanguage: map['selectedLanguage'] ?? 'ru',
      selectedTheme: map['selectedTheme'] ?? 'system',
      itemsPerPage: map['itemsPerPage'] ?? 20,
      commissionRate: (map['commissionRate'] ?? 0.05).toDouble(),
      bannerUrl: map['bannerUrl'],
      supportedCountries: List<String>.from(map['supportedCountries'] ?? ['TJ', 'UZ', 'KG', 'KZ']),
      categories: List<String>.from(map['categories'] ?? ['Седан', 'Внедорожник', 'Хэтчбек', 'Купе', 'Кабриолет']),
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'emailNotifications': emailNotifications,
      'pushNotifications': pushNotifications,
      'maintenanceMode': maintenanceMode,
      'newUserApprovalRequired': newUserApprovalRequired,
      'carModerationEnabled': carModerationEnabled,
      'selectedLanguage': selectedLanguage,
      'selectedTheme': selectedTheme,
      'itemsPerPage': itemsPerPage,
      'commissionRate': commissionRate,
      'bannerUrl': bannerUrl,
      'supportedCountries': supportedCountries,
      'categories': categories,
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  factory AdminSettings.fromJson(Map<String, dynamic> json) => fromMap(json);
  Map<String, dynamic> toJson() => toMap();

  AdminSettings copyWith({
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? pushNotifications,
    bool? maintenanceMode,
    bool? newUserApprovalRequired,
    bool? carModerationEnabled,
    String? selectedLanguage,
    String? selectedTheme,
    int? itemsPerPage,
    double? commissionRate,
    String? bannerUrl,
    List<String>? supportedCountries,
    List<String>? categories,
    DateTime? updatedAt,
  }) {
    return AdminSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
      newUserApprovalRequired: newUserApprovalRequired ?? this.newUserApprovalRequired,
      carModerationEnabled: carModerationEnabled ?? this.carModerationEnabled,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      selectedTheme: selectedTheme ?? this.selectedTheme,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      commissionRate: commissionRate ?? this.commissionRate,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      supportedCountries: supportedCountries ?? this.supportedCountries,
      categories: categories ?? this.categories,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
