import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1_car_sales/models/admin_settings.dart';

void main() {
  test('admin settings safely parse Firestore values', () {
    final timestamp = Timestamp.fromDate(DateTime.utc(2026, 7, 25));
    final settings = AdminSettings.fromMap({
      'notificationsEnabled': false,
      'itemsPerPage': 40,
      'updatedAt': timestamp,
      'updatedBy': 'super-admin-id',
    });

    expect(settings.notificationsEnabled, isFalse);
    expect(settings.itemsPerPage, 40);
    expect(settings.updatedAt, timestamp.toDate());
    expect(settings.updatedBy, 'super-admin-id');
  });

  test('admin settings use safe defaults for missing values', () {
    final settings = AdminSettings.fromMap(const {});

    expect(settings.notificationsEnabled, isTrue);
    expect(settings.language, 'ru');
    expect(settings.themeMode, 'system');
    expect(settings.itemsPerPage, 20);
  });
}
