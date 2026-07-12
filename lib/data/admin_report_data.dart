import '../models/admin_report.dart';

const List<AdminReport> adminReports = [
  AdminReport(
    id: 'users',
    title: 'Новые пользователи',
    value: '1280',
    subtitle: 'Всего зарегистрировано',
  ),
  AdminReport(
    id: 'dealers',
    title: 'Крупные дилеры',
    value: '36',
    subtitle: 'Проверенные компании',
  ),
  AdminReport(
    id: 'sales',
    title: 'Продажи',
    value: '214',
    subtitle: 'Автомобилей продано',
  ),
  AdminReport(
    id: 'revenue',
    title: 'Доход платформы',
    value: '18 650 \$',
    subtitle: 'Комиссия, реклама, premium',
  ),
  AdminReport(
    id: 'visits',
    title: 'Посещения сегодня',
    value: '742',
    subtitle: 'Активность пользователей',
  ),
  AdminReport(
    id: 'complaints',
    title: 'Жалобы',
    value: '12',
    subtitle: 'Требуют проверки',
  ),
];