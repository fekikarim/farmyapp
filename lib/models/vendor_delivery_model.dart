import '../models/delivery_model.dart';

/// Stats for the vendor delivery dashboard
class VendorDeliveryStats {
  final int totalOrdersCount;
  final int activeDeliveriesCount;
  final int deliveredCount;
  final int cancelledCount;
  final double totalRevenue;

  VendorDeliveryStats({
    required this.totalOrdersCount,
    required this.activeDeliveriesCount,
    required this.deliveredCount,
    required this.cancelledCount,
    required this.totalRevenue,
  });

  factory VendorDeliveryStats.fromJson(Map<String, dynamic> json) {
    return VendorDeliveryStats(
      totalOrdersCount: json['total_orders_count'] ?? 0,
      activeDeliveriesCount: json['active_deliveries_count'] ?? 0,
      deliveredCount: json['delivered_count'] ?? 0,
      cancelledCount: json['cancelled_count'] ?? 0,
      totalRevenue:
          double.tryParse(json['total_revenue']?.toString() ?? '0') ?? 0,
    );
  }

  static VendorDeliveryStats empty() => VendorDeliveryStats(
    totalOrdersCount: 0,
    activeDeliveriesCount: 0,
    deliveredCount: 0,
    cancelledCount: 0,
    totalRevenue: 0,
  );
}

/// Allowed status transition for vendors
class StatusTransition {
  final DeliveryStatus status;
  final String label;

  StatusTransition({required this.status, required this.label});

  factory StatusTransition.fromJson(Map<String, dynamic> json) {
    return StatusTransition(
      status: DeliveryStatus.fromString(json['status'] ?? ''),
      label: json['label'] ?? '',
    );
  }
}

/// Customer info in vendor context
class VendorCustomerInfo {
  final String id;
  final String name;
  final String email;
  final String? picture;

  VendorCustomerInfo({
    required this.id,
    required this.name,
    required this.email,
    this.picture,
  });

  factory VendorCustomerInfo.fromJson(Map<String, dynamic> json) {
    return VendorCustomerInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      email: json['email'] ?? '',
      picture: json['picture'],
    );
  }
}

/// A single delivery item in the vendor list
class VendorDeliveryItem {
  final String id;
  final String orderId;
  final DeliveryStatus deliveryStatus;
  final String deliveryStatusLabel;
  final DateTime? estimatedDeliveryTime;
  final bool isTerminal;
  final List<DeliveryStatus> allowedTransitions;
  final VendorCustomerInfo? customer;
  final DeliveryOrderSummary? order;
  final DateTime createdAt;
  final DateTime updatedAt;

  VendorDeliveryItem({
    required this.id,
    required this.orderId,
    required this.deliveryStatus,
    required this.deliveryStatusLabel,
    this.estimatedDeliveryTime,
    required this.isTerminal,
    required this.allowedTransitions,
    this.customer,
    this.order,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VendorDeliveryItem.fromJson(Map<String, dynamic> json) {
    return VendorDeliveryItem(
      id: json['id'] ?? '',
      orderId: json['order_id'] ?? '',
      deliveryStatus: DeliveryStatus.fromString(json['delivery_status'] ?? ''),
      deliveryStatusLabel: json['delivery_status_label'] ?? '',
      estimatedDeliveryTime: json['estimated_delivery_time'] != null
          ? DateTime.tryParse(json['estimated_delivery_time'])
          : null,
      isTerminal: json['is_terminal'] ?? false,
      allowedTransitions:
          (json['allowed_transitions'] as List<dynamic>?)
              ?.map((e) => DeliveryStatus.fromString(e.toString()))
              .toList() ??
          [],
      customer: json['customer'] != null
          ? VendorCustomerInfo.fromJson(json['customer'])
          : null,
      order: json['order'] != null
          ? DeliveryOrderSummary.fromJson(json['order'])
          : null,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

/// Full vendor delivery detail (with timeline)
class VendorDeliveryDetail {
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
  final List<DeliveryStatus> allowedTransitions;
  final List<StatusTransition> allowedTransitionLabels;
  final LatLng? coordinates;
  final LatLng? destination;
  final List<DeliveryTimelineStep> timeline;
  final VendorCustomerInfo? customer;
  final DeliveryOrderSummary? order;
  final DeliveryPerson? seller;
  final DeliveryPerson? driver;
  final DateTime createdAt;
  final DateTime updatedAt;

  VendorDeliveryDetail({
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
    required this.allowedTransitions,
    required this.allowedTransitionLabels,
    this.coordinates,
    this.destination,
    required this.timeline,
    this.customer,
    this.order,
    this.seller,
    this.driver,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VendorDeliveryDetail.fromJson(Map<String, dynamic> json) {
    return VendorDeliveryDetail(
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
      allowedTransitions:
          (json['allowed_transitions'] as List<dynamic>?)
              ?.map((e) => DeliveryStatus.fromString(e.toString()))
              .toList() ??
          [],
      allowedTransitionLabels:
          (json['allowed_transition_labels'] as List<dynamic>?)
              ?.map((e) => StatusTransition.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
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
      customer: json['customer'] != null
          ? VendorCustomerInfo.fromJson(json['customer'])
          : null,
      order: json['order'] != null
          ? DeliveryOrderSummary.fromJson(json['order'])
          : null,
      seller: json['seller'] != null
          ? DeliveryPerson.fromJson(json['seller'])
          : null,
      driver: json['driver'] != null
          ? DeliveryPerson.fromJson(json['driver'])
          : null,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

/// Pagination metadata
class PaginationMeta {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  PaginationMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      totalPages: json['totalPages'] ?? 1,
    );
  }

  bool get hasNextPage => page < totalPages;
}
