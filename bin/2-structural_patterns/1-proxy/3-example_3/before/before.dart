// BEFORE: Identical simultaneous reads repeat the expensive operation.
class CatalogService {
  int calls = 0;
  Future<String> fetch(String sku) async {
    calls++;
    await Future<void>.value();
    return 'Product $sku';
  }
}

Future<void> main() async {
  final service = CatalogService();
  final results = await Future.wait([
    service.fetch('PEN'),
    service.fetch('PEN'),
  ]);
  print(results);
  print('Service calls: ${service.calls}');
}
