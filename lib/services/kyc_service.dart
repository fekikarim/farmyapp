import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_service.dart';

class KycService {
  static final String _baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://192.168.0.133:3001';

  static Future<Map<String, dynamic>> submitKyc({
    required String role,
    required File frontImage,
    required File backImage,
    required File selfieImage,
  }) async {
    print('Submitting KYC for role: $role');
    try {
      final url = Uri.parse('$_baseUrl/api/v1/kyc/start');
      
      var request = http.MultipartRequest('POST', url);
      
      // Get token from AuthService
      final token = await AuthService.getAccessToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      request.fields['role'] = role;
      
      // Explicitly set content type to image/jpeg
      request.files.add(await http.MultipartFile.fromPath(
        'front_image', 
        frontImage.path,
        contentType: MediaType('image', 'jpeg'),
      ));
      request.files.add(await http.MultipartFile.fromPath(
        'back_image', 
        backImage.path,
        contentType: MediaType('image', 'jpeg'),
      ));
      request.files.add(await http.MultipartFile.fromPath(
        'selfie_image', 
        selfieImage.path,
        contentType: MediaType('image', 'jpeg'),
      ));

      print('Sending KYC request...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body)['message'] ?? 'Failed to submit KYC';
        return Future.error(error);
      }
    } catch (e) {
      print('Error in submitKyc: $e');
      return Future.error(e.toString());
    }
  }
}
