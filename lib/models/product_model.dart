import 'user_model.dart';

enum ProductStatus { available, sold, hidden }

class Product {
  final String id;
  final String title;
  final String? description;
  final double price;
  final double quantity;
  final String unit;
  final ProductStatus status;
  final List<String> images;
  final String ownerId;
  final User? owner;
  final String productTypeId;
  final String? landId;
  final String? landRentalId;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.title,
    this.description,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.status,
    required this.images,
    required this.ownerId,
    this.owner,
    required this.productTypeId,
    this.landId,
    this.landRentalId,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled',
      description: json['description'],
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      quantity: double.tryParse(json['quantity'].toString()) ?? 0.0,
      unit: json['unit'] ?? '',
      status: _parseStatus(json['status']?.toString() ?? ''),
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      ownerId: json['owner_id']?.toString() ?? '',
      owner: json['owner'] != null ? User.fromJson(json['owner']) : null,
      productTypeId: json['product_type_id']?.toString() ?? '',
      landId: json['land_id']?.toString(),
      landRentalId: json['land_rental_id']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  static ProductStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'sold':
        return ProductStatus.sold;
      case 'hidden':
        return ProductStatus.hidden;
      case 'available':
      default:
        return ProductStatus.available;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'quantity': quantity,
      'unit': unit,
      'product_type_id': productTypeId,
      'land_id': landId,
      'land_rental_id': landRentalId,
      'images': images,
    };
  }
}
