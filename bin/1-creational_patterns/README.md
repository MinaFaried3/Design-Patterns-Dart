# Creational patterns

These patterns organize object creation: who constructs an object, how its configuration is assembled, and whether state is copied or shared.

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

| Pattern | What varies during creation? |
| --- | --- |
| [Singleton](1-singleton/README.md) | Control construction so callers share one instance within a Dart isolate. |
| [Prototype](2-prototype/README.md) | Create a new object by asking an existing configured object to copy itself. |
| [Builder](3-builder/README.md) | Accumulate construction steps separately from the completed product; optionally reuse the same steps for different representations. |
| [Factory Method](4-factory_method/README.md) | A creator owns a useful workflow and delegates product creation to an overridable method. |
| [Abstract Factory](5-abstract_factory/README.md) | Choose one factory to create a compatible family of related products. |

## Scenario map

| Pattern | Simple | Intermediate | Complex |
| --- | --- | --- | --- |
| Singleton | Shared logger | One inventory store | Asynchronous initialization |
| Prototype | Copy a configured label | Deep-copy an employee | Polymorphic document templates |
| Builder | Build a sandwich | Build a SELECT query | One report recipe, two representations |
| Factory Method | Notification workflows | Report exporters | Asynchronous inventory import |
| Abstract Factory | Matching UI controls | Compatible codecs | Deployment infrastructure families |

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
dart analyze bin/1-creational_patterns
dart tool/verify_examples.dart
dart test
```

The verification runner checks the full 5-creational / 7-structural structure, then runs all 72 before/after programs with assertions enabled. The tests exercise semantic guarantees such as copy independence, interface substitution, complete cache keys, and failure cleanup. All network, storage, and payment services in these examples are simulated in memory.
