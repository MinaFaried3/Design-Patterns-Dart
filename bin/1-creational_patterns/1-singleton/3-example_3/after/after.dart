// AFTER: Cache initialization itself, so concurrent callers share one Future.

// 1. ASYNCHRONOUS SINGLETON
class Settings {
  Settings._(Map<String, String> values) : values = Map.unmodifiable(values);

  final Map<String, String> values;
  static Future<Settings>? _pending;

  // The first caller chooses the loader. Later callers share its result.
  static Future<Settings> load(
    Future<Map<String, String>> Function() loader,
  ) {
    return _pending ??= _initialize(loader);
  }

  static Future<Settings> _initialize(
    Future<Map<String, String>> Function() loader,
  ) async {
    try {
      // The async boundary also handles a loader that throws synchronously.
      final values = await Future<Map<String, String>>.sync(loader);
      return Settings._(values);
    } catch (_) {
      _pending = null; // A failed initialization must allow a later retry.
      rethrow;
    }
  }
}

// 2. SIMULATED SOURCE
class SettingsSource {
  int calls = 0;

  Future<Map<String, String>> read() async {
    calls++;
    if (calls == 1) throw StateError('Temporary initialization failure');
    return {'theme': 'dark'};
  }
}

// 3. USAGE: Failure, retry, and simultaneous callers.
Future<void> main() async {
  final source = SettingsSource();
  try {
    await Settings.load(source.read);
  } on StateError {
    print('First load failed; retry is allowed');
  }

  final first = Settings.load(source.read);
  final second = Settings.load(source.read);
  assert(identical(first, second));

  final settings = await Future.wait([first, second]);
  assert(identical(settings[0], settings[1]));
  assert(source.calls == 2); // One failure + one shared successful retry.
  print('Source calls: ${source.calls}');
  print('Same settings: ${identical(settings[0], settings[1])}');
  print('Theme: ${settings.first.values['theme']}');
}
