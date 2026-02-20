import 'package:copy_with_extension_gen/src/copy_with_generator.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:copy_with_extension_gen/src/settings.dart';
import 'package:source_gen_test/source_gen_test.dart'
    show
        initializeLibraryReaderForDirectory,
        initializeBuildLogTracking,
        testAnnotatedElements;
import 'package:test/test.dart';

import '../helpers/golden_test_utils.dart';

Future<void> main() async {
  final reader = await initializeLibraryReaderForDirectory(
    'test/generated_code_test_cases',
    'source_gen_entrypoint.dart',
  );
  initializeBuildLogTracking();

  testAnnotatedElements<CopyWith>(
    reader,
    CopyWithGenerator(
      Settings(
        copyWithNull: false,
        skipFields: false,
        immutableFields: false,
      ),
    ),
  );

  group('generated code goldens', () {
    test('type aliases are preserved in generated code', () async {
      await expectGeneratedCodeMatchesGolden(
        sourceDirectory: 'test/generated_code_test_cases',
        sourceFile: 'source_gen_entrypoint.dart',
        elementName: 'GoldenAliasNames',
        goldenFilePath:
            'test/goldens/generated_code_test_cases__golden_alias_names.golden',
      );
    });
  });
}
