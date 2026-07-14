import 'package:cloud_firestore/cloud_firestore.dart';

/// Модель настроек администратора
class AdminSettings {
  final bool notificationsEnabled;
  final bool emailNotificationsEnabled;
  final bool pushNotificationsEnabled;
  final bool maintenanceMode;
  final bool requireUserVerification;
  final bool moderateListings;
  final String language;
  final String themeMode; // 'light', 'dark', 'system'
  final int itemsPerPage;
  final DateTime? updatedAt;
  final String? updatedBy;

  AdminSettings({
    this.notificationsEnabled = true,
    this.emailNotificationsEnabled = true,
    this.pushNotificationsEnabled = true,
    this.maintenanceMode = false,
    this.requireUserVerification = false,
    this.moderateListings = false,
    this.language = 'ru',
    this.themeMode = 'system',
    this.itemsPerPage = 20,
    this.updatedAt,
    this.updatedBy,
  });

  /// Создать из Firestore документа
  factory AdminSettings.fromMap(Map<String, dynamic> map) {
    return AdminSettings(
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      emailNotificationsEnabled: map['emailNotificationsEnabled'] ?? true,
      pushNotificationsEnabled: map['pushNotificationsEnabled'] ?? true,
      maintenanceMode: map['maintenanceMode'] ?? false,
      requireUserVerification: map['requireUserVerification'] ?? false,
      moderateListings: map['moderateListings'] ?? false,
      language: map['language'] ?? 'ru',
      themeMode: map['themeMode'] ?? 'system',
      itemsPerPage: (map['itemsPerPage'] ?? 20).toInt(),
      updatedAt: _parseTimestamp(map['updatedAt']),
      updatedBy: map['updatedBy'],
    );
  }

  /// Преобразовать в Map для Firestore
  Map<String, dynamic> toMap() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'emailNotificationsEnabled': emailNotificationsEnabled,
      'pushNotificationsEnabled': pushNotificationsEnabled,
      'maintenanceMode': maintenanceMode,
      'requireUserVerification': requireUserVerification,
      'moderateListings': moderateListings,
      'language': language,
      'themeMode': themeMode,
      'itemsPerPage': itemsPerPage,
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
      if (updatedBy != null) 'updatedBy': updatedBy,
    };
  }

  /// Копия с изменениями
  AdminSettings copyWith({
    bool? notificationsEnabled,
    bool? emailNotificationsEnabled,
    bool? pushNotificationsEnabled,
    bool? maintenanceMode,
    bool? requireUserVerification,
    bool? moderateListings,
    String? language,
    String? themeMode,
    int? itemsPerPage,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return AdminSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotificationsEnabled:
          emailNotificationsEnabled ?? this.emailNotificationsEnabled,
      pushNotificationsEnabled:
          pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
      requireUserVerification:
          requireUserVerification ?? this.requireUserVerification,
      moderateListings: moderateListings ?? this.moderateListings,
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  /// Безопасное преобразование Timestamp/DateTime
  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  /// Значения по умолчанию
  static AdminSettings defaults() => AdminSettings();
}
