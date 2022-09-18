import '2-builder.dart';

class Director {
  late Builder builder;

  void construct(Builder builder) {
    this.builder = builder;
    builder.startUpOperations();
    builder.buildBody();
    builder.insertWheels();
    builder.addHeadLights();
    builder.endOperations();
  }
}
