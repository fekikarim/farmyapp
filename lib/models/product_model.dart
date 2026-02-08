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
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: (json['price'] ?? 0).toDouble(),
      quantity: (json['quantity'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
      status: _parseStatus(json['status']),
      images: List<String>.from(json['images'] ?? []),
      ownerId: json['owner_id'],
      owner: json['owner'] != null ? User.fromJson(json['owner']) : null,
      productTypeId: json['product_type_id'],
      landId: json['land_id'],
      landRentalId: json['land_rental_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  static ProductStatus _parseStatus(String status) {
    switch (status) {
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
