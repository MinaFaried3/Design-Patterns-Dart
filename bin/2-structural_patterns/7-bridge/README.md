# Bridge

Separate a high-level abstraction from an implementation dimension so both can vary independently.

## Roles to find in the code

Abstraction: Remote, Shape, or StockReport. Refined abstraction: a feature or domain specialization. Implementor: Device, Renderer, or ReportDelivery contract. Concrete implementors: interchangeable backends.

## Three examples

Study the scenarios in order. In each scenario, run **before**, identify the design pressure, then read and run **after**. The before version is intentionally limited in design; it is still a runnable program.

### 1. Simple: Remotes and devices

- [Before](1-example_1/before/before.dart): Advanced remote features are duplicated for TV and radio subclasses.
- [After](1-example_1/after/after.dart): Remote holds Device. AdvancedRemote adds mute once; Tv and Radio implement device operations independently.
- **Observe:** The same AdvancedRemote mutes either a TV or a radio.
- **Try:** Add a Speaker device without adding an AdvancedSpeakerRemote.

### 2. Intermediate: Shapes and renderers

- [Before](2-example_2/before/before.dart): Each shape-renderer combination has its own class.
- [After](2-example_2/after/after.dart): Circle and Rectangle hold Renderer and delegate backend-specific drawing. Two shapes combine with two renderers without four paired subclasses.
- **Observe:** Vector and raster output are produced for both shapes.
- **Try:** Add one renderer and count how many shape classes must change.

### 3. Complex: Reports and delivery backends

- [Before](3-example_3/before/before.dart): Report calculations are duplicated across email and archive variants.
- [After](3-example_3/after/after.dart): StockReport owns validation and publishing. SummaryReport and LowStockReport specialize report content; independent ReportDelivery implementations deliver it asynchronously.
- **Observe:** Both backends receive matching summary and low-stock content; each records two reports.
- **Try:** Add another report and another delivery backend, then list the new combinations without creating paired subclasses.

## Run

From the repository root:

```sh
dart --enable-asserts bin/2-structural_patterns/7-bridge/1-example_1/before/before.dart
dart --enable-asserts bin/2-structural_patterns/7-bridge/1-example_1/after/after.dart
```

For the next scenarios, replace `1-example_1` with `2-example_2` or `3-example_3`. Assertions document important guarantees; the verification runner enables them automatically.

## Dart perspective and tradeoffs

Having an interface alone is not the complete point. Identify two dimensions and show that combinations use composition instead of one subclass per pair. Adapter translates a preexisting incompatible API; Bridge deliberately separates dimensions. Strategy is related composition, but its emphasis is selecting an algorithm.

## Check your understanding

1. Which code decides what concrete objects are created or composed?
2. What does the client know before the refactoring, and what contract does it know after?
3. Trace one call from `main` through the pattern roles.
4. Add a variation and identify the files or classes you had to modify.
5. When would the direct before design be sufficient?
