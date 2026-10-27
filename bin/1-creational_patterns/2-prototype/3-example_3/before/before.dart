// BEFORE: Clients must know every concrete node type to copy a document.

// 1. MODELS
abstract class DocumentNode {}

class Paragraph extends DocumentNode {
  String text;
  Paragraph(this.text);
}

class Section extends DocumentNode {
  final List<DocumentNode> children;
  Section(this.children);
}

// 2. CLIENT-SIDE COPY LOGIC: Every new node type changes this function.
DocumentNode copyNode(DocumentNode node) {
  if (node is Paragraph) return Paragraph(node.text);
  if (node is Section) {
    return Section(node.children.map(copyNode).toList());
  }
  throw UnsupportedError('Unknown node type');
}

// 3. USAGE
void main() {
  final template = Section([
    Paragraph('Introduction'),
    Section([Paragraph('Body')]),
  ]);
  final copy = copyNode(template) as Section;
  (copy.children.first as Paragraph).text = 'Custom introduction';
  print((template.children.first as Paragraph).text);
  print((copy.children.first as Paragraph).text);
}
