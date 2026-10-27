# Abstract Factory

Choose one factory to create a compatible family of related products.

## Roles to find in the code

Abstract products: the interfaces of related objects. Abstract factory: one creation method per product role. Concrete factory: one coherent family. Client: uses products through contracts.

## Three examples

Study the scenarios in order. In each scenario, run **before**, identify the design pressure, then read and run **after**. The before version is intentionally limited in design; it is still a runnable program.

### 1. Simple: Matching UI controls

- [Before](1-example_1/before/before.dart): The caller independently chooses a light button and dark checkbox.
- [After](1-example_1/after/after.dart): A LightUiFactory or DarkUiFactory creates both controls for a screen.
- **Observe:** Each settings screen contains products from one theme.
- **Try:** Add a HighContrastUiFactory with its button and checkbox.

### 2. Intermediate: Compatible codecs

- [Before](2-example_2/before/before.dart): JSON encoding is accidentally paired with pipe decoding.
- [After](2-example_2/after/after.dart): CodecFactory creates both sides of a round trip. The pipe example intentionally supports only a nonempty list whose values exclude the delimiter.
- **Observe:** Both factories round-trip Pen and Book as two separate values.
- **Try:** Add another codec family and run the same roundTrip client unchanged.

### 3. Complex: Deployment infrastructure families

- [Before](3-example_3/before/before.dart): Independent construction mixes local storage references with a cloud queue.
- [After](3-example_3/after/after.dart): One DeploymentFactory supplies storage, queue, and audit products. ReportApplication coordinates contracts while local and cloud families remain interchangeable.
- **Observe:** Every local result starts with local; every cloud result starts with cloud.
- **Try:** Add a staging family and identify which client code stays unchanged.

## Run

From the repository root:

```sh
dart --enable-asserts bin/1-creational_patterns/5-abstract_factory/1-example_1/before/before.dart
dart --enable-asserts bin/1-creational_patterns/5-abstract_factory/1-example_1/after/after.dart
```

For the next scenarios, replace `1-example_1` with `2-example_2` or `3-example_3`. Assertions document important guarantees; the verification runner enables them automatically.

## Dart perspective and tradeoffs

Factory Method varies a product-creation hook inside an inherited workflow. Abstract Factory supplies several related product roles through composition. Adding a family is easy; adding a product role changes every factory. Family consistency depends on correct concrete factory implementations.

## Check your understanding

1. Which code decides what concrete objects are created or composed?
2. What does the client know before the refactoring, and what contract does it know after?
3. Trace one call from `main` through the pattern roles.
4. Add a variation and identify the files or classes you had to modify.
5. When would the direct before design be sufficient?
