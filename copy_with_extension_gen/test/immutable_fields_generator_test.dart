import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:copy_with_extension_gen/src/copy_with_generator.dart';
import 'package:copy_with_extension_gen/src/settings.dart';
import 'package:source_gen_test/source_gen_test.dart'
    show generateForElement, initializeLibraryReaderForDirectory;
import 'package:test/test.dart';

@CopyWith()
class ImmutableFixture {
  const ImmutableFixture({this.a, this.b});

  final String? a;

  @CopyWithField(immutable: false)
  final String? b;
}

void main() {
  test('immutableFields setting marks fields immutable by default', () async {
    final reader = await initializeLibraryReaderForDirectory(
      'test',
      'immutable_fields_generator_test.dart',
    );

    final output = await generateForElement(
      CopyWithGenerator(
        Settings(
          copyWithNull: false,
          skipFields: false,
          immutableFields: true,
        ),
      ),
      reader,
      'ImmutableFixture',
    );

    expect(output, contains('b('));
    expect(output, isNot(contains('a(')));
  });
}
