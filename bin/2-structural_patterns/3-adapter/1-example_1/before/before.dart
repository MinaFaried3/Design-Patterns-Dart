// BEFORE: The client is coupled to a vendor-specific method and unit.
class FahrenheitSensor {
  double readFahrenheit() => 86;
}

double readScreenTemperature(FahrenheitSensor sensor) {
  return (sensor.readFahrenheit() - 32) * 5 / 9;
}

void main() {
  print('Celsius: ${readScreenTemperature(FahrenheitSensor())}');
}
