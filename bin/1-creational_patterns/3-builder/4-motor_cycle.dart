import '1-product.dart';
import '2-builder.dart';

class MotorCycleBuilder extends Builder {
  late Product product;
  late String brandName;

  MotorCycleBuilder(this.brandName) {
    product = Product();
  }

  @override
  void startUpOperations() {
    product.add(string("car model name : $brandName"));
  }

  @override
  void buildBody() {
    product.add(string("body of car was added"));
  }

  @override
  void insertWheels() {
    product.add(string("wheels of car was added"));
  }

  @override
  void addHeadLights() {
    product.add(string("headlights of car was added"));
  }

  @override
  void endOperations() {}

  @override
  Product getVehicle() {
    return product;
  }
}
