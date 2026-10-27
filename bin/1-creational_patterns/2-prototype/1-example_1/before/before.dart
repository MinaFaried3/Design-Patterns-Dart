// BEFORE: Recreating a configured object duplicates every default.

// 1. MODEL
class Label {
  String text;
  String color;
  int fontSize;
  Label(this.text, this.color, this.fontSize);
}

// 2. USAGE
void main() {
  final template = Label('Draft', 'blue', 14);
  final invoice = Label('Invoice', 'blue', 14);
  final receipt = Label('Receipt', 'blue', 14);

  print('${template.text}: ${template.color}, ${template.fontSize}');
  print('${invoice.text}: ${invoice.color}, ${invoice.fontSize}');
  print('${receipt.text}: ${receipt.color}, ${receipt.fontSize}');
  // A new template property requires updating every reconstruction.
}
