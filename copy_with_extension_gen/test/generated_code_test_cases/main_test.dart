import 'package:copy_with_extension_gen/src/copy_with_generator.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:copy_with_extension_gen/src/settings.dart';
import 'package:source_gen_test/source_gen_test.dart'
    show
        initializeLibraryReaderForDirectory,
        initializeBuildLogTracking,
        testAnnotatedElements;

Future<void> main() async {
  final reader = await initializeLibraryReaderForDirectory(
    'test/generated_code_test_cases',
    'source_gen_entrypoint.dart',
  );
  final readerForCustomSettingsCase = await initializeLibraryReaderForDirectory(
    'test/generated_code_test_cases',
    'custom_settings_test_case.dart',
  );

  initializeBuildLogTracking();

  testAnnotatedElements<CopyWith>(
    reader,
    CopyWithGenerator(const Settings(copyWithNull: false, skipFields: false)),
  );

  testAnnotatedElements<CopyWith>(
    readerForCustomSettingsCase,
    CopyWithGenerator(const Settings(copyWithNull: true, skipFields: true)),
  );
}
