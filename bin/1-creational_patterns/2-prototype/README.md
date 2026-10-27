# Prototype

Create a new object by asking an existing configured object to copy itself.

## Roles to find in the code

Prototype contract: clone. Concrete prototype: owns its copy semantics. Registry: optional store of named templates. Client: requests and customizes copies.

## Three examples

Study the scenarios in order. In each scenario, run **before**, identify the design pressure, then read and run **after**. The before version is intentionally limited in design; it is still a runnable program.

### 1. Simple: Copy a configured label

- [Before](1-example_1/before/before.dart): Every client repeats the template's construction details.
- [After](1-example_1/after/after.dart): Label.clone owns copying its configuration. Each copy can change text independently.
- **Observe:** Draft, Invoice, and Receipt retain blue, 14 while remaining separate objects.
- **Try:** Add a fontFamily property and identify the single cloning method that needs updating.

### 2. Intermediate: Deep-copy an employee

- [Before](2-example_2/before/before.dart): A shallow copy shares Address and the skills list with its template.
- [After](2-example_2/after/after.dart): Clone the nested Address and copy the list of immutable strings.
- **Observe:** The template stays Cairo, [Dart]; the copy becomes Alexandria, [Dart, SQL].
- **Try:** If skills contained mutable Skill objects, explain what List.of alone would leave shared.

### 3. Complex: Polymorphic document templates

- [Before](3-example_3/before/before.dart): Copying code switches on every concrete document node type.
- [After](3-example_3/after/after.dart): Each node recursively clones itself through DocumentNode. A registry owns a snapshot and returns new trees without knowing node subclasses.
- **Observe:** Editing the nested body of the first document leaves the second document and registry template unchanged.
- **Try:** Add an ImageNode that implements clone and render without editing TemplateRegistry or Section.

## Run

From the repository root:

```sh
dart --enable-asserts bin/1-creational_patterns/2-prototype/1-example_1/before/before.dart
dart --enable-asserts bin/1-creational_patterns/2-prototype/1-example_1/after/after.dart
```

For the next scenarios, replace `1-example_1` with `2-example_2` or `3-example_3`. Assertions document important guarantees; the verification runner enables them automatically.

## Dart perspective and tradeoffs

Dart has no universal deep-clone operation. Decide explicitly which fields can be shared because they are immutable and which mutable fields need copies. These tree examples assume acyclic input.

## Check your understanding

1. Which code decides what concrete objects are created or composed?
2. What does the client know before the refactoring, and what contract does it know after?
3. Trace one call from `main` through the pattern roles.
4. Add a variation and identify the files or classes you had to modify.
5. When would the direct before design be sufficient?
