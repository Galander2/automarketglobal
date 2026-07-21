class AdminSettings {
  final bool notificationsEnabled;
  final bool emailNotificationsEnabled;
  final bool pushNotificationsEnabled;
  final bool maintenanceMode;
  final bool requireUserVerification;
  final bool moderateListings;
  final String language;
  final String themeMode;
  final int itemsPerPage;
  final DateTime? updatedAt;
  final String? updatedBy;

  const AdminSettings({
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

  factory AdminSettings.defaults() {
    return const AdminSettings();
  }

  factory AdminSettings.fromMap(Map<String, dynamic> map) {
    return AdminSettings(
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      emailNotificationsEnabled:
          map['emailNotificationsEnabled'] as bool? ?? true,
      pushNotificationsEnabled:
          map['pushNotificationsEnabled'] as bool? ?? true,
      maintenanceMode: map['maintenanceMode'] as bool? ?? false,
      requireUserVerification: map['requireUserVerification'] as bool? ?? false,
      moderateListings: map['moderateListings'] as bool? ?? false,
      language: map['language'] as String? ?? 'ru',
      themeMode: map['themeMode'] as String? ?? 'system',
      itemsPerPage: map['itemsPerPage'] as int? ?? 20,
      updatedAt: map['updatedAt'] as DateTime?,
      updatedBy: map['updatedBy'] as String?,
    );
  }

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
      if (updatedAt != null) 'updatedAt': updatedAt,
      if (updatedBy != null) 'updatedBy': updatedBy,
    };
  }

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
}
