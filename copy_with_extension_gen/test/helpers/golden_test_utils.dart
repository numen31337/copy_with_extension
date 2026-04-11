import 'dart:io';

import 'package:copy_with_extension_gen/src/copy_with_generator.dart';
import 'package:copy_with_extension_gen/src/settings.dart';
import 'package:source_gen_test/source_gen_test.dart' show generateForElement;
import 'package:test/test.dart';

import 'source_gen_test_utils.dart';

/// Generates output for [elementName] and verifies it against [goldenFilePath].
Future<void> expectGeneratedCodeMatchesGolden({
  required String sourceDirectory,
  required String sourceFile,
  required String elementName,
  required String goldenFilePath,
  Settings? settings,
}) async {
  final reader = await initializePackageLibraryReaderForDirectory(
    sourceDirectory,
    sourceFile,
  );
  final output = await generateForElement(
    CopyWithGenerator(settings ?? _defaultSettings()),
    reader,
    elementName,
  );
  await expectMatchesGolden(actual: output, goldenFilePath: goldenFilePath);
}

/// Compares [actual] with file content from [goldenFilePath].
///
/// Set `UPDATE_GOLDENS=true` (or `1`) to rewrite golden files.
Future<void> expectMatchesGolden({
  required String actual,
  required String goldenFilePath,
}) async {
  final resolvedGoldenFilePath = resolvePackagePath(goldenFilePath);
  final goldenFile = File(resolvedGoldenFilePath);
  final normalizedActual = _normalize(actual);

  if (_shouldUpdateGoldens) {
    await goldenFile.create(recursive: true);
    await goldenFile.writeAsString('$normalizedActual\n');
  }

  if (!await goldenFile.exists()) {
    fail(
      'Golden file not found: "$resolvedGoldenFilePath". '
      'Run with UPDATE_GOLDENS=true to create it.',
    );
  }

  final expected = _normalize(await goldenFile.readAsString());
  expect(
    normalizedActual,
    expected,
    reason:
        'Golden mismatch at "$resolvedGoldenFilePath". '
        'Run with UPDATE_GOLDENS=true to refresh expected output.',
  );
}

Settings _defaultSettings() {
  return Settings(
    copyWithNull: false,
    skipFields: false,
    immutableFields: false,
  );
}

bool get _shouldUpdateGoldens {
  final value = Platform.environment['UPDATE_GOLDENS'];
  if (value == null) return false;
  final normalized = value.toLowerCase();
  return normalized == '1' || normalized == 'true';
}

String _normalize(String value) => value.replaceAll('\r\n', '\n').trim();
