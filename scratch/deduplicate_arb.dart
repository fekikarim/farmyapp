import 'dart:convert';
import 'dart:io';

void main() async {
  final files = [
    'lib/l10n/app_en.arb',
    'lib/l10n/app_fr.arb',
    'lib/l10n/app_es.arb',
  ];

  for (final filePath in files) {
    final file = File(filePath);
    if (!file.existsSync()) continue;

    final content = await file.readAsString();
    // We can't just parse as JSON because it might have duplicates which jsonDecode doesn't like or just overwrites.
    // But actually, jsonDecode handles duplicate keys by taking the last one.
    // However, ARB files have metadata like "@key" which must be kept with "key".

    // Let's try to parse it and write it back neatly.
    try {
      final Map<String, dynamic> data = jsonDecode(content);
      final sortedKeys = data.keys.toList()..sort();

      final Map<String, dynamic> result = {};
      // Preserve @@locale if exists at top
      if (data.containsKey('@@locale')) {
        result['@@locale'] = data['@@locale'];
      }

      for (final key in sortedKeys) {
        if (key == '@@locale') continue;
        result[key] = data[key];
      }

      final encoder = JsonEncoder.withIndent('  ');
      await file.writeAsString(encoder.convert(result));
      print('Deduplicated and sorted $filePath');
    } catch (e) {
      print('Error parsing $filePath: $e');
    }
  }
}
