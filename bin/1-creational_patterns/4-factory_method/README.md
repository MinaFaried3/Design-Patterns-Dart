# Factory Method

A creator owns a useful workflow and delegates product creation to an overridable method.

## Roles to find in the code

Product: MessageSender, StockFormatter, or StockReader. Creator: reusable workflow plus creation hook. Concrete creator: overrides the hook. Client: chooses a creator.

## Three examples

Study the scenarios in order. In each scenario, run **before**, identify the design pressure, then read and run **after**. The before version is intentionally limited in design; it is still a runnable program.

### 1. Simple: Notification workflows

- [Before](1-example_1/before/before.dart): The shared notification flow directly chooses EmailSender or SmsSender.
- [After](1-example_1/after/after.dart): NotificationFlow.notify prepares the message and calls createSender. EmailFlow and SmsFlow override that factory method.
- **Observe:** Email: [APP] Welcome and SMS: [APP] Welcome.
- **Try:** Add PushFlow and PushSender without editing NotificationFlow.notify.

### 2. Intermediate: Report exporters

- [Before](2-example_2/before/before.dart): Validation, sorting, and format selection share one method.
- [After](2-example_2/after/after.dart): ReportExporter reuses validation and sorting; subclasses supply TextFormatter or JsonFormatter.
- **Observe:** Both formats receive Book before Pen, including the JSON object.
- **Try:** Override createFormatter with a fake that records its input and verify it receives sorted data.

### 3. Complex: Asynchronous inventory import

- [Before](3-example_3/before/before.dart): Import orchestration depends directly on every parser type.
- [After](3-example_3/after/after.dart): InventoryImportJob obtains a StockReader from its factory method, then shares asynchronous reading, validation, and duplicate-SKU aggregation.
- **Observe:** Both sources produce PEN: 5 and BOOK: 1; the common workflow rejects a negative quantity.
- **Try:** Add a reader and creator for another input format while leaving run unchanged.

## Run

From the repository root:

```sh
dart --enable-asserts bin/1-creational_patterns/4-factory_method/1-example_1/before/before.dart
dart --enable-asserts bin/1-creational_patterns/4-factory_method/1-example_1/after/after.dart
```

For the next scenarios, replace `1-example_1` with `2-example_2` or `3-example_3`. Assertions document important guarantees; the verification runner enables them automatically.

## Dart perspective and tradeoffs

A function containing a switch that returns objects is a simple factory. A Dart factory constructor is a language feature. The GoF Factory Method demonstrated here is a method overridden by creator subclasses and used by the inherited workflow.

## Check your understanding

1. Which code decides what concrete objects are created or composed?
2. What does the client know before the refactoring, and what contract does it know after?
3. Trace one call from `main` through the pattern roles.
4. Add a variation and identify the files or classes you had to modify.
5. When would the direct before design be sufficient?
