import 'package:latlong2/latlong.dart';
import 'land_rental_model.dart';

class Land {
  final String id;
  final String ownerId;
  final String name;
  final String? description;
  final double widthM;
  final double heightM;
  final int gridWidth;
  final int gridHeight;
  final List<LatLng>? boundaries;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<LandRental> rentals;
  final String? hederaTransactionId;

  Land({
    required this.id,
    required this.ownerId,
    required this.name,
    this.description,
    this.widthM = 10.0,
    this.heightM = 10.0,
    this.gridWidth = 10,
    this.gridHeight = 10,
    this.boundaries,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.rentals = const [],
    this.hederaTransactionId,
  });

  bool get isRented {
    if (rentals.isEmpty) return false;
    final now = DateTime.now();
    return rentals.any(
      (r) =>
          r.paymentStatus != PaymentStatus.cancelled &&
          (r.rentalEndDate == null || r.rentalEndDate!.isAfter(now)),
    );
  }

  factory Land.fromJson(Map<String, dynamic> json) {
    final wM = double.tryParse(json['width_m']?.toString() ?? '') ?? 10.0;
    final hM = double.tryParse(json['height_m']?.toString() ?? '') ?? 10.0;

    return Land(
      id: json['id']?.toString() ?? '',
      ownerId: json['owner_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Untitled',
      description: json['description']?.toString(),
      widthM: wM,
      heightM: hM,
      gridWidth: int.tryParse(json['grid_width']?.toString() ?? '') ??
          (wM / 1.0).ceil(), // 1.0 = METERS_PER_CELL
      gridHeight: int.tryParse(json['grid_height']?.toString() ?? '') ??
          (hM / 1.0).ceil(),
      boundaries: json['boundaries'] != null
          ? _parseBoundaries(json['boundaries'])
          : null,
      isActive: json['is_active'] ?? true,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      rentals: json['rentals'] != null
          ? (json['rentals'] as List)
                .map((r) => LandRental.fromJson(r))
                .toList()
          : [],
      hederaTransactionId: json['hedera_transaction_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'name': name,
      'description': description,
      'width_m': widthM,
      'height_m': heightM,
      'grid_width': gridWidth,
      'grid_height': gridHeight,
      'boundaries': boundaries != null ? _boundariesToJson(boundaries!) : null,
      'is_active': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static List<LatLng> _parseBoundaries(dynamic boundaries) {
    if (boundaries is List) {
      return boundaries.map((point) {
        if (point is Map) {
          final lat = double.tryParse(point['latitude']?.toString() ?? '') ?? 0.0;
          final lng = double.tryParse(point['longitude']?.toString() ?? '') ?? 0.0;
          return LatLng(lat, lng);
        } else if (point is List && point.length >= 2) {
          final lng = double.tryParse(point[0]?.toString() ?? '') ?? 0.0;
          final lat = double.tryParse(point[1]?.toString() ?? '') ?? 0.0;
          return LatLng(lat, lng); // GeoJSON is [lng, lat]
        }
        return const LatLng(0, 0);
      }).toList();
    }
    return [];
  }

  static dynamic _boundariesToJson(List<LatLng> points) {
    return points.map((p) => [p.longitude, p.latitude]).toList();
  }
}
