# Design patterns in Dart: study guide

Start with the [creational guide](bin/1-creational_patterns/README.md) or the [structural guide](bin/2-structural_patterns/README.md). Each pattern has three scenarios: simple, intermediate, and complex. Each scenario has independently runnable before and after versions.

The [behavioral examples](bin/3-behavioral_patterns/) supplied the before/after study structure. They remain an independent reference and have not been reorganized by this curriculum update.

## How to study one scenario

1. Run before. Explain its concrete design pressure before naming a pattern.
2. Read the after contract and find the participants by their roles.
3. Trace one call from main. Identify which object creates, wraps, delegates, or recurses.
4. Run after with assertions enabled and compare observable behavior.
5. Complete the README exercise. Identify the code that stays unchanged when adding a variation.
6. Decide when the original direct implementation would be sufficient.

The levels add depth to the pattern itself: copying nested mutable state, creating related product families, composing wrappers, sharing asynchronous work, or combining recursive groups. No scenario needs a server, database, UI framework, credentials, interactive input, or third-party runtime package.

## Important distinctions

| Compare | Responsibility to look for |
| --- | --- |
| Factory Method / Abstract Factory | An overridable creation hook in a creator workflow / a factory object providing a related product family |
| Builder / Prototype | Assemble a product in steps / copy a configured product |
| Singleton / ordinary injection | Enforce one instance within an isolate / explicitly pass whatever instance the application chooses |
| Adapter / Decorator / Proxy | Translate an interface / add composable responsibilities / control access or reuse |
| Facade / Adapter | Simplify a subsystem workflow / satisfy an existing target interface |
| Bridge / Adapter | Design two independently varying dimensions / integrate an existing incompatible API |
| Composite / Iterator | Model leaves and groups uniformly / expose a traversal through a sequence interface |
| Flyweight / Singleton | Share many immutable values by intrinsic-state key / enforce one instance of a resource |

## Dart perspective

- Use abstract classes to make pattern contracts explicit. Clients accept those contracts rather than specific implementations.
- Constructor injection makes object composition visible in main.
- Dart's factory constructor is a language feature, not automatically the GoF Factory Method pattern.
- Private named constructors and static fields can implement a Singleton; static state belongs to an isolate.
- Cloning requires explicit decisions about nested mutable objects. Final fields alone do not make a contained List immutable.
- Unmodifiable collections protect built products and shared flyweights from accidental mutation.
- Records make concise value keys for pools keyed by several fields.
- A Future can represent work already in progress. Caching it can share initialization or matching reads.
- Iterable and Iterator separate a sequence from one traversal. A sync* generator can supply an iterator without manually implementing its state.

## Run and verify

Use the Dart SDK constraint in pubspec.yaml. Run commands from the repository root:

```sh
dart --enable-asserts bin/1-creational_patterns/2-prototype/1-example_1/before/before.dart
dart --enable-asserts bin/1-creational_patterns/2-prototype/1-example_1/after/after.dart

dart analyze bin/1-creational_patterns bin/2-structural_patterns tool test
dart tool/verify_examples.dart
dart test
```

The runner verifies all twelve pattern folders and all 72 entry points with assertions enabled. Tests check contract behavior and failure paths in addition to the illustrative assertions inside main.
