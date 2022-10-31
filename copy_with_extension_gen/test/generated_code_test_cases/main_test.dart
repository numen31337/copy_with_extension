import 'package:copy_with_extension_gen/builder.dart';
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

  initializeBuildLogTracking();

  settings = const Settings(copyWithNull: false, skipFields: false);

  testAnnotatedElements<CopyWith>(reader, CopyWithGenerator());
}
