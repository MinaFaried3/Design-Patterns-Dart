// AFTER: Polymorphic cloning copies a nested tree through one contract.

// 1. PROTOTYPE CONTRACT
abstract class DocumentNode {
  DocumentNode clone();
  String render();
}

// 2. CONCRETE PROTOTYPES
class Paragraph implements DocumentNode {
  String text;
  Paragraph(this.text);

  @override
  Paragraph clone() => Paragraph(text);

  @override
  String render() => text;
}

class Section implements DocumentNode {
  final List<DocumentNode> children;
  Section(this.children);

  @override
  Section clone() => Section(children.map((node) => node.clone()).toList());

  @override
  String render() => children.map((node) => node.render()).join(' | ');
}

// 3. REGISTRY: Stores configured prototypes and returns independent copies.
class TemplateRegistry {
  final Map<String, DocumentNode> _templates = {};

  void register(String name, DocumentNode template) {
    _templates[name] = template.clone(); // Registry owns its snapshot.
  }

  DocumentNode create(String name) {
    final template = _templates[name];
    if (template == null) throw ArgumentError('Unknown template: $name');
    return template.clone();
  }
}

// 4. USAGE
void main() {
  final registry = TemplateRegistry();
  registry.register('report', Section([
    Paragraph('Introduction'),
    Section([Paragraph('Body')]),
  ]));

  final first = registry.create('report') as Section;
  final second = registry.create('report') as Section;
  final nested = first.children[1] as Section;
  (nested.children.first as Paragraph).text = 'Custom body';

  assert(second.render() == 'Introduction | Body');
  assert(registry.create('report').render() == 'Introduction | Body');
  print('First: ${first.render()}');
  print('Second: ${second.render()}');
}
