// AFTER: Cache completed reads and share matching requests in progress.

// 1. SUBJECT CONTRACT AND REAL SUBJECT
abstract class Catalog {
  Future<String> fetch(String sku);
}

class CatalogService implements Catalog {
  int calls = 0;
  bool failNext = false;

  @override
  Future<String> fetch(String sku) async {
    calls++;
    await Future<void>.value();
    if (failNext) {
      failNext = false;
      throw StateError('Temporary catalog failure');
    }
    return 'Product $sku';
  }
}

// 2. CACHING PROXY: One cache entry per complete request key.
class CachedCatalog implements Catalog {
  final Catalog _subject;
  final Map<String, Future<String>> _cache = {};
  CachedCatalog(this._subject);

  @override
  Future<String> fetch(String sku) {
    final existing = _cache[sku];
    if (existing != null) return existing;

    late final Future<String> request;
    request = Future<String>.sync(() => _subject.fetch(sku)).then(
      (value) => value,
      onError: (Object error, StackTrace stack) {
        // An invalidated older request must not evict its replacement.
        if (identical(_cache[sku], request)) _cache.remove(sku);
        Error.throwWithStackTrace(error, stack);
      },
    );
    _cache[sku] = request;
    return request;
  }

  void invalidate(String sku) => _cache.remove(sku);
}

// 3. USAGE: Deduplication, explicit invalidation, and failure retry.
Future<void> main() async {
  final service = CatalogService();
  final Catalog catalog = CachedCatalog(service);
  final results = await Future.wait([
    catalog.fetch('PEN'),
    catalog.fetch('PEN'),
  ]);
  await catalog.fetch('PEN');
  assert(service.calls == 1);
  print(results);
  print('Calls after repeated reads: ${service.calls}');

  (catalog as CachedCatalog).invalidate('PEN');
  await catalog.fetch('PEN');
  assert(service.calls == 2);

  service.failNext = true;
  try {
    await catalog.fetch('BOOK');
  } on StateError {
    print('Failed read removed from cache');
  }
  await catalog.fetch('BOOK');
  assert(service.calls == 4);
  print('Calls after invalidation and retry: ${service.calls}');
}
