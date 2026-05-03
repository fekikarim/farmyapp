class RoiOverview {
  final double totalInvestment;
  final double totalRevenue;
  final double netProfit;
  final double roiPercentage;

  RoiOverview({
    required this.totalInvestment,
    required this.totalRevenue,
    required this.netProfit,
    required this.roiPercentage,
  });

  factory RoiOverview.fromJson(Map<String, dynamic> json) {
    return RoiOverview(
      totalInvestment: (json['totalInvestment'] as num?)?.toDouble() ?? 0.0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      netProfit: (json['netProfit'] as num?)?.toDouble() ?? 0.0,
      roiPercentage: (json['roiPercentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class RoiCosts {
  final double rent;
  final double items;
  final double workers;
  final double total;

  RoiCosts({
    required this.rent,
    required this.items,
    required this.workers,
    required this.total,
  });

  factory RoiCosts.fromJson(Map<String, dynamic> json) {
    return RoiCosts(
      rent: (json['rent'] as num?)?.toDouble() ?? 0.0,
      items: (json['items'] as num?)?.toDouble() ?? 0.0,
      workers: (json['workers'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class RoiRentalBreakdown {
  final String id;
  final String landId;
  final String landName;
  final RoiCosts costs;
  final double revenue;
  final double netProfit;
  final double roiPercentage;

  RoiRentalBreakdown({
    required this.id,
    required this.landId,
    required this.landName,
    required this.costs,
    required this.revenue,
    required this.netProfit,
    required this.roiPercentage,
  });

  factory RoiRentalBreakdown.fromJson(Map<String, dynamic> json) {
    return RoiRentalBreakdown(
      id: json['id'] as String? ?? '',
      landId: json['landId'] as String? ?? '',
      landName: json['landName'] as String? ?? 'Unknown Land',
      costs: RoiCosts.fromJson(json['costs'] as Map<String, dynamic>? ?? {}),
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
      netProfit: (json['netProfit'] as num?)?.toDouble() ?? 0.0,
      roiPercentage: (json['roiPercentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class RoiDashboardData {
  final RoiOverview overview;
  final List<RoiRentalBreakdown> rentals;

  RoiDashboardData({
    required this.overview,
    required this.rentals,
  });

  factory RoiDashboardData.fromJson(Map<String, dynamic> json) {
    return RoiDashboardData(
      overview: RoiOverview.fromJson(json['overview'] as Map<String, dynamic>? ?? {}),
      rentals: (json['rentals'] as List<dynamic>?)
              ?.map((e) => RoiRentalBreakdown.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
