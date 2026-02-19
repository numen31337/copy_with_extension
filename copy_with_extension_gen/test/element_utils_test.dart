import 'dart:typed_data' as ns;

import 'package:analyzer/dart/element/element.dart' show ClassElement;
import 'package:copy_with_extension_gen/src/element_utils.dart';
import 'package:source_gen_test/source_gen_test.dart'
    show initializeLibraryReaderForDirectory;
import 'package:test/test.dart';

typedef LocalAlias<T> = List<T>;
typedef LocalScalar = int;

class ElementUtilsAliasFixture {
  const ElementUtilsAliasFixture({
    required this.aliasWithArgs,
    required this.aliasWithoutArgs,
    required this.parameterized,
  });

  final LocalAlias<String> aliasWithArgs;
  final LocalScalar aliasWithoutArgs;
  final List<ns.Uint8List> parameterized;
}

void main() {
  group('ElementUtils.typeNameWithPrefix', () {
    late ClassElement fixture;

    setUpAll(() async {
      final reader = await initializeLibraryReaderForDirectory(
        'test',
        'element_utils_test.dart',
      );
      final fixtureType = reader.findType('ElementUtilsAliasFixture');
      expect(fixtureType, isNotNull);
      fixture = fixtureType!;
    });

    test('renders imported aliases with type arguments', () {
      final field = fixture.getField('aliasWithArgs');
      expect(field, isNotNull);

      final result =
          ElementUtils.typeNameWithPrefix(fixture.library, field!.type);
      expect(result, 'LocalAlias<String>');
    });

    test('renders imported aliases without type arguments', () {
      final field = fixture.getField('aliasWithoutArgs');
      expect(field, isNotNull);

      final result =
          ElementUtils.typeNameWithPrefix(fixture.library, field!.type);
      expect(result, 'LocalScalar');
    });

    test('renders nested parameterized types with import prefixes', () {
      final field = fixture.getField('parameterized');
      expect(field, isNotNull);

      final result =
          ElementUtils.typeNameWithPrefix(fixture.library, field!.type);
      expect(result, 'List<ns.Uint8List>');
    });
  });
}
