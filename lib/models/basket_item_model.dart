import 'product_model.dart';

class BasketItem {
  final Product product;
  int quantity;

  BasketItem({
    required this.product,
    this.quantity = 1,
  });

  /// Line total = price × quantity
  double get subtotal => product.price * quantity;

  /// Max purchasable quantity (based on available stock)
  int get maxQuantity => product.quantity.toInt();

  /// Whether more can be added
  bool get canIncrement => quantity < maxQuantity;

  /// Serialize for local persistence
  Map<String, dynamic> toJson() => {
        'product': {
          'id': product.id,
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'quantity': product.quantity,
          'unit': product.unit,
          'status': product.status.name,
          'images': product.images,
          'ownerId': product.ownerId,
          'productTypeId': product.productTypeId,
          'landId': product.landId,
          'landRentalId': product.landRentalId,
          'createdAt': product.createdAt.toIso8601String(),
        },
        'quantity': quantity,
      };

  factory BasketItem.fromJson(Map<String, dynamic> json) {
    return BasketItem(
      product: Product.fromJson({
        'id': json['product']['id'],
        'title': json['product']['title'],
        'description': json['product']['description'],
        'price': json['product']['price'],
        'quantity': json['product']['quantity'],
        'unit': json['product']['unit'],
        'status': json['product']['status'],
        'images': json['product']['images'],
        'owner_id': json['product']['ownerId'],
        'product_type_id': json['product']['productTypeId'],
        'land_id': json['product']['landId'],
        'land_rental_id': json['product']['landRentalId'],
        'createdAt': json['product']['createdAt'],
      }),
      quantity: json['quantity'] ?? 1,
    );
  }

  BasketItem copyWith({int? quantity}) {
    return BasketItem(
      product: product,
      quantity: quantity ?? this.quantity,
    );
  }
}
