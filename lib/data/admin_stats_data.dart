import '../models/admin_stats.dart';

class AdminStatsData {
  static AdminStats getStats() {
    return const AdminStats(
      totalUsers: 1250,
      totalDealers: 89,
      totalCars: 3420,
      pendingCars: 45,
      approvedCars: 3200,
      soldCars: 175,
      platformRevenue: 125000.0,
      todayVisits: 342,
    );
  }
}