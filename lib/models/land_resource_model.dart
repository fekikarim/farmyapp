class LandResource {
  final String id;
  final String landId;
  final String resourceTypeId;
  final double quantity;
  final double maxCapacity;
  final DateTime lastUpdated;
  final ResourceType? resourceType;

  LandResource({
    required this.id,
    required this.landId,
    required this.resourceTypeId,
    required this.quantity,
    required this.maxCapacity,
    required this.lastUpdated,
    this.resourceType,
  });

  factory LandResource.fromJson(Map<String, dynamic> json) {
    return LandResource(
      id: json['id'],
      landId: json['land_id'],
      resourceTypeId: json['resource_type_id'],
      quantity: double.parse(json['quantity'].toString()),
      maxCapacity: double.parse(json['max_capacity'].toString()),
      lastUpdated: DateTime.parse(json['last_updated']),
      resourceType: json['resource_type'] != null
          ? ResourceType.fromJson(json['resource_type'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'land_id': landId,
      'resource_type_id': resourceTypeId,
      'quantity': quantity,
      'max_capacity': maxCapacity,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  double get percentageFull => (quantity / maxCapacity * 100).clamp(0, 100);

  bool get isFull => quantity >= maxCapacity;

  bool get isEmpty => quantity <= 0;
}

class ResourceType {
  final String id;
  final String name;
  final String unit;
  final String? description;
  final String? iconUrl;
  final bool isActive;

  ResourceType({
    required this.id,
    required this.name,
    required this.unit,
    this.description,
    this.iconUrl,
    required this.isActive,
  });

  factory ResourceType.fromJson(Map<String, dynamic> json) {
    return ResourceType(
      id: json['id'],
      name: json['name'],
      unit: json['unit'],
      description: json['description'],
      iconUrl: json['icon_url'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'unit': unit,
      'description': description,
      'icon_url': iconUrl,
      'is_active': isActive,
    };
  }
}
