import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'auth_service.dart';

class ProofService {
  static final String _baseUrl = dotenv.get(
    'API_BASE_URL',
    fallback: 'http://192.168.0.133:3001',
  );

  static Future<String?> requestProof(
    String farmerId,
    String landId, {
    String targetType = 'land',
    String? targetId,
  }) async {
    try {
      final response = await AuthService.authenticatedRequest(
        'POST',
        Uri.parse('$_baseUrl/api/v1/proofs/request-proof'),
        body: {
          'farmer_id': farmerId,
          'land_id': landId,
          'target_type': targetType,
          if (targetId != null) 'target_id': targetId,
        },
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 201) return null; // Success

      return body['message'] ??
          'Failed to request proof (Status: ${response.statusCode})';
    } catch (e) {
      print('requestProof Error: $e');
      return 'Network error: $e';
    }
  }

  static Future<List<dynamic>> getMyProofs() async {
    try {
      final response = await AuthService.authenticatedRequest(
        'GET',
        Uri.parse('$_baseUrl/api/v1/proofs/my-proofs'),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['data'] ?? [];
      }
      return [];
    } catch (e) {
      print('getMyProofs Error: $e');
      return [];
    }
  }

  static Future<String?> submitProof(
    String proofId,
    XFile proofImage, {
    Function(String)? onStatusUpdate,
  }) async {
    try {
      onStatusUpdate?.call('Uploading Image...');
      final token = await AuthService.getAccessToken();
      final uri = Uri.parse('$_baseUrl/api/v1/proofs/submit-proof/$proofId');
      final request = http.MultipartRequest('POST', uri);

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      final bytes = await proofImage.readAsBytes();
      final mimeType = lookupMimeType(proofImage.path) ?? 'image/jpeg';

      request.files.add(
        http.MultipartFile.fromBytes(
          'proof_image',
          bytes,
          filename: proofImage.name,
          contentType: MediaType.parse(mimeType),
        ),
      );

      final streamedResponse = await request.send();
      onStatusUpdate?.call('AI Verifying...');

      final response = await http.Response.fromStream(streamedResponse);
      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return body['message']?.toString().contains('rejected') == true
            ? body['message']
            : null;
      }

      return body['message'] ??
          'Failed to submit proof (Status: ${response.statusCode})';
    } catch (e) {
      print('submitProof Error: $e');
      return 'Network error: $e';
    }
  }
}
