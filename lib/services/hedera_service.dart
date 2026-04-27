import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_service.dart';

class HederaEntry {
  final String type;
  final String id;
  final String label;
  final String sublabel;
  final double? amount;
  final String currency;
  final String paymentMethod;
  final String status;
  final String hederaTransactionId;
  final DateTime timestamp;

  HederaEntry({
    required this.type,
    required this.id,
    required this.label,
    required this.sublabel,
    this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.status,
    required this.hederaTransactionId,
    required this.timestamp,
  });

  factory HederaEntry.fromJson(Map<String, dynamic> json) {
    return HederaEntry(
      type: json['type'] ?? '',
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      sublabel: json['sublabel'] ?? '',
      amount: json['amount'] != null ? double.tryParse(json['amount'].toString()) : null,
      currency: json['currency'] ?? 'usd',
      paymentMethod: json['payment_method'] ?? '',
      status: json['status'] ?? '',
      hederaTransactionId: json['hedera_transaction_id'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  /// Returns the HashScan URL for this transaction
  String get hashScanUrl =>
      'https://hashscan.io/testnet/transaction/${Uri.encodeComponent(hederaTransactionId)}';
}

class HederaService {
  static final String _baseUrl = dotenv.get(
    'API_BASE_URL',
    fallback: 'http://192.168.0.133:3001',
  );

  static Future<List<HederaEntry>> getMyRegistry({
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final params = <String, String>{};
      if (from != null) params['from'] = _formatDate(from);
      if (to != null) params['to'] = _formatDate(to);

      final uri = Uri.parse('$_baseUrl/api/v1/hedera/my-registry')
          .replace(queryParameters: params.isNotEmpty ? params : null);

      final response = await AuthService.authenticatedRequest('GET', uri);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List data = body['data'] ?? [];
        return data.map((e) => HederaEntry.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static String _formatDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
