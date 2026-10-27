// AFTER: Translate the vendor's interface into the client's contract.

// 1. TARGET
abstract class TemperatureSensor {
  double readCelsius();
}

// 2. ADAPTEE: Treat this existing API as unmodifiable.
class FahrenheitSensor {
  double readFahrenheit() => 86;
}

// 3. ADAPTER
class FahrenheitSensorAdapter implements TemperatureSensor {
  final FahrenheitSensor sensor;
  FahrenheitSensorAdapter(this.sensor);

  @override
  double readCelsius() => (sensor.readFahrenheit() - 32) * 5 / 9;
}

// 4. CLIENT
double readScreenTemperature(TemperatureSensor sensor) => sensor.readCelsius();

void main() {
  final sensor = FahrenheitSensorAdapter(FahrenheitSensor());
  final value = readScreenTemperature(sensor);
  assert((value - 30).abs() < 0.000001);
  print('Celsius: $value');
}
