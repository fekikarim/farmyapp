import 'package:latlong2/latlong.dart';

class GeometryUtils {
  /// Check if two polygons intersect
  static bool doPolygonsIntersect(List<LatLng> poly1, List<LatLng> poly2) {
    if (poly1.length < 3 || poly2.length < 3) return false;

    // Check if any edge of poly1 intersects with any edge of poly2
    for (int i = 0; i < poly1.length; i++) {
      int nextI = (i + 1) % poly1.length;
      final p1 = poly1[i];
      final p2 = poly1[nextI];

      for (int j = 0; j < poly2.length; j++) {
        int nextJ = (j + 1) % poly2.length;
        final p3 = poly2[j];
        final p4 = poly2[nextJ];

        if (_doLineSegmentsIntersect(p1, p2, p3, p4)) {
          return true;
        }
      }
    }

    // Check if one polygon is completely inside the other
    if (_isPointInPolygon(poly1.first, poly2) ||
        _isPointInPolygon(poly2.first, poly1)) {
      return true;
    }

    return false;
  }

  /// Check if a point is inside a polygon (Ray Casting algorithm)
  static bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    bool isInside = false;
    int j = polygon.length - 1;

    for (int i = 0; i < polygon.length; i++) {
      if ((polygon[i].latitude > point.latitude) !=
              (polygon[j].latitude > point.latitude) &&
          (point.longitude <
              (polygon[j].longitude - polygon[i].longitude) *
                      (point.latitude - polygon[i].latitude) /
                      (polygon[j].latitude - polygon[i].latitude) +
                  polygon[i].longitude)) {
        isInside = !isInside;
      }
      j = i;
    }

    return isInside;
  }

  /// Check if two line segments (p1-p2 and p3-p4) intersect
  static bool _doLineSegmentsIntersect(
    LatLng p1,
    LatLng p2,
    LatLng p3,
    LatLng p4,
  ) {
    double d1 = _direction(p3, p4, p1);
    double d2 = _direction(p3, p4, p2);
    double d3 = _direction(p1, p2, p3);
    double d4 = _direction(p1, p2, p4);

    if (((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) &&
        ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0))) {
      return true;
    }

    if (d1 == 0 && _onSegment(p3, p4, p1)) return true;
    if (d2 == 0 && _onSegment(p3, p4, p2)) return true;
    if (d3 == 0 && _onSegment(p1, p2, p3)) return true;
    if (d4 == 0 && _onSegment(p1, p2, p4)) return true;

    return false;
  }

  static double _direction(LatLng pi, LatLng pj, LatLng pk) {
    return (pk.longitude - pi.longitude) * (pj.latitude - pi.latitude) -
        (pj.longitude - pi.longitude) * (pk.latitude - pi.latitude);
  }

  static bool _onSegment(LatLng pi, LatLng pj, LatLng pk) {
    return (pk.longitude >=
            (pi.longitude < pj.longitude ? pi.longitude : pj.longitude)) &&
        (pk.longitude <=
            (pi.longitude > pj.longitude ? pi.longitude : pj.longitude)) &&
        (pk.latitude >=
            (pi.latitude < pj.latitude ? pi.latitude : pj.latitude)) &&
        (pk.latitude <=
            (pi.latitude > pj.latitude ? pi.latitude : pj.latitude));
  }
}
