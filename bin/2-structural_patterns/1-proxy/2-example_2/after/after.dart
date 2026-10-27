// AFTER: A protection proxy checks access before delegating.

// 1. SUBJECT CONTRACT AND REAL SUBJECT
abstract class DocumentReader {
  String read(String id);
}

class DocumentStore implements DocumentReader {
  int reads = 0;
  @override
  String read(String id) {
    reads++;
    return 'Confidential document $id';
  }
}

// 2. PROXY
class ProtectedDocumentReader implements DocumentReader {
  final DocumentReader _subject;
  final bool canRead;
  ProtectedDocumentReader(this._subject, {required this.canRead});

  @override
  String read(String id) {
    if (!canRead) throw StateError('Access denied');
    return _subject.read(id);
  }
}

// 3. CLIENT: Receives only the permitted access path.
String openDocument(DocumentReader reader) => reader.read('DOC-1');

void main() {
  final store = DocumentStore();
  final allowed = ProtectedDocumentReader(store, canRead: true);
  final denied = ProtectedDocumentReader(store, canRead: false);
  print(openDocument(allowed));
  try {
    openDocument(denied);
    throw StateError('The proxy should reject this request');
  } on StateError catch (error) {
    assert(error.message == 'Access denied');
    print(error.message);
  }
  assert(store.reads == 1); // Rejected call never reached the real subject.
  print('Underlying reads: ${store.reads}');
}
