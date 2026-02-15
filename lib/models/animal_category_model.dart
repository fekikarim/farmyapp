class AnimalCategory {
  final String id;
  final String name;
  final String? description;
  final String? iconUrl;
  final bool isActive;
  final List<ResourceConsumption>? resourceConsumptions;

  AnimalCategory({
    required this.id,
    required this.name,
    this.description,
    this.iconUrl,
    required this.isActive,
    this.resourceConsumptions,
  });

  factory AnimalCategory.fromJson(Map<String, dynamic> json) {
    return AnimalCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      iconUrl: json['icon_url'],
      isActive: json['is_active'] ?? true,
      resourceConsumptions: json['resource_consumptions'] != null
          ? (json['resource_consumptions'] as List)
              .map((e) => ResourceConsumption.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_url': iconUrl,
      'is_active': isActive,
    };
  }
}

class ResourceConsumption {
  final String id;
  final String animalCategoryId;
  final String resourceTypeId;
  final double consumptionRate;
  final bool isRequired;
  final ResourceType? resourceType;

  ResourceConsumption({
    required this.id,
    required this.animalCategoryId,
    required this.resourceTypeId,
    required this.consumptionRate,
    required this.isRequired,
    this.resourceType,
  });

  factory ResourceConsumption.fromJson(Map<String, dynamic> json) {
    return ResourceConsumption(
      id: json['id'],
      animalCategoryId: json['animal_category_id'],
      resourceTypeId: json['resource_type_id'],
      consumptionRate: double.parse(json['consumption_rate'].toString()),
      isRequired: json['is_required'] ?? true,
      resourceType: json['resource_type'] != null
          ? ResourceType.fromJson(json['resource_type'])
          : null,
    );
  }
}

class ResourceType {
  final String id;
  final String name;
  final String unit;
  final String? description;
  final String? iconUrl;

  ResourceType({
    required this.id,
    required this.name,
    required this.unit,
    this.description,
    this.iconUrl,
  });

  factory ResourceType.fromJson(Map<String, dynamic> json) {
    return ResourceType(
      id: json['id'],
      name: json['name'],
      unit: json['unit'],
      description: json['description'],
      iconUrl: json['icon_url'],
    );
  }
}
