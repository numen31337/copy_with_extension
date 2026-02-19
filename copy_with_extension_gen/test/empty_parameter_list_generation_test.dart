import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:copy_with_extension_gen/src/copy_with_generator.dart';
import 'package:copy_with_extension_gen/src/settings.dart';
import 'package:source_gen_test/source_gen_test.dart'
    show generateForElement, initializeLibraryReaderForDirectory;
import 'package:test/test.dart';

@CopyWith(immutableFields: true, copyWithNull: true)
class Issue125Fixture {
  const Issue125Fixture({required this.name, this.age});

  @CopyWithField(immutable: false)
  final String name;

  final int? age;
}

@CopyWith(immutableFields: true)
class AllImmutableFixture {
  const AllImmutableFixture({required this.id});

  final int id;
}

void main() {
  Future<String> generateOutput(String target) async {
    final reader = await initializeLibraryReaderForDirectory(
      'test',
      'empty_parameter_list_generation_test.dart',
    );

    return generateForElement(
      CopyWithGenerator(
        Settings(
          copyWithNull: false,
          skipFields: false,
          immutableFields: false,
        ),
      ),
      reader,
      target,
    );
  }

  test(
    'does not emit copyWithNull when no mutable nullable fields are available',
    () async {
      final output = await generateOutput('Issue125Fixture');
      expect(output, isNot(contains('copyWithNull(')));
    },
  );

  test(
    'uses call() instead of call({}) when all fields are immutable',
    () async {
      final output = await generateOutput('AllImmutableFixture');
      expect(output, contains('call()'));
      expect(output, isNot(contains('call({})')));
    },
  );
}
