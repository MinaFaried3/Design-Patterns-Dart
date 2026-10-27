// BEFORE: Concurrent callers independently initialize the same resource.

// 1. SIMULATED RESOURCE: No network or file access.
class Settings {
  static int loads = 0;
  final Map<String, String> values;
  Settings(this.values);

  static Future<Settings> load() async {
    loads++;
    await Future<void>.value();
    return Settings({'theme': 'dark'});
  }
}

// 2. USAGE
Future<void> main() async {
  final settings = await Future.wait([Settings.load(), Settings.load()]);
  print('Loads: ${Settings.loads}');
  print('Same settings: ${identical(settings[0], settings[1])}');
}
