import '1-product.dart';
import '2-builder.dart';
import '3-car.dart';
import '4-motor_cycle.dart';
import '5-director.dart';

void main() {
  Director director = Director();
  Builder carBuilder = CarBuilder("Jeep");
  Builder motorCycleBuilder = MotorCycleBuilder("Honda");

  /// making car
  director.construct(carBuilder);
  Product car = carBuilder.getVehicle();
  print("Car ${car.show()}");
  print(
      "=====================================================================");

  /// making car
  director.construct(motorCycleBuilder);
  Product motorCycle = motorCycleBuilder.getVehicle();
  print("MotorCycle ${motorCycle.show()}");
}
