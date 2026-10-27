// AFTER: Remote features and device implementations vary independently.

// 1. IMPLEMENTOR CONTRACT AND CONCRETE IMPLEMENTORS
abstract class Device {
  String powerOn();
  String setVolume(int value);
}

class Tv implements Device {
  @override
  String powerOn() => 'TV on';
  @override
  String setVolume(int value) => 'TV volume: $value';
}

class Radio implements Device {
  @override
  String powerOn() => 'Radio on';
  @override
  String setVolume(int value) => 'Radio volume: $value';
}

// 2. ABSTRACTION: Holds a bridge to a Device.
class Remote {
  final Device device;
  Remote(this.device);
  String turnOn() => device.powerOn();
}

// 3. REFINED ABSTRACTION: Adds features for every device.
class AdvancedRemote extends Remote {
  AdvancedRemote(super.device);
  String mute() => device.setVolume(0);
}

// 4. USAGE
void main() {
  final tv = AdvancedRemote(Tv());
  final radio = AdvancedRemote(Radio());
  assert(tv.mute() == 'TV volume: 0');
  assert(radio.mute() == 'Radio volume: 0');
  print(tv.turnOn());
  print(tv.mute());
  print(radio.mute());
}
