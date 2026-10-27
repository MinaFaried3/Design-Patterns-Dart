import 'dart:convert';

// BEFORE: Independently selected encoder and decoder disagree on format.
class JsonEncoder {
  String encode(List<String> values) => jsonEncode(values);
}

class PipeDecoder {
  List<String> decode(String source) => source.split('|');
}

void main() {
  final encoded = JsonEncoder().encode(['Pen', 'Book']);
  final decoded = PipeDecoder().decode(encoded);
  print('Encoded: $encoded');
  print('Decoded item count: ${decoded.length}'); // 1 instead of 2.
}
