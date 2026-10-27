// BEFORE: Every caller must remember to enforce the access rule.
class DocumentStore {
  int reads = 0;
  String read(String id) {
    reads++;
    return 'Confidential document $id';
  }
}

String readFromScreen(DocumentStore store, bool canRead, String id) {
  if (!canRead) throw StateError('Access denied');
  return store.read(id);
}

void main() {
  final store = DocumentStore();
  print(readFromScreen(store, true, 'DOC-1'));
  // Another client forgets the access check.
  print(store.read('DOC-1'));
  print('Underlying reads: ${store.reads}');
}
