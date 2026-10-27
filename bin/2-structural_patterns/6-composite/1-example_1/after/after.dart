// AFTER: A leaf and a group share the same component contract.

// 1. COMPONENT
abstract class StorageEntry {
  int get size;
}

// 2. LEAF
class FileItem implements StorageEntry {
  @override
  final int size;
  FileItem(this.size);
}

// 3. COMPOSITE: Children can themselves be leaves or composites.
class Folder implements StorageEntry {
  final List<StorageEntry> children;
  Folder(List<StorageEntry> children) : children = List.unmodifiable(children);

  @override
  int get size => children.fold(0, (total, child) => total + child.size);
}

// 4. CLIENT: The same operation handles either kind.
void printSize(StorageEntry entry) => print('Total bytes: ${entry.size}');

void main() {
  final root = Folder([
    FileItem(100),
    Folder([FileItem(50)]),
  ]);
  assert(root.size == 150);
  assert(Folder([]).size == 0);
  printSize(root);
  printSize(FileItem(25));
}
