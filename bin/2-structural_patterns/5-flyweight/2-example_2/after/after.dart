// AFTER: A value key identifies the complete shared style.

// 1. FLYWEIGHT
class TextStyle {
  final String font;
  final int size;
  final bool bold;
  TextStyle(this.font, this.size, this.bold);
}

// 2. FACTORY: Font alone would be an incorrect cache key.
class TextStyleFactory {
  final Map<(String, int, bool), TextStyle> _styles = {};

  TextStyle get(String font, int size, {bool bold = false}) {
    return _styles.putIfAbsent((
      font,
      size,
      bold,
    ), () => TextStyle(font, size, bold));
  }

  int get count => _styles.length;
}

// 3. CONTEXT
class Glyph {
  final String character;
  final int column;
  final TextStyle style;
  Glyph(this.character, this.column, this.style);
}

// 4. USAGE
void main() {
  final styles = TextStyleFactory();
  final glyphs = [
    Glyph('D', 0, styles.get('Mono', 14)),
    Glyph('a', 1, styles.get('Mono', 14)),
    Glyph('r', 2, styles.get('Mono', 14)),
    Glyph('t', 3, styles.get('Mono', 14, bold: true)),
  ];
  assert(identical(glyphs[0].style, glyphs[1].style));
  assert(!identical(glyphs[0].style, glyphs[3].style));
  print('Glyphs: ${glyphs.length}; allocated styles: ${styles.count}');
}
