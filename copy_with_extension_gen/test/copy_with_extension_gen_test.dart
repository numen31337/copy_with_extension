import 'dart:async';
import 'package:test/test.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:logging/logging.dart';
import 'package:source_gen/source_gen.dart';
import 'package:copy_with_extension_gen/src/copy_with_generator.dart';
import 'constants.dart';

//Run the tests with `pub run test` as we don't use the flutter dependencies here

void main() {
  group('generator', () {
    test('produces correct output for correct input', () async {
      final result = await _generate(correctInput);
      expect(result, correctResult);
    });
  });
}

Builder get _builder => PartBuilder([CopyWithGenerator()], '.g.dart');

Future<String> _generate(String source) async {
  final srcs = <String, String>{
    'copy_with_extension|lib/copy_with_extension.dart': annotationsBase,
    '$pkgName|lib/test_case_class.dart': source,
  };

  String? error;
  void captureError(LogRecord logRecord) {
    error = logRecord.error.toString();
  }

  final writer = InMemoryAssetWriter();
  await testBuilder(
    _builder,
    srcs,
    rootPackage: pkgName,
    writer: writer,
    onLog: captureError,
  );

  if (error != null) {
    // ignore: avoid_print
    print('Error: $error');
  }

  return String.fromCharCodes(
    writer.assets[AssetId(pkgName, 'lib/test_case_class.g.dart')] ?? [],
  );
}
