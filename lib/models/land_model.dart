import 'package:latlong2/latlong.dart';

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
  final DateTime createdAt;
  final DateTime updatedAt;

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
    required this.createdAt,
    required this.updatedAt,
  });

  factory Land.fromJson(Map<String, dynamic> json) {
    final wM = (json['width_m'] ?? 10.0).toDouble();
    final hM = (json['height_m'] ?? 10.0).toDouble();

    return Land(
      id: json['id'],
      ownerId: json['owner_id'],
      name: json['name'],
      description: json['description'],
      widthM: wM,
      heightM: hM,
      gridWidth:
          json['grid_width'] ?? (wM / 1.0).ceil(), // 1.0 = METERS_PER_CELL
      gridHeight: json['grid_height'] ?? (hM / 1.0).ceil(),
      boundaries: json['boundaries'] != null
          ? _parseBoundaries(json['boundaries'])
          : null,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
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
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static List<LatLng> _parseBoundaries(dynamic boundaries) {
    if (boundaries is List) {
      return boundaries.map((point) {
        if (point is Map) {
          return LatLng(point['latitude'], point['longitude']);
        } else if (point is List && point.length >= 2) {
          return LatLng(point[1], point[0]); // GeoJSON is [lng, lat]
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
