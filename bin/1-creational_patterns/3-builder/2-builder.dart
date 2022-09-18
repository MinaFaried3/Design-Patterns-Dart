import '1-product.dart';

abstract class Builder {
  void startUpOperations();

  void buildBody();

  void insertWheels();

  void addHeadLights();

  void endOperations();

  Product getVehicle();
}
