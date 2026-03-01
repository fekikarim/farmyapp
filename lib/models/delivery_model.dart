/// Delivery status enum matching backend ENUM values
enum DeliveryStatus {
  orderCreated,
  confirmed,
  preparing,
  outForDelivery,
  nearby,
  delivered,
  cancelled;

  static DeliveryStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'ORDER_CREATED':
        return DeliveryStatus.orderCreated;
      case 'CONFIRMED':
        return DeliveryStatus.confirmed;
      case 'PREPARING':
        return DeliveryStatus.preparing;
      case 'OUT_FOR_DELIVERY':
        return DeliveryStatus.outForDelivery;
      case 'NEARBY':
        return DeliveryStatus.nearby;
      case 'DELIVERED':
        return DeliveryStatus.delivered;
      case 'CANCELLED':
        return DeliveryStatus.cancelled;
      default:
        return DeliveryStatus.orderCreated;
    }
  }

  String get apiValue {
    switch (this) {
      case DeliveryStatus.orderCreated:
        return 'ORDER_CREATED';
      case DeliveryStatus.confirmed:
        return 'CONFIRMED';
      case DeliveryStatus.preparing:
        return 'PREPARING';
      case DeliveryStatus.outForDelivery:
        return 'OUT_FOR_DELIVERY';
      case DeliveryStatus.nearby:
        return 'NEARBY';
      case DeliveryStatus.delivered:
        return 'DELIVERED';
      case DeliveryStatus.cancelled:
        return 'CANCELLED';
    }
  }

  String get label {
    switch (this) {
      case DeliveryStatus.orderCreated:
        return 'Order Created';
      case DeliveryStatus.confirmed:
        return 'Confirmed';
      case DeliveryStatus.preparing:
        return 'Preparing';
      case DeliveryStatus.outForDelivery:
        return 'Out for Delivery';
      case DeliveryStatus.nearby:
        return 'Driver Nearby';
      case DeliveryStatus.delivered:
        return 'Delivered';
      case DeliveryStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get description {
    switch (this) {
      case DeliveryStatus.orderCreated:
        return 'Your order has been placed successfully.';
      case DeliveryStatus.confirmed:
        return 'The seller has confirmed your order.';
      case DeliveryStatus.preparing:
        return 'Your order is being prepared for delivery.';
      case DeliveryStatus.outForDelivery:
        return 'Your order is on the way!';
      case DeliveryStatus.nearby:
        return 'The driver is nearby. Please be ready!';
      case DeliveryStatus.delivered:
        return 'Your order has been delivered. Enjoy!';
      case DeliveryStatus.cancelled:
        return 'This delivery has been cancelled.';
    }
  }

  bool get isTerminal =>
      this == DeliveryStatus.delivered || this == DeliveryStatus.cancelled;
}

/// A single step in the delivery timeline
class DeliveryTimelineStep {
  final DeliveryStatus status;
  final String label;
  final String state; // 'completed', 'current', 'pending', 'cancelled'
  final DateTime? timestamp;
  final String? note;

  DeliveryTimelineStep({
    required this.status,
    required this.label,
    required this.state,
    this.timestamp,
    this.note,
  });

  bool get isCompleted => state == 'completed';
  bool get isCurrent => state == 'current';
  bool get isPending => state == 'pending';
  bool get isCancelled => state == 'cancelled';

  factory DeliveryTimelineStep.fromJson(Map<String, dynamic> json) {
    return DeliveryTimelineStep(
      status: DeliveryStatus.fromString(json['status'] ?? ''),
      label: json['label'] ?? '',
      state: json['state'] ?? 'pending',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'])
          : null,
      note: json['note'],
    );
  }
}

/// Coordinate pair
class LatLng {
  final double latitude;
  final double longitude;

  const LatLng({required this.latitude, required this.longitude});

  factory LatLng.fromJson(Map<String, dynamic> json) {
    return LatLng(
      latitude: double.tryParse(json['latitude'].toString()) ?? 0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0,
    );
  }
}

/// Order summary within delivery
class DeliveryOrderSummary {
  final String id;
  final String productName;
  final double quantity;
  final double totalPrice;

  DeliveryOrderSummary({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.totalPrice,
  });

  factory DeliveryOrderSummary.fromJson(Map<String, dynamic> json) {
    return DeliveryOrderSummary(
      id: json['id'] ?? '',
      productName: json['product_name'] ?? 'Unknown Product',
      quantity: double.tryParse(json['quantity'].toString()) ?? 0,
      totalPrice: double.tryParse(json['total_price'].toString()) ?? 0,
    );
  }
}

/// Minimal person info for display
class DeliveryPerson {
  final String id;
  final String name;
  final String? picture;

  DeliveryPerson({required this.id, required this.name, this.picture});

  factory DeliveryPerson.fromJson(Map<String, dynamic> json) {
    return DeliveryPerson(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      picture: json['picture'],
    );
  }
}

/// Full delivery tracking model
class DeliveryTracking {
  final String id;
  final String orderId;
  final DeliveryStatus deliveryStatus;
  final String deliveryStatusLabel;
  final DateTime? estimatedDeliveryTime;
  final String? deliveryAddress;
  final bool isTerminal;
  final DateTime? startedAt;
  final DateTime? deliveredAt;
  final String? cancellationReason;
  final LatLng? coordinates;
  final LatLng? destination;
  final List<DeliveryTimelineStep> timeline;
  final DeliveryOrderSummary? order;
  final DeliveryPerson? seller;
  final DeliveryPerson? buyer;
  final DeliveryPerson? driver;
  final DateTime createdAt;
  final DateTime updatedAt;

  DeliveryTracking({
    required this.id,
    required this.orderId,
    required this.deliveryStatus,
    required this.deliveryStatusLabel,
    this.estimatedDeliveryTime,
    this.deliveryAddress,
    required this.isTerminal,
    this.startedAt,
    this.deliveredAt,
    this.cancellationReason,
    this.coordinates,
    this.destination,
    required this.timeline,
    this.order,
    this.seller,
    this.buyer,
    this.driver,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeliveryTracking.fromJson(Map<String, dynamic> json) {
    return DeliveryTracking(
      id: json['id'] ?? '',
      orderId: json['order_id'] ?? '',
      deliveryStatus: DeliveryStatus.fromString(json['delivery_status'] ?? ''),
      deliveryStatusLabel: json['delivery_status_label'] ?? '',
      estimatedDeliveryTime: json['estimated_delivery_time'] != null
          ? DateTime.tryParse(json['estimated_delivery_time'])
          : null,
      deliveryAddress: json['delivery_address'],
      isTerminal: json['is_terminal'] ?? false,
      startedAt: json['started_at'] != null
          ? DateTime.tryParse(json['started_at'])
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.tryParse(json['delivered_at'])
          : null,
      cancellationReason: json['cancellation_reason'],
      coordinates: json['coordinates'] != null
          ? LatLng.fromJson(json['coordinates'])
          : null,
      destination: json['destination'] != null
          ? LatLng.fromJson(json['destination'])
          : null,
      timeline:
          (json['timeline'] as List<dynamic>?)
              ?.map(
                (e) => DeliveryTimelineStep.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      order: json['order'] != null
          ? DeliveryOrderSummary.fromJson(json['order'])
          : null,
      seller: json['seller'] != null
          ? DeliveryPerson.fromJson(json['seller'])
          : null,
      buyer: json['buyer'] != null
          ? DeliveryPerson.fromJson(json['buyer'])
          : null,
      driver: json['driver'] != null
          ? DeliveryPerson.fromJson(json['driver'])
          : null,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  /// Whether the map section should be visible
  bool get showMap =>
      !isTerminal &&
      (deliveryStatus == DeliveryStatus.outForDelivery ||
          deliveryStatus == DeliveryStatus.nearby) &&
      coordinates != null;

  /// Remaining time until ETA
  Duration? get timeRemaining {
    if (estimatedDeliveryTime == null) return null;
    final remaining = estimatedDeliveryTime!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }
}
