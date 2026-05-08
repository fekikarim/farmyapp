import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/crop_cycle_model.dart';
import '../models/crop_plan_model.dart';
import 'auth_service.dart';

class CropCalendarService {
  static final String _baseUrl = dotenv.get(
    'API_BASE_URL',
    fallback: 'http://192.168.0.133:3001',
  );

  /// Fetch crop cycles for a specific land (from placed items + asset_productions)
  static Future<List<CropCycle>> fetchCropCycles(String landId) async {
    try {
      final response = await AuthService.authenticatedRequest(
        'GET',
        Uri.parse('$_baseUrl/api/v1/lands/$landId/crop-cycles'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List data = body['data'] ?? [];
        return data.map((item) => CropCycle.fromJson(item)).toList();
      }

      if (response.statusCode == 404) {
        // Endpoint not available yet - fallback to fetch from placed items
        return await _fetchCropCyclesFromPlacedItems(landId);
      }

      throw Exception('Failed to fetch crop cycles: ${response.statusCode}');
    } catch (e) {
      print('fetchCropCycles Error: $e');
      // Fallback: try to construct from placed items
      return await _fetchCropCyclesFromPlacedItems(landId);
    }
  }

  /// Fallback: Fetch placed items and construct crop cycles
  static Future<List<CropCycle>> _fetchCropCyclesFromPlacedItems(
    String landId,
  ) async {
    try {
      final response = await AuthService.authenticatedRequest(
        'GET',
        Uri.parse('$_baseUrl/api/v1/lands/$landId/placed-items'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List data = body['data'] ?? [];

        return data
            .where((item) {
              // Filter for vegetation and trees (crops)
              final category = item['asset_category']?.toString().toLowerCase();
              return category == 'vegetation' || category == 'tree';
            })
            .map((item) {
              // Convert placed item to crop cycle
              final variant = item['variant'] ?? {};
              final attributes = variant['attributes'] ?? {};
              final productions = item['asset_productions'] ?? [];

              // Get cycle info from first production or use defaults
              final production = productions.isNotEmpty ? productions[0] : {};
              final cycleDays =
                  production['cycle_days'] ?? attributes['growth_days'] ?? 30;
              final growthDays = attributes['growth_days'];

              return CropCycle(
                id: item['id']?.toString() ?? '',
                landId: landId,
                variantId: item['variant_id']?.toString() ?? '',
                assetCategory:
                    item['asset_category']?.toString() ?? 'vegetation',
                variantName: variant['variant_code']?.toString() ?? 'Unknown',
                iconUrl: variant['image_url'],
                placedAt: item['createdAt'] != null
                    ? DateTime.parse(item['createdAt'])
                    : DateTime.now(),
                growthDays: growthDays != null
                    ? int.tryParse(growthDays.toString())
                    : null,
                cycleDays: int.tryParse(cycleDays.toString()) ?? 30,
                isPerennial: attributes['is_perennial'] == true,
                productName: production['product']?['name'],
                ratePerCycle: production['rate_per_cycle'] != null
                    ? double.tryParse(production['rate_per_cycle'].toString())
                    : null,
                onHarvestOnly: production['on_harvest_only'] ?? true,
                status: CropCycleStatus.growing,
                harvestCount: 0,
              );
            })
            .toList();
      }

      return [];
    } catch (e) {
      print('_fetchCropCyclesFromPlacedItems Error: $e');
      return [];
    }
  }

  /// Fetch all crop cycles across all user's lands
  static Future<Map<String, List<CropCycle>>> fetchAllCropCycles(
    List<String> landIds,
  ) async {
    final Map<String, List<CropCycle>> result = {};

    for (final landId in landIds) {
      result[landId] = await fetchCropCycles(landId);
    }

    return result;
  }

  /// Fetch crop plans for a specific land
  static Future<List<CropPlan>> fetchCropPlans(String landId) async {
    try {
      final response = await AuthService.authenticatedRequest(
        'GET',
        Uri.parse('$_baseUrl/api/v1/lands/$landId/crop-plans'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List data = body['data'] ?? [];
        return data.map((item) => CropPlan.fromJson(item)).toList();
      }

      if (response.statusCode == 404) {
        // Endpoint not available yet
        return [];
      }

      throw Exception('Failed to fetch crop plans: ${response.statusCode}');
    } catch (e) {
      print('fetchCropPlans Error: $e');
      return [];
    }
  }

  /// Create a new crop plan
  static Future<CropPlan?> createCropPlan(CropPlan plan) async {
    try {
      final response = await AuthService.authenticatedRequest(
        'POST',
        Uri.parse('$_baseUrl/api/v1/crop-plans'),
        body: jsonEncode(plan.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final data = body['data'];
        if (data != null) {
          return CropPlan.fromJson(data);
        }
      }

      print('createCropPlan Failed: ${response.statusCode} - ${response.body}');
      return null;
    } catch (e) {
      print('createCropPlan Error: $e');
      return null;
    }
  }

  /// Update an existing crop plan
  static Future<CropPlan?> updateCropPlan(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await AuthService.authenticatedRequest(
        'PATCH',
        Uri.parse('$_baseUrl/api/v1/crop-plans/$id'),
        body: jsonEncode(updates),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final data = body['data'];
        if (data != null) {
          return CropPlan.fromJson(data);
        }
      }

      print('updateCropPlan Failed: ${response.statusCode} - ${response.body}');
      return null;
    } catch (e) {
      print('updateCropPlan Error: $e');
      return null;
    }
  }

  /// Mark a crop plan as active (planted)
  static Future<CropPlan?> activateCropPlan(String id) async {
    return await updateCropPlan(id, {'status': 'active'});
  }

  /// Mark a crop plan as completed (harvested)
  static Future<CropPlan?> completeCropPlan(String id) async {
    return await updateCropPlan(id, {
      'status': 'completed',
      'completed_at': DateTime.now().toIso8601String(),
    });
  }

  /// Cancel a crop plan
  static Future<CropPlan?> cancelCropPlan(String id) async {
    return await updateCropPlan(id, {'status': 'cancelled'});
  }

  /// Delete a crop plan
  static Future<bool> deleteCropPlan(String id) async {
    try {
      final response = await AuthService.authenticatedRequest(
        'DELETE',
        Uri.parse('$_baseUrl/api/v1/crop-plans/$id'),
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('deleteCropPlan Error: $e');
      return false;
    }
  }

  /// Get available crop variants for planning
  static Future<List<Map<String, dynamic>>> fetchAvailableCrops() async {
    try {
      // Fetch vegetation and tree types with variants from shop
      final results = <Map<String, dynamic>>[];

      final vegResponse = await AuthService.authenticatedRequest(
        'GET',
        Uri.parse('$_baseUrl/api/v1/assets/vegetation/types/with-variants'),
      );

      if (vegResponse.statusCode == 200) {
        final body = jsonDecode(vegResponse.body);
        final data = body['data'] ?? [];
        for (final item in data) {
          results.add({...item, 'category': 'vegetation'});
        }
      }

      final treeResponse = await AuthService.authenticatedRequest(
        'GET',
        Uri.parse('$_baseUrl/api/v1/assets/tree/types/with-variants'),
      );

      if (treeResponse.statusCode == 200) {
        final body = jsonDecode(treeResponse.body);
        final data = body['data'] ?? [];
        for (final item in data) {
          results.add({...item, 'category': 'tree'});
        }
      }

      return results;
    } catch (e) {
      print('fetchAvailableCrops Error: $e');
      return [];
    }
  }

  /// Get variant details with production info
  static Future<Map<String, dynamic>?> fetchVariantDetails(
    String category,
    String variantId,
  ) async {
    try {
      final response = await AuthService.authenticatedRequest(
        'GET',
        Uri.parse('$_baseUrl/api/v1/assets/$category/variants/$variantId'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return body['data'];
      }

      return null;
    } catch (e) {
      print('fetchVariantDetails Error: $e');
      return null;
    }
  }
}
