// BEFORE: Every screen knows subsystem calls and their required order.
class Projector {
  void turnOn() => print('Projector on');
}

class SoundSystem {
  void setVolume(int value) => print('Volume: $value');
}

class StreamingPlayer {
  void play(String title) => print('Playing $title');
}

void main() {
  Projector().turnOn();
  SoundSystem().setVolume(20);
  StreamingPlayer().play('Dart Patterns');
}
