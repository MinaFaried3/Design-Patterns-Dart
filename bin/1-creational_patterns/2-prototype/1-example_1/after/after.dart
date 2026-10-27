// AFTER: New objects copy an existing configured prototype.

// 1. PROTOTYPE
class Label {
  String text;
  String color;
  int fontSize;
  Label(this.text, this.color, this.fontSize);

  Label clone() => Label(text, color, fontSize);
}

// 2. USAGE
void main() {
  final template = Label('Draft', 'blue', 14);
  final invoice = template.clone()..text = 'Invoice';
  final receipt = template.clone()..text = 'Receipt';

  assert(!identical(template, invoice));
  assert(template.text == 'Draft');
  assert(invoice.color == template.color);
  for (final label in [template, invoice, receipt]) {
    print('${label.text}: ${label.color}, ${label.fontSize}');
  }
}
