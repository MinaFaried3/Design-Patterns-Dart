# Decorator

Add responsibilities by wrapping objects that share the same component contract.

## Roles to find in the code

Component contract: Drink, Notifier, or TextStore. Concrete component: core behavior. Decorator: holds another component and adds behavior before or after delegation.

## Three examples

Study the scenarios in order. In each scenario, run **before**, identify the design pressure, then read and run **after**. The before version is intentionally limited in design; it is still a runnable program.

### 1. Simple: Coffee add-ons

- [Before](1-example_1/before/before.dart): A subclass is needed for every combination of ingredients.
- [After](1-example_1/after/after.dart): Milk and Sugar each wrap any Drink, including another decorator.
- **Observe:** Coffee + milk + sugar costs 27; double milk costs 30.
- **Try:** Add a Cinnamon decorator without changing Coffee, Milk, or Sugar.

### 2. Intermediate: Optional notification channels

- [Before](2-example_2/before/before.dart): Flags and branches accumulate in a central notifier.
- [After](2-example_2/after/after.dart): SMS and push decorators add deliveries around EmailNotifier. The client receives one Notifier interface.
- **Observe:** The base component returns one delivery; the composed notifier returns three.
- **Try:** Swap decorator order and inspect how delivery order changes.

### 3. Complex: Reversible storage transformations

- [Before](3-example_3/before/before.dart): Callers must repeat matching write/read flags and inverse transformation order.
- [After](3-example_3/after/after.dart): GzipTextStore and Base64TextStore wrap an in-memory TextStore. Each wrapper reverses its own transformation while delegating through the same interface.
- **Observe:** Both compositions restore the original text while the underlying memory stores transformed data.
- **Try:** Draw the call order for write and read. Explain why Base64 provides no confidentiality.

## Run

From the repository root:

```sh
dart --enable-asserts bin/2-structural_patterns/2-decorator/1-example_1/before/before.dart
dart --enable-asserts bin/2-structural_patterns/2-decorator/1-example_1/after/after.dart
```

For the next scenarios, replace `1-example_1` with `2-example_2` or `3-example_3`. Assertions document important guarantees; the verification runner enables them automatically.

## Dart perspective and tradeoffs

Composition order can change behavior. Decorator preserves the interface while adding responsibilities; Adapter translates an interface, and Proxy controls access. Wrappers should define consistent semantics for both the forward and reverse operation when supporting round trips.

## Check your understanding

1. Which code decides what concrete objects are created or composed?
2. What does the client know before the refactoring, and what contract does it know after?
3. Trace one call from `main` through the pattern roles.
4. Add a variation and identify the files or classes you had to modify.
5. When would the direct before design be sufficient?
