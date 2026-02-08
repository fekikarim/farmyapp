class ProductType {
  final String id;
  final String name;
  final String unit;
  final String? description;
  final String? iconUrl;

  ProductType({
    required this.id,
    required this.name,
    required this.unit,
    this.description,
    this.iconUrl,
  });

  factory ProductType.fromJson(Map<String, dynamic> json) {
    return ProductType(
      id: json['id'],
      name: json['name'],
      unit: json['unit'],
      description: json['description'],
      iconUrl: json['icon_url'],
    );
  }
}
