class ShopItemType {
  final String id;
  final String name;
  final String? description;
  final String? iconUrl;
  final bool isActive;
  final List<ShopItemVariant>? variants;

  ShopItemType({
    required this.id,
    required this.name,
    this.description,
    this.iconUrl,
    required this.isActive,
    this.variants,
  });

  factory ShopItemType.fromJson(Map<String, dynamic> json) {
    return ShopItemType(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      iconUrl: json['icon_url'],
      isActive: json['is_active'] ?? true,
      variants: json['variants'] != null
          ? (json['variants'] as List)
              .map((v) => ShopItemVariant.fromJson(v))
              .toList()
          : null,
    );
  }

  String get assetIconPath {
    if (iconUrl == null) return '';
    // User said: it means the icon is in the flutter assets folder in a folder called game/<url>
    // icon_url might be /icons/cow.png, so we need assets/game/icons/cow.png
    String path = iconUrl!;
    if (path.startsWith('/')) {
      path = path.substring(1);
    }
    return 'assets/game_images/$path';
  }
}

class ShopItemVariant {
  final String id;
  final String typeId;
  final String variantCode;
  final double basePrice;
  final Map<String, dynamic>? attributes;
  final String? imageUrl;
  final Map<String, dynamic>? sprites;
  final bool isAvailable;

  ShopItemVariant({
    required this.id,
    required this.typeId,
    required this.variantCode,
    required this.basePrice,
    this.attributes,
    this.imageUrl,
    this.sprites,
    required this.isAvailable,
  });

  factory ShopItemVariant.fromJson(Map<String, dynamic> json) {
    return ShopItemVariant(
      id: json['id'],
      typeId: json['type_id'],
      variantCode: json['variant_code'],
      basePrice: (json['base_price'] is num) 
          ? (json['base_price'] as num).toDouble() 
          : double.tryParse(json['base_price'].toString()) ?? 0.0,
      attributes: json['attributes'],
      imageUrl: json['image_url'],
      sprites: json['sprites'],
      isAvailable: json['is_available'] ?? true,
    );
  }

  String get assetImagePath {
    if (imageUrl == null) return '';
    String path = imageUrl!;
    if (path.startsWith('/')) {
      path = path.substring(1);
    }
    return 'assets/game_images/$path';
  }

  Map<String, String> get formattedAttributes {
    if (attributes == null) return {};
    final Map<String, String> formatted = {};
    
    attributes!.forEach((key, value) {
      final String label = key.split('_').map((word) {
        if (word.isEmpty) return '';
        return word[0].toUpperCase() + word.substring(1);
      }).join(' ');
      
      String displayValue = value.toString();
      if (key.contains('price') || key.contains('cost')) {
        displayValue = '\$$displayValue';
      } else if (key.contains('efficiency')) {
        displayValue = '$displayValue%';
      } else if (key.contains('days') || key.contains('years')) {
        displayValue = '$displayValue ${key.split('_').last}';
      }
      
      formatted[label] = displayValue;
    });
    
    return formatted;
  }
}
