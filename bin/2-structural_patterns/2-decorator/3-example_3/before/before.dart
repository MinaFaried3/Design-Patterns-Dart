import 'dart:convert';
import 'dart:io';

// BEFORE: Storage owns every optional transformation and its inverse.
class TextStore {
  String _value = '';

  void write(String value, {bool compress = false, bool encode = false}) {
    if (compress) value = base64Encode(gzip.encode(utf8.encode(value)));
    if (encode) value = base64Encode(utf8.encode(value));
    _value = value;
  }

  String read({bool compress = false, bool encode = false}) {
    var value = _value;
    if (encode) value = utf8.decode(base64Decode(value));
    if (compress) value = utf8.decode(gzip.decode(base64Decode(value)));
    return value;
  }
}

void main() {
  final store = TextStore();
  store.write('Inventory report', compress: true, encode: true);
  print(store.read(compress: true, encode: true));
  // Every caller must remember matching flags and inverse order.
}
