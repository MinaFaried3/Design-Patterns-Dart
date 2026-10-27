# Adapter

Translate an existing incompatible API into the interface the client expects.

## Roles to find in the code

Target: application-facing contract. Adaptee: existing or vendor API. Adapter: implements the target and delegates with necessary translations. Client: depends only on the target.

## Three examples

Study the scenarios in order. In each scenario, run **before**, identify the design pressure, then read and run **after**. The before version is intentionally limited in design; it is still a runnable program.

### 1. Simple: Temperature units

- [Before](1-example_1/before/before.dart): The screen depends on a vendor's Fahrenheit API and repeats its conversion.
- [After](1-example_1/after/after.dart): FahrenheitSensorAdapter implements TemperatureSensor and converts the vendor value into Celsius.
- **Observe:** 86 Fahrenheit becomes Celsius: 30.0.
- **Try:** Provide a native Celsius sensor and use the same screen function.

### 2. Intermediate: Legacy payroll integration

- [Before](2-example_2/before/before.dart): Payroll switches on Employee versus LegacyOperator and knows both pay models.
- [After](2-example_2/after/after.dart): OperatorPayrollAdapter translates the legacy name and daily pay into Payable's monthly contract.
- **Observe:** The mixed list totals 200000 cents without type checks in calculatePayroll.
- **Try:** Add a contractor adapter without editing calculatePayroll.

### 3. Complex: Payment SDK migration

- [Before](3-example_3/before/before.dart): Checkout knows a vendor's payload and numeric decline code.
- [After](3-example_3/after/after.dart): Two adapters normalize synchronous maps and asynchronous vendor exceptions into one PaymentGateway contract and PaymentResult.
- **Observe:** Both gateways accept 2500 cents and normalize a 6000-cent decline to Declined.
- **Try:** Simulate an unexpected vendor failure and confirm it is not silently converted into a normal decline.

## Run

From the repository root:

```sh
dart --enable-asserts bin/2-structural_patterns/3-adapter/1-example_1/before/before.dart
dart --enable-asserts bin/2-structural_patterns/3-adapter/1-example_1/after/after.dart
```

For the next scenarios, replace `1-example_1` with `2-example_2` or `3-example_3`. Assertions document important guarantees; the verification runner enables them automatically.

## Dart perspective and tradeoffs

Adapt semantics as well as method names: units, result shapes, and error behavior must match. Catch only the vendor errors you can translate; unexpected failures should remain visible. Bridge starts with two independent dimensions, whereas Adapter integrates an existing incompatible API.

## Check your understanding

1. Which code decides what concrete objects are created or composed?
2. What does the client know before the refactoring, and what contract does it know after?
3. Trace one call from `main` through the pattern roles.
4. Add a variation and identify the files or classes you had to modify.
5. When would the direct before design be sufficient?
