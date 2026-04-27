import 'hedera_service.dart';

class InvoicePreviewData {
  final int recordCount;
  final double totalAmount;
  final Map<String, int> countByType;

  const InvoicePreviewData({
    required this.recordCount,
    required this.totalAmount,
    required this.countByType,
  });
}

class InvoicePreviewService {
  /// Fetches Hedera registry for the date range and filters by types locally.
  /// Returns summary stats for the preview card.
  static Future<InvoicePreviewData> fetchPreview({
    required DateTime from,
    required DateTime to,
    required List<String> types,
  }) async {
    final all = await HederaService.getMyRegistry(from: from, to: to);

    final filtered = all.where((e) => types.contains(e.type)).toList();

    final countByType = <String, int>{};
    double total = 0.0;

    for (final entry in filtered) {
      countByType[entry.type] = (countByType[entry.type] ?? 0) + 1;
      total += entry.amount ?? 0.0;
    }

    return InvoicePreviewData(
      recordCount: filtered.length,
      totalAmount: total,
      countByType: countByType,
    );
  }
}
