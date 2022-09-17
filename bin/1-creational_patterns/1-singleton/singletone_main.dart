import 'singletone.dart';

main() {
  ///hasCode is same location in memory
  Singleton singleton = Singleton.getInstance();
  print(singleton.hashCode);
  Singleton singleton1 = Singleton.getInstance();
  print(singleton1.hashCode);
  Singleton singleton2 = Singleton.getInstance();
  print(singleton2.hashCode);

  singleton.addOne();
  singleton1.addOne();
  singleton2.addOne();
  print(
      "object counter is ${singleton.counter} ${singleton1.counter} ${singleton2.counter}");
}
