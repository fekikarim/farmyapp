class PlacedItem {
  final String id;
  final String landId;
  final String assetCategory;
  final String variantId;
  final int positionX;
  final int positionY;
  final bool isActive;
  final DateTime placedAt;
  final Map<String, dynamic>? details;

  PlacedItem({
    required this.id,
    required this.landId,
    required this.assetCategory,
    required this.variantId,
    required this.positionX,
    required this.positionY,
    required this.isActive,
    required this.placedAt,
    this.details,
  });

  factory PlacedItem.fromJson(Map<String, dynamic> json) {
    return PlacedItem(
      id: json['id'] ?? '',
      landId: json['land_id'] ?? '',
      assetCategory: json['asset_category'] ?? '',
      variantId: json['variant_id'] ?? '',
      positionX: json['position_x'] ?? 0,
      positionY: json['position_y'] ?? 0,
      isActive: json['is_active'] ?? false,
      placedAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      details: json['details'],
    );
  }

  String get displayName => details?['name'] ?? '$assetCategory ($variantId)';
}
