import 'dart:convert';
import 'dart:io';

// Runs every curriculum entry point in a fresh isolate/process.
// Assertions stay enabled even when this runner is launched without them.
const _categories = <String, List<String>>{
  'bin/1-creational_patterns': [
    '1-singleton',
    '2-prototype',
    '3-builder',
    '4-factory_method',
    '5-abstract_factory',
  ],
  'bin/2-structural_patterns': [
    '1-proxy',
    '2-decorator',
    '3-adapter',
    '4-facade',
    '5-flyweight',
    '6-composite',
    '7-bridge',
  ],
};

Future<void> main() async {
  final root = Directory.fromUri(Platform.script.resolve('../'));
  final expected = <String>[];

  for (final category in _categories.entries) {
    for (final pattern in category.value) {
      for (var number = 1; number <= 3; number++) {
        for (final version in ['before', 'after']) {
          expected.add(
            '${category.key}/$pattern/$number-example_$number/'
            '$version/$version.dart',
          );
        }
      }
    }
  }

  final expectedPaths = expected
      .map((path) => File.fromUri(root.uri.resolve(path)).absolute.path)
      .toSet();
  final actualPaths = <String>{};
  for (final category in _categories.keys) {
    final directory = Directory.fromUri(root.uri.resolve('$category/'));
    if (!directory.existsSync()) {
      stderr.writeln('Missing category: $category');
      exitCode = 1;
      return;
    }
    actualPaths.addAll(
      directory
          .listSync(recursive: true, followLinks: false)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .map((file) => file.absolute.path),
    );
  }

  final missing = expectedPaths.difference(actualPaths);
  final unexpected = actualPaths.difference(expectedPaths);
  if (missing.isNotEmpty || unexpected.isNotEmpty) {
    for (final path in missing) {
      stderr.writeln('Missing entry point: $path');
    }
    for (final path in unexpected) {
      stderr.writeln('Unexpected Dart file: $path');
    }
    exitCode = 1;
    return;
  }

  stdout.writeln('Checking 12 patterns, 36 scenarios, 72 programs...');
  var next = 0;
  var failures = 0;

  Future<void> worker() async {
    while (next < expected.length) {
      final path = expected[next++];
      final process = await Process.start(Platform.resolvedExecutable, [
        '--enable-asserts',
        path,
      ], workingDirectory: root.path);
      final output = process.stdout.transform(utf8.decoder).join();
      final errors = process.stderr.transform(utf8.decoder).join();
      var timedOut = false;
      final code = await process.exitCode.timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          timedOut = true;
          process.kill();
          return -1;
        },
      );
      final captured = await output;
      final capturedErrors = await errors;
      if (code != 0) {
        failures++;
        stderr.writeln('FAIL: $path${timedOut ? ' (timed out)' : ''}');
        stderr.write(captured);
        stderr.write(capturedErrors);
      }
    }
  }

  await Future.wait(List.generate(4, (_) => worker()));
  if (failures != 0) {
    stderr.writeln('$failures of ${expected.length} programs failed.');
    exitCode = 1;
    return;
  }
  stdout.writeln(
    'All ${expected.length} programs passed with assertions enabled.',
  );
}
