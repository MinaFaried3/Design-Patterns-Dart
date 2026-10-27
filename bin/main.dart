class A {
  final int d;

  const A(this.d);
}

class B {
  A get a => const A(55);
}

void printA() {
  final b = B();
  final a1 = b.a;
  final a2 = b.a;
  print(a1.hashCode);
  print(a2.hashCode);
  print(identical(a1, a2));
}

void main() {
  final b = B();
  final a1 = b.a;
  final a2 = b.a;
  print(a1.hashCode);
  print(a2.hashCode);
  print(identical(a1, a2));
  printA();
}
