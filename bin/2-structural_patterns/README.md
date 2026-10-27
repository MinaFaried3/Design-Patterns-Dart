# Structural patterns

These patterns organize object relationships: wrapping, translating, grouping, coordinating, and sharing objects.

The structure follows the behavioral examples: a pattern folder contains numbered scenario folders, each containing independent `before` and `after` programs. Every scenario has a runnable `main()` and uses only Dart SDK libraries. Scenarios deliberately stay in one file per version so you can compare them directly without navigating shared infrastructure.

```text
pattern/
  README.md
  1-example_1/          # Simple: the essential mechanism
    before/before.dart
    after/after.dart
  2-example_2/          # Intermediate: a practical variation
    before/before.dart
    after/after.dart
  3-example_3/          # Complex: deeper composition or lifecycle
    before/before.dart
    after/after.dart
```

## Pattern map

| Pattern | What relationship does the pattern introduce? |
| --- | --- |
| [Proxy](1-proxy/README.md) | Provide a substitute with the same interface that controls access to a real subject. |
| [Decorator](2-decorator/README.md) | Add responsibilities by wrapping objects that share the same component contract. |
| [Adapter](3-adapter/README.md) | Translate an existing incompatible API into the interface the client expects. |
| [Facade](4-facade/README.md) | Offer a small task-oriented API over several subsystem APIs and their coordination rules. |
| [Flyweight](5-flyweight/README.md) | Reduce duplication by sharing immutable intrinsic state while keeping per-occurrence extrinsic state outside it. |
| [Composite](6-composite/README.md) | Represent a part-whole tree so clients can use leaves and groups through one interface. |
| [Bridge](7-bridge/README.md) | Separate a high-level abstraction from an implementation dimension so both can vary independently. |

## Scenario map

| Pattern | Simple | Intermediate | Complex |
| --- | --- | --- | --- |
| Proxy | Lazy image loading | Protected document access | Asynchronous caching proxy |
| Decorator | Coffee add-ons | Optional notification channels | Reversible storage transformations |
| Adapter | Temperature units | Legacy payroll integration | Payment SDK migration |
| Facade | Home theater | Archive and deliver a stock report | Checkout with compensation |
| Flyweight | Forest tree types | Document text styles | Tile map texture pool |
| Composite | Files and folders | Arithmetic expression trees | Explainable approval policies |
| Bridge | Remotes and devices | Shapes and renderers | Reports and delivery backends |

## Study workflow

1. Read a pattern's core idea and roles in its README.
2. Run its first before program and name the specific design pressure.
3. Compare the after program: locate the contract, concrete participants, and client.
4. Trace a call before running it; then check the output and assertions.
5. Complete the small extension exercise before proceeding to the next scenario.
6. Explain what the abstraction costs and when a simpler direct design would suffice.

Start with example 1 of each pattern, then revisit the category for examples 2 and 3. Keep the data and workflow in mind while comparing before and after; the goal is to understand the responsibility moved by the pattern, not to memorize class names.

## Verification

From the repository root:

```sh
dart analyze bin/2-structural_patterns
dart tool/verify_examples.dart
dart test
```

The verification runner checks the full 5-creational / 7-structural structure, then runs all 72 before/after programs with assertions enabled. The tests exercise semantic guarantees such as copy independence, interface substitution, complete cache keys, and failure cleanup. All network, storage, and payment services in these examples are simulated in memory.
