// AFTER: A facade exposes one task-oriented entry point.

// 1. SUBSYSTEMS
class Projector {
  void turnOn() => print('Projector on');
}

class SoundSystem {
  void setVolume(int value) => print('Volume: $value');
}

class StreamingPlayer {
  void play(String title) => print('Playing $title');
}

// 2. FACADE
class HomeTheater {
  final Projector projector;
  final SoundSystem sound;
  final StreamingPlayer player;
  HomeTheater(this.projector, this.sound, this.player);

  void watch(String title) {
    projector.turnOn();
    sound.setVolume(20);
    player.play(title);
  }
}

// 3. CLIENT
void main() {
  final theater = HomeTheater(Projector(), SoundSystem(), StreamingPlayer());
  theater.watch('Dart Patterns');
}
