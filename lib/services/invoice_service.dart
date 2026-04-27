import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_service.dart';

class InvoiceService {
  static final String _baseUrl = dotenv.get(
    'API_BASE_URL',
    fallback: 'http://192.168.0.133:3001',
  );

  /// Downloads the PDF invoice from the backend as raw bytes.
  /// [types] can include: 'land_rental', 'item_purchase', 'product_purchase'
  static Future<Uint8List> generateInvoice({
    required DateTime from,
    required DateTime to,
    required List<String> types,
  }) async {
    if (types.isEmpty) {
      throw Exception('At least one activity type must be selected.');
    }

    final fromStr = _formatDate(from);
    final toStr = _formatDate(to);
    final typesStr = types.join(',');

    final uri = Uri.parse(
      '$_baseUrl/api/v1/hedera/invoice?from=$fromStr&to=$toStr&types=$typesStr',
    );

    final response = await AuthService.authenticatedRequest('GET', uri);

    if (response.statusCode == 200) {
      return response.bodyBytes;
    }

    // Parse error message from backend
    String message = 'Failed to generate invoice (${response.statusCode})';
    try {
      final body = response.body;
      if (body.contains('"message"')) {
        final start = body.indexOf('"message":"') + 11;
        final end = body.indexOf('"', start);
        message = body.substring(start, end);
      }
    } catch (_) {}
    throw Exception(message);
  }

  static String _formatDate(DateTime dt) =>
      '${dt.year}-${_pad(dt.month)}-${_pad(dt.day)}';

  static String _pad(int n) => n.toString().padLeft(2, '0');
}
