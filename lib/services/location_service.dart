import 'package:geolocator/geolocator.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();

  factory LocationService() {
    return _instance;
  }

  LocationService._internal();

  /// Request location permissions
  static Future<bool> requestLocationPermission() async {
    try {
      final permission = await Geolocator.requestPermission();
      
      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openLocationSettings();
        return false;
      }
      
      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e) {
      print('❌ Location Permission Error: $e');
      return false;
    }
  }

  /// Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      print('❌ Location Service Check Error: $e');
      return false;
    }
  }

  /// Get current GPS coordinates
  static Future<Map<String, double>?> getCurrentLocation() async {
    try {
      print('📍 Requesting current location...');
      
      // Check if location service is enabled
      final isEnabled = await isLocationServiceEnabled();
      if (!isEnabled) {
        print('❌ Location service is disabled');
        await Geolocator.openLocationSettings();
        return null;
      }

      // Request permission
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        print('❌ Location permission denied');
        return null;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      final location = {
        'latitude': position.latitude,
        'longitude': position.longitude,
      };

      print('✅ Location fetched: $location');
      return location;
    } catch (e) {
      print('❌ Get Location Error: $e');
      
      // If high accuracy fails, try best effort
      if (e.toString().contains('TimeoutException')) {
        try {
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
            forceAndroidLocationManager: true,
          );

          final location = {
            'latitude': position.latitude,
            'longitude': position.longitude,
          };

          print('✅ Location fetched (best effort): $location');
          return location;
        } catch (fallbackError) {
          print('❌ Fallback Location Error: $fallbackError');
          return null;
        }
      }
      
      return null;
    }
  }

  /// Stream location updates
  static Stream<Map<String, double>> getLocationStream() {
    try {
      return Geolocator.getPositionStream().map((position) => {
        'latitude': position.latitude,
        'longitude': position.longitude,
      });
    } catch (e) {
      print('❌ Location Stream Error: $e');
      return Stream.empty();
    }
  }
}
