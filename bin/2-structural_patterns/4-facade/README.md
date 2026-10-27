# Facade

Offer a small task-oriented API over several subsystem APIs and their coordination rules.

## Roles to find in the code

Subsystems: independent low-level capabilities. Facade: coordinates a useful application task. Client: calls the facade instead of repeating orchestration.

## Three examples

Study the scenarios in order. In each scenario, run **before**, identify the design pressure, then read and run **after**. The before version is intentionally limited in design; it is still a runnable program.

### 1. Simple: Home theater

- [Before](1-example_1/before/before.dart): Each screen must remember projector, sound, and player calls in order.
- [After](1-example_1/after/after.dart): HomeTheater.watch exposes one meaningful operation and sequences its three subsystems.
- **Observe:** Projector on, Volume: 20, Playing Dart Patterns.
- **Try:** Add a preparation step without changing the watch call in the client.

### 2. Intermediate: Archive and deliver a stock report

- [Before](2-example_2/before/before.dart): Every report caller repeats reading, rendering, saving, and delivery.
- [After](2-example_2/after/after.dart): StockReportFacade.exportAndSend coordinates injected subsystems; the client supplies only the recipient.
- **Observe:** REPORT-1 is sent to Mona and its archived content contains both stock rows.
- **Try:** Replace ReportDelivery with a recording implementation and inspect the report ID it receives.

### 3. Complex: Checkout with compensation

- [Before](3-example_3/before/before.dart): A failed payment leaves reserved inventory deducted.
- [After](3-example_3/after/after.dart): CheckoutFacade owns step order and tracks which steps succeeded. Payment failure releases stock; shipping failure refunds payment and releases stock in reverse order.
- **Observe:** After one successful and two failed orders, stock stays 8 and balance stays 800 cents.
- **Try:** Explain why this synchronous in-memory compensation is insufficient to guarantee atomicity across remote services.

## Run

From the repository root:

```sh
dart --enable-asserts bin/2-structural_patterns/4-facade/1-example_1/before/before.dart
dart --enable-asserts bin/2-structural_patterns/4-facade/1-example_1/after/after.dart
```

For the next scenarios, replace `1-example_1` with `2-example_2` or `3-example_3`. Assertions document important guarantees; the verification runner enables them automatically.

## Dart perspective and tradeoffs

Facade simplifies access and may coordinate compensation, but it does not itself provide database transactions, distributed atomicity, or retry safety. Keep subsystem responsibilities separate rather than moving all implementation into a giant facade.

## Check your understanding

1. Which code decides what concrete objects are created or composed?
2. What does the client know before the refactoring, and what contract does it know after?
3. Trace one call from `main` through the pattern roles.
4. Add a variation and identify the files or classes you had to modify.
5. When would the direct before design be sufficient?
