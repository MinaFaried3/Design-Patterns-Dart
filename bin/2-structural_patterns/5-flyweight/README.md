# Flyweight

Reduce duplication by sharing immutable intrinsic state while keeping per-occurrence extrinsic state outside it.

## Roles to find in the code

Flyweight: shared intrinsic metadata. Context: position or other per-object state. Factory/pool: reuses flyweights by a complete value key. Client: combines a context with its shared data.

## Three examples

Study the scenarios in order. In each scenario, run **before**, identify the design pressure, then read and run **after**. The before version is intentionally limited in design; it is still a runnable program.

### 1. Simple: Forest tree types

- [Before](1-example_1/before/before.dart): Each tree repeats species and color metadata.
- [After](1-example_1/after/after.dart): TreeTypeFactory shares TreeType by species and color; Tree keeps its own coordinates.
- **Observe:** Three tree contexts use two metadata groups; the two oak types are identical references.
- **Try:** Add another oak at a new position and verify the type count stays two.

### 2. Intermediate: Document text styles

- [Before](2-example_2/before/before.dart): Each glyph allocates identical font, size, and weight metadata.
- [After](2-example_2/after/after.dart): TextStyleFactory uses all three intrinsic fields as its key, while glyph characters and columns stay outside.
- **Observe:** Four glyphs use two styles; regular and bold styles are distinct.
- **Try:** Show the incorrect result produced by a cache key that omits bold.

### 3. Complex: Tile map texture pool

- [Before](3-example_3/before/before.dart): One hundred tiles allocate one hundred equal-size texture payloads.
- [After](3-example_3/after/after.dart): Tiles share terrain-and-season textures while keeping position and mutable durability separate. Rendering receives the extrinsic state as arguments.
- **Observe:** 100 tiles share 2 textures: 2048 logical payload bytes instead of 102400. Damaging one tile leaves another unchanged.
- **Try:** Request a winter grass texture and predict the pool count. Explain why durability must not move into TerrainTexture.

## Run

From the repository root:

```sh
dart --enable-asserts bin/2-structural_patterns/5-flyweight/1-example_1/before/before.dart
dart --enable-asserts bin/2-structural_patterns/5-flyweight/1-example_1/after/after.dart
```

For the next scenarios, replace `1-example_1` with `2-example_2` or `3-example_3`. Assertions document important guarantees; the verification runner enables them automatically.

## Dart perspective and tradeoffs

Flyweight is more specific than caching an arbitrary service. Identify intrinsic versus extrinsic state explicitly. Record keys provide value equality in Dart. Pool lifetime matters; the pool here is scoped to a session. Payload counts illustrate duplication, not actual Dart heap measurements.

## Check your understanding

1. Which code decides what concrete objects are created or composed?
2. What does the client know before the refactoring, and what contract does it know after?
3. Trace one call from `main` through the pattern roles.
4. Add a variation and identify the files or classes you had to modify.
5. When would the direct before design be sufficient?
