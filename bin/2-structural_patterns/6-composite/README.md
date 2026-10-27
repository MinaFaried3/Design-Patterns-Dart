# Composite

Represent a part-whole tree so clients can use leaves and groups through one interface.

## Roles to find in the code

Component: shared operations. Leaf: performs the operation directly. Composite: contains components and combines their results. Client: invokes the root without branching on concrete types.

## Three examples

Study the scenarios in order. In each scenario, run **before**, identify the design pressure, then read and run **after**. The before version is intentionally limited in design; it is still a runnable program.

### 1. Simple: Files and folders

- [Before](1-example_1/before/before.dart): Clients distinguish files from folders and manually sum separate collections.
- [After](1-example_1/after/after.dart): Both implement StorageEntry.size. Folder delegates to children, which may be other folders.
- **Observe:** The root totals 150 bytes; the same client can print a single 25-byte leaf; an empty folder totals zero.
- **Try:** Add a nested folder without editing printSize.

### 2. Intermediate: Arithmetic expression trees

- [Before](2-example_2/before/before.dart): A central evaluator interprets operation tags and nullable node fields.
- [After](2-example_2/after/after.dart): Number, Sum, and Product implement evaluate and describe. Composites recursively delegate through Expression.
- **Observe:** ((3.0 + 2.0) * 4.0) evaluates to 20.0.
- **Try:** Add a new composite operation without editing existing node classes.

### 3. Complex: Explainable approval policies

- [Before](3-example_3/before/before.dart): Approval and explanation routines repeat the same nested conditions.
- [After](3-example_3/after/after.dart): HasRole and WithinLimit are leaves; AllOf and AnyOf are nested composites. Evaluation builds a Decision tree so all child results remain inspectable.
- **Observe:** A manager requesting 9000 passes; a manager requesting 15000 fails; an admin passes either amount.
- **Try:** Compose a second policy from the existing rule types and explain the empty-group semantics of every versus any.

## Run

From the repository root:

```sh
dart --enable-asserts bin/2-structural_patterns/6-composite/1-example_1/before/before.dart
dart --enable-asserts bin/2-structural_patterns/6-composite/1-example_1/after/after.dart
```

For the next scenarios, replace `1-example_1` with `2-example_2` or `3-example_3`. Assertions document important guarantees; the verification runner enables them automatically.

## Dart perspective and tradeoffs

Recursion alone is not Composite: leaves and groups must share a useful contract. These examples construct immutable child lists and assume acyclic trees. Composite models the tree; Iterator can separately expose its traversal as a sequence.

## Check your understanding

1. Which code decides what concrete objects are created or composed?
2. What does the client know before the refactoring, and what contract does it know after?
3. Trace one call from `main` through the pattern roles.
4. Add a variation and identify the files or classes you had to modify.
5. When would the direct before design be sufficient?
