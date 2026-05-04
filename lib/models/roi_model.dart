class RoiOverview {
  final double totalInvestment;
  final double totalRevenue;
  final double netProfit;
  final double roiPercentage;
  
  // Product revenue breakdown
  final double productRevenue;
  final double rentalRevenue;
  final int totalProductsSold;
  final double averageProductMargin;
  
  // Profit calculation metadata
  final DateTime? lastCalculated;
  final String calculationVersion;

  RoiOverview({
    required this.totalInvestment,
    required this.totalRevenue,
    required this.netProfit,
    required this.roiPercentage,
    this.productRevenue = 0.0,
    this.rentalRevenue = 0.0,
    this.totalProductsSold = 0,
    this.averageProductMargin = 0.0,
    this.lastCalculated,
    this.calculationVersion = '1.0',
  });

  factory RoiOverview.fromJson(Map<String, dynamic> json) {
    return RoiOverview(
      totalInvestment: (json['totalInvestment'] as num?)?.toDouble() ?? 0.0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      netProfit: (json['netProfit'] as num?)?.toDouble() ?? 0.0,
      roiPercentage: (json['roiPercentage'] as num?)?.toDouble() ?? 0.0,
      productRevenue: (json['productRevenue'] as num?)?.toDouble() ?? 0.0,
      rentalRevenue: (json['rentalRevenue'] as num?)?.toDouble() ?? 0.0,
      totalProductsSold: (json['totalProductsSold'] as num?)?.toInt() ?? 0,
      averageProductMargin: (json['averageProductMargin'] as num?)?.toDouble() ?? 0.0,
      lastCalculated: json['lastCalculated'] != null 
          ? DateTime.tryParse(json['lastCalculated'] as String)
          : null,
      calculationVersion: json['calculationVersion'] as String? ?? '1.0',
    );
  }
  
  /// Calculate net profit dynamically including product revenue
  /// Formula: (Product Revenue + Rental Revenue) - Total Investment
  double calculateNetProfit() {
    return (productRevenue + rentalRevenue) - totalInvestment;
  }
  
  /// Calculate ROI percentage with precision
  /// Formula: ((Total Revenue - Investment) / Investment) * 100
  double calculateRoiPercentage() {
    if (totalInvestment <= 0) return 0.0;
    return ((totalRevenue - totalInvestment) / totalInvestment) * 100;
  }
  
  /// Get product revenue contribution percentage
  double get productRevenueContribution {
    if (totalRevenue <= 0) return 0.0;
    return (productRevenue / totalRevenue) * 100;
  }
  
  /// Validate data integrity
  bool get isValid {
    return totalInvestment >= 0 && 
           totalRevenue >= 0 && 
           productRevenue >= 0 && 
           rentalRevenue >= 0;
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

class ProductRevenue {
  final String productId;
  final String productName;
  final int quantitySold;
  final double unitPrice;
  final double totalRevenue;
  final double profitMargin;
  final DateTime saleDate;

  ProductRevenue({
    required this.productId,
    required this.productName,
    required this.quantitySold,
    required this.unitPrice,
    required this.totalRevenue,
    required this.profitMargin,
    required this.saleDate,
  });

  factory ProductRevenue.fromJson(Map<String, dynamic> json) {
    return ProductRevenue(
      productId: json['productId'] as String? ?? '',
      productName: json['productName'] as String? ?? 'Unknown Product',
      quantitySold: (json['quantitySold'] as num?)?.toInt() ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      profitMargin: (json['profitMargin'] as num?)?.toDouble() ?? 0.0,
      saleDate: DateTime.tryParse(json['saleDate'] as String? ?? '') ?? DateTime.now(),
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
  
  // Product revenue details for this land
  final double productRevenue;
  final List<ProductRevenue> productBreakdown;
  final int productsSoldCount;

  RoiRentalBreakdown({
    required this.id,
    required this.landId,
    required this.landName,
    required this.costs,
    required this.revenue,
    required this.netProfit,
    required this.roiPercentage,
    this.productRevenue = 0.0,
    this.productBreakdown = const [],
    this.productsSoldCount = 0,
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
      productRevenue: (json['productRevenue'] as num?)?.toDouble() ?? 0.0,
      productBreakdown: (json['productBreakdown'] as List<dynamic>?)
              ?.map((e) => ProductRevenue.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      productsSoldCount: (json['productsSoldCount'] as num?)?.toInt() ?? 0,
    );
  }
  
  /// Calculate total revenue including products
  double get totalRevenueWithProducts => revenue + productRevenue;
  
  /// Calculate net profit with product revenue
  double get adjustedNetProfit => totalRevenueWithProducts - costs.total;
  
  /// Get profit contribution from products
  double get productContributionPercentage {
    final total = totalRevenueWithProducts;
    if (total <= 0) return 0.0;
    return (productRevenue / total) * 100;
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
