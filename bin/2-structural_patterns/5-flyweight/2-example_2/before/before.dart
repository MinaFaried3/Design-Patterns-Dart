// BEFORE: Every glyph owns a duplicate style object.
class TextStyle {
  final String font;
  final int size;
  final bool bold;
  TextStyle(this.font, this.size, this.bold);
}

class Glyph {
  final String character;
  final int column;
  final TextStyle style;
  Glyph(this.character, this.column, this.style);
}

void main() {
  final glyphs = [
    Glyph('D', 0, TextStyle('Mono', 14, false)),
    Glyph('a', 1, TextStyle('Mono', 14, false)),
    Glyph('r', 2, TextStyle('Mono', 14, false)),
    Glyph('t', 3, TextStyle('Mono', 14, true)),
  ];
  print('Glyphs: ${glyphs.length}; allocated styles: ${glyphs.length}');
}
