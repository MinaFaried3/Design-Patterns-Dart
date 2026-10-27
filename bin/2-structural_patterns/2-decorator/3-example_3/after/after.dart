import 'dart:convert';
import 'dart:io';

// AFTER: Wrappers apply transformations on write and inverse steps on read.
// Data stays in memory. Base64 is an encoding, not encryption.

// 1. COMPONENT CONTRACT AND STORAGE
abstract class TextStore {
  void write(String value);
  String read();
}

class MemoryTextStore implements TextStore {
  String _value = '';
  @override
  void write(String value) => _value = value;
  @override
  String read() => _value;
}

// 2. DECORATORS
abstract class TextStoreDecorator implements TextStore {
  final TextStore inner;
  TextStoreDecorator(this.inner);
}

class Base64TextStore extends TextStoreDecorator {
  Base64TextStore(super.inner);

  @override
  void write(String value) => inner.write(base64Encode(utf8.encode(value)));

  @override
  String read() => utf8.decode(base64Decode(inner.read()));
}

class GzipTextStore extends TextStoreDecorator {
  GzipTextStore(super.inner);

  @override
  void write(String value) {
    inner.write(base64Encode(gzip.encode(utf8.encode(value))));
  }

  @override
  String read() => utf8.decode(gzip.decode(base64Decode(inner.read())));
}

// 3. CLIENT: Uses TextStore without transformation flags.
void main() {
  final memory = MemoryTextStore();
  final TextStore store = GzipTextStore(Base64TextStore(memory));
  const original = 'Inventory report: PEN=10, BOOK=5';
  store.write(original);

  assert(store.read() == original);
  assert(memory.read() != original);
  print('Restored: ${store.read()}');
  print('Stored as transformed text: ${memory.read() != original}');

  // The same components support a different ordering.
  final reversed = Base64TextStore(GzipTextStore(MemoryTextStore()));
  reversed.write(original);
  assert(reversed.read() == original);
  print('Reversed composition also restores: ${reversed.read()}');
}
