class Singleton {
  //parent-child relation ship
  static Singleton? singleton;
  int counter = 0;

  static Singleton getInstance() {
    singleton ??= Singleton();
    return singleton!;
  }

  void addOne() {
    counter++;
  }
}
