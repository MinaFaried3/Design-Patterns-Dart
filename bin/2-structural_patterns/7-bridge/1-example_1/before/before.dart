// BEFORE: Remote features are duplicated for every device family.
class TvRemote {
  String turnOn() => 'TV on';
}

class RadioRemote {
  String turnOn() => 'Radio on';
}

class AdvancedTvRemote extends TvRemote {
  String mute() => 'TV muted';
}

class AdvancedRadioRemote extends RadioRemote {
  String mute() => 'Radio muted';
}

void main() {
  print(AdvancedTvRemote().turnOn());
  print(AdvancedTvRemote().mute());
  print(AdvancedRadioRemote().mute());
}
