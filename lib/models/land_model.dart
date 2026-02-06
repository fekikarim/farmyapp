import 'package:latlong2/latlong.dart';

class Land {
  final String id;
  final String ownerId;
  final String name;
  final String? description;
  final int gridWidth;
  final int gridHeight;
  final double widthM;
  final double heightM;
  final List<LatLng>? boundaries;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Land({
    required this.id,
    required this.ownerId,
    required this.name,
    this.description,
    this.gridWidth = 10,
    this.gridHeight = 10,
    this.widthM = 10.0,
    this.heightM = 10.0,
    this.boundaries,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Land.fromJson(Map<String, dynamic> json) {
    return Land(
      id: json['id'],
      ownerId: json['owner_id'],
      name: json['name'],
      description: json['description'],
      gridWidth: json['grid_width'] ?? 10,
      gridHeight: json['grid_height'] ?? 10,
      widthM: (json['width_m'] ?? 10.0).toDouble(),
      heightM: (json['height_m'] ?? 10.0).toDouble(),
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
      'grid_width': gridWidth,
      'grid_height': gridHeight,
      'width_m': widthM,
      'height_m': heightM,
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
    // Handle PostGIS polygon format if needed (simplified here)
    return [];
  }

  static dynamic _boundariesToJson(List<LatLng> points) {
    return points.map((p) => [p.longitude, p.latitude]).toList();
  }
}
