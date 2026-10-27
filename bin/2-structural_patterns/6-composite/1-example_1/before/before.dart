// BEFORE: Files and folders have different APIs, so clients branch on type.
class FileItem {
  final int bytes;
  FileItem(this.bytes);
}

class Folder {
  final List<FileItem> files;
  final List<Folder> folders;
  Folder(this.files, this.folders);
}

int totalSize(Object item) {
  if (item is FileItem) return item.bytes;
  if (item is Folder) {
    return item.files.fold(0, (total, file) => total + file.bytes) +
        item.folders.fold(0, (total, folder) => total + totalSize(folder));
  }
  throw ArgumentError('Unknown item');
}

void main() {
  final root = Folder(
    [FileItem(100)],
    [
      Folder([FileItem(50)], []),
    ],
  );
  print('Total bytes: ${totalSize(root)}');
}
