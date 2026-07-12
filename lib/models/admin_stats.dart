class AdminStats {
  final int totalUsers;
  final int totalDealers;
  final int totalCars;
  final int pendingCars;
  final int approvedCars;
  final int soldCars;
  final double platformRevenue;
  final int todayVisits;

  const AdminStats({
    required this.totalUsers,
    required this.totalDealers,
    required this.totalCars,
    required this.pendingCars,
    required this.approvedCars,
    required this.soldCars,
    required this.platformRevenue,
    required this.todayVisits,
  });
}