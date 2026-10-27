# Proxy

Provide a substitute with the same interface that controls access to a real subject.

## Roles to find in the code

Subject contract: ImageDisplay, DocumentReader, or Catalog. Real subject: does the work. Proxy: controls when and whether to delegate. Client: can use either through the same interface.

## Three examples

Study the scenarios in order. In each scenario, run **before**, identify the design pressure, then read and run **after**. The before version is intentionally limited in design; it is still a runnable program.

### 1. Simple: Lazy image loading

- [Before](1-example_1/before/before.dart): The gallery loads an unused image eagerly.
- [After](1-example_1/after/after.dart): LazyImage implements ImageDisplay and constructs RealImage only on the first display call.
- **Observe:** Loaded images: 1 after displaying the first image twice.
- **Try:** Display the second image and predict the new load count.

### 2. Intermediate: Protected document access

- [Before](2-example_2/before/before.dart): Authorization checks are duplicated and one client omits them.
- [After](2-example_2/after/after.dart): ProtectedDocumentReader checks the permission before delegating through the shared DocumentReader contract.
- **Observe:** The denied call reports Access denied; the underlying store records only one read.
- **Try:** Inject a recording reader and prove rejection never invokes it.

### 3. Complex: Asynchronous caching proxy

- [Before](3-example_3/before/before.dart): Repeated and simultaneous reads call the real service repeatedly.
- [After](3-example_3/after/after.dart): CachedCatalog caches a Future per SKU, shares in-progress work, retains success, removes failures, and supports explicit invalidation.
- **Observe:** Three matching reads use one service call; invalidation and a failed-then-retried key bring the total to four.
- **Try:** Extend the key to include a locale and explain why SKU alone would then be incorrect.

## Run

From the repository root:

```sh
dart --enable-asserts bin/2-structural_patterns/1-proxy/1-example_1/before/before.dart
dart --enable-asserts bin/2-structural_patterns/1-proxy/1-example_1/after/after.dart
```

For the next scenarios, replace `1-example_1` with `2-example_2` or `3-example_3`. Assertions document important guarantees; the verification runner enables them automatically.

## Dart perspective and tradeoffs

Proxy controls access, creation, or reuse. Decorator focuses on adding composable responsibilities. An in-memory protection proxy illustrates a boundary; actual authorization belongs at the trusted service boundary. The cache demo uses explicit invalidation and assumes SKU completely identifies the request.

## Check your understanding

1. Which code decides what concrete objects are created or composed?
2. What does the client know before the refactoring, and what contract does it know after?
3. Trace one call from `main` through the pattern roles.
4. Add a variation and identify the files or classes you had to modify.
5. When would the direct before design be sufficient?
