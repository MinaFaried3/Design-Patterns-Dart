import 'dart:collection';

class string extends LinkedListEntry<string> {
  final String str;

  string(this.str);

  @override
  String toString() {
    return str;
  }
}

class Product {
  LinkedList<string> parts = LinkedList<string>();

  void add(string part) {
    parts.add(part);
  }

  String show() {
    StringBuffer result = StringBuffer();
    result.write("product components are :");
    for (string part in parts) {
      result.write("\n${part.toString()}");
    }
    return result.toString();
  }
}
