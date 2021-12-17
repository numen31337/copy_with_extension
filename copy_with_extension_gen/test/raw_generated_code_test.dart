import 'package:copy_with_extension_gen/src/copy_with_generator.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:source_gen_test/source_gen_test.dart';

Future<void> main() async {
  final reader = await initializeLibraryReaderForDirectory(
    'test/raw_generated_code_test_cases',
    'source_gen_tests.dart',
  );

  initializeBuildLogTracking();

  testAnnotatedElements<CopyWith>(reader, CopyWithGenerator());
}
