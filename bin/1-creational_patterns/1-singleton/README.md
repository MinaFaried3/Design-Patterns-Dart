# Singleton

Control construction so callers share one instance within a Dart isolate.

## Roles to find in the code

Private constructor: construction gate. Static field: shared instance or shared initialization Future. Clients: consumers of the shared resource.

## Three examples

Study the scenarios in order. In each scenario, run **before**, identify the design pressure, then read and run **after**. The before version is intentionally limited in design; it is still a runnable program.

### 1. Simple: Shared logger

- [Before](1-example_1/before/before.dart): Independent loggers split a history that should be shared.
- [After](1-example_1/after/after.dart): A private constructor and a factory constructor return the same AppLogger. Read-only history prevents callers from modifying the internal list.
- **Observe:** Same logger: true; both messages appear in the shared history.
- **Try:** Remove the factory redirect and predict which assertion fails.

### 2. Intermediate: One inventory store

- [Before](2-example_2/before/before.dart): Checkout decreases one stock counter while the report reads a different counter.
- [After](2-example_2/after/after.dart): A static instance owns stock. Both clients receive that instance through constructor injection, making the shared dependency visible.
- **Observe:** Both clients report 7 items after reserving 3 from 10.
- **Try:** Explain why passing one ordinary InventoryStore instance could also satisfy this application's sharing requirement.

### 3. Complex: Asynchronous initialization

- [Before](3-example_3/before/before.dart): Simultaneous callers independently initialize the same resource.
- [After](3-example_3/after/after.dart): Cache the Future before awaiting it. Concurrent calls share both initialization and its resulting object. Clear the cached Future on failure to permit retry.
- **Observe:** One failed source call plus one shared retry: Source calls: 2; Same settings: true.
- **Try:** Explain why caching only the finished Settings object can allow duplicate initialization.

## Run

From the repository root:

```sh
dart --enable-asserts bin/1-creational_patterns/1-singleton/1-example_1/before/before.dart
dart --enable-asserts bin/1-creational_patterns/1-singleton/1-example_1/after/after.dart
```

For the next scenarios, replace `1-example_1` with `2-example_2` or `3-example_3`. Assertions document important guarantees; the verification runner enables them automatically.

## Dart perspective and tradeoffs

Dart statics are isolate-local. Singleton does not share memory across isolates or provide thread synchronization. Prefer ordinary objects passed through constructors when global uniqueness is unnecessary. A Dart factory constructor alone does not imply Singleton.

## Check your understanding

1. Which code decides what concrete objects are created or composed?
2. What does the client know before the refactoring, and what contract does it know after?
3. Trace one call from `main` through the pattern roles.
4. Add a variation and identify the files or classes you had to modify.
5. When would the direct before design be sufficient?
