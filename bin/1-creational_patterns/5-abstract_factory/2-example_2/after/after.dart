import 'dart:convert';

// AFTER: A factory supplies a compatible encoder/decoder pair.

// 1. PRODUCT CONTRACTS
abstract class ValueEncoder {
  String encode(List<String> values);
}

abstract class ValueDecoder {
  List<String> decode(String source);
}

// 2. PRODUCT FAMILIES
class JsonValueEncoder implements ValueEncoder {
  @override
  String encode(List<String> values) => jsonEncode(values);
}

class JsonValueDecoder implements ValueDecoder {
  @override
  List<String> decode(String source) =>
      (jsonDecode(source) as List<dynamic>).cast<String>();
}

class PipeValueEncoder implements ValueEncoder {
  @override
  String encode(List<String> values) {
    if (values.isEmpty || values.any((value) => value.contains('|'))) {
      throw ArgumentError('Pipe demo requires items without the delimiter');
    }
    return values.join('|');
  }
}

class PipeValueDecoder implements ValueDecoder {
  @override
  List<String> decode(String source) => source.split('|');
}

// 3. FACTORIES
abstract class CodecFactory {
  ValueEncoder createEncoder();
  ValueDecoder createDecoder();
}

class JsonCodecFactory implements CodecFactory {
  @override
  ValueEncoder createEncoder() => JsonValueEncoder();

  @override
  ValueDecoder createDecoder() => JsonValueDecoder();
}

class PipeCodecFactory implements CodecFactory {
  @override
  ValueEncoder createEncoder() => PipeValueEncoder();

  @override
  ValueDecoder createDecoder() => PipeValueDecoder();
}

// 4. CLIENT
List<String> roundTrip(CodecFactory factory, List<String> input) {
  final encoded = factory.createEncoder().encode(input);
  return factory.createDecoder().decode(encoded);
}

void main() {
  for (final factory in <CodecFactory>[
    JsonCodecFactory(),
    PipeCodecFactory(),
  ]) {
    final result = roundTrip(factory, ['Pen', 'Book']);
    assert(result.length == 2 && result[1] == 'Book');
    print(result);
  }
}
