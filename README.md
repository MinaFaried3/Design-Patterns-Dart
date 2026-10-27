# Design Patterns in Dart

Learn each pattern by comparing a runnable **before** design with its **after**
refactoring. The creational and structural categories contain 36 scenarios:
three levels for each of five creational and seven structural patterns.

## Start studying

- [Study guide](STUDY_GUIDE.md): learning workflow, Dart concepts, and pattern comparisons.
- [Creational patterns](bin/1-creational_patterns/README.md): Singleton, Prototype,
  Builder, Factory Method, and Abstract Factory.
- [Structural patterns](bin/2-structural_patterns/README.md): Proxy, Decorator,
  Adapter, Facade, Flyweight, Composite, and Bridge.
- [Behavioral examples](bin/3-behavioral_patterns/): the original before/after reference.

Each creational or structural pattern has this layout:

```text
pattern/
  README.md
  1-example_1/          # Simple
    before/before.dart
    after/after.dart
  2-example_2/          # Intermediate
    before/before.dart
    after/after.dart
  3-example_3/          # Complex
    before/before.dart
    after/after.dart
```

Pattern READMEs explain the problem, participant roles, expected observations,
Dart tradeoffs, and an extension exercise for each scenario. All 72 new example
programs run independently using only Dart SDK libraries and in-memory services.

## Run

Use the Dart SDK version required by [pubspec.yaml](pubspec.yaml).
From the repository root:

```sh
dart --enable-asserts bin/1-creational_patterns/2-prototype/1-example_1/before/before.dart
dart --enable-asserts bin/1-creational_patterns/2-prototype/1-example_1/after/after.dart
```

## Verify

```sh
dart pub get
dart analyze bin/1-creational_patterns bin/2-structural_patterns tool test
dart tool/verify_examples.dart
dart test
```

The runner validates the scenario structure and executes every before/after
program with assertions enabled. Tests additionally cover copy independence,
interface substitution, compatible families, asynchronous sharing, complete
flyweight keys, and cleanup after partial failures.
