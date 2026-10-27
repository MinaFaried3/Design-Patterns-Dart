# Builder

Accumulate construction steps separately from the completed product; optionally reuse the same steps for different representations.

## Roles to find in the code

Product: completed result. Builder: collects parts and construction rules. Concrete builders: assemble representations. Director: optional owner of the step sequence.

## Three examples

Study the scenarios in order. In each scenario, run **before**, identify the design pressure, then read and run **after**. The before version is intentionally limited in design; it is still a runnable program.

### 1. Simple: Build a sandwich

- [Before](1-example_1/before/before.dart): A mutable product can escape before construction finishes.
- [After](1-example_1/after/after.dart): A fluent builder validates required parts and returns an immutable snapshot. Continuing construction does not mutate an existing sandwich.
- **Observe:** Whole wheat: [Cheese, Tomato], even after adding Olives to the builder.
- **Try:** Try build before adding a filling and explain why the failure belongs at the construction boundary.

### 2. Intermediate: Build a SELECT query

- [Before](2-example_2/before/before.dart): Callers repeat separator rules and must keep SQL and parameter order aligned.
- [After](2-example_2/after/after.dart): The builder owns a small query grammar and validation. The product snapshots SQL and bound values; the demo executes no database calls.
- **Observe:** SELECT * FROM inventory WHERE warehouse = ? AND quantity = ? LIMIT 5; parameters [CAIRO, 10].
- **Try:** Build two products from the same builder and verify the first parameter list does not change.

### 3. Complex: One report recipe, two representations

- [Before](3-example_3/before/before.dart): A format branch mixes construction order with output representation.
- [After](3-example_3/after/after.dart): InventoryReportDirector calls start, addRow, and finish through ReportBuilder. Markdown and CSV builders interpret the same recipe differently.
- **Observe:** Both reports total 15. Reusing a builder for another report clears the previous assembly.
- **Try:** Add an HTML builder without editing the director.

## Run

From the repository root:

```sh
dart --enable-asserts bin/1-creational_patterns/3-builder/1-example_1/before/before.dart
dart --enable-asserts bin/1-creational_patterns/3-builder/1-example_1/after/after.dart
```

For the next scenarios, replace `1-example_1` with `2-example_2` or `3-example_3`. Assertions document important guarantees; the verification runner enables them automatically.

## Dart perspective and tradeoffs

Dart named parameters often suffice for a small immutable object. Use a builder when incremental assembly, validation, snapshots, or multiple representations justify it. A fluent method chain alone does not establish the full director-and-builders structure.

## Check your understanding

1. Which code decides what concrete objects are created or composed?
2. What does the client know before the refactoring, and what contract does it know after?
3. Trace one call from `main` through the pattern roles.
4. Add a variation and identify the files or classes you had to modify.
5. When would the direct before design be sufficient?
