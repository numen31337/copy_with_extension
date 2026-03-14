import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:copy_with_extension_gen/src/copy_with_field_annotation.dart';
import 'package:copy_with_extension_gen/src/copy_with_generator.dart';
import 'package:copy_with_extension_gen/src/settings.dart';
import 'package:source_gen_test/source_gen_test.dart'
    show generateForElement, initializeLibraryReaderForDirectory;
import 'package:test/test.dart';

class Obsolete {
  const Obsolete(this.message);
  final String message;
}

class DoNotUse {
  const DoNotUse();
}

@CopyWith()
class AnnotationFixture {
  const AnnotationFixture({this.name, this.legacy, this.custom});

  @Deprecated('deprecated field')
  final String? name;

  @Obsolete('obsolete field')
  final String? legacy;

  @DoNotUse()
  final String? custom;
}

@CopyWith()
class FieldInitializerFixture {
  FieldInitializerFixture({required int b}) : a = b;
  final int a;
}

@CopyWith()
class ChainRoot {
  const ChainRoot({required this.a});
  final int a;
}

@CopyWith()
class ChainMiddle extends ChainRoot {
  ChainMiddle({required int b}) : super(a: b);
}

@CopyWith()
class ChainLeaf extends ChainMiddle {
  ChainLeaf({required int c}) : super(b: c);
}

void main() {
  group('Settings', () {
    test('Default values', () {
      final randomGlobalSettings = Settings.fromConfig(<String, dynamic>{
        'test1': 'test1',
        'test2': 123,
        'copyWithNull': 123,
        'skipFields': null,
      });
      final emptyGlobalSettings = Settings.fromConfig(<String, dynamic>{});
      const defaultFieldAnnotation = CopyWithFieldAnnotation.defaults();

      expect(randomGlobalSettings.copyWithNull, false);
      expect(randomGlobalSettings.skipFields, false);
      expect(randomGlobalSettings.immutableFields, false);
      expect(randomGlobalSettings.annotations, {'deprecated'});
      expect(emptyGlobalSettings.copyWithNull, false);
      expect(emptyGlobalSettings.skipFields, false);
      expect(emptyGlobalSettings.immutableFields, false);
      expect(emptyGlobalSettings.annotations, {'deprecated'});
      expect(defaultFieldAnnotation.immutable, false);
    });

    test('Custom values', () {
      final customSettings = Settings.fromConfig(<String, dynamic>{
        'copy_with_null': true,
        'skip_fields': true,
        'immutable_fields': true,
        'annotations': ['Foo'],
      });

      expect(customSettings.copyWithNull, true);
      expect(customSettings.skipFields, true);
      expect(customSettings.immutableFields, true);
      expect(customSettings.annotations, {'foo'});
    });

    test('Empty annotations override defaults', () {
      final settings = Settings.fromConfig(<String, dynamic>{
        'annotations': <String>[],
      });
      expect(settings.annotations, <String>{});
    });

    test('Null annotations fallback to defaults', () {
      final settings = Settings.fromConfig(<String, dynamic>{
        'annotations': null,
      });
      expect(settings.annotations, {'deprecated'});
    });
  });

  group('Annotation forwarding', () {
    test('forwards default annotations', () async {
      final reader = await initializeLibraryReaderForDirectory(
        'test',
        'settings_test.dart',
      );

      final output = await generateForElement(
        CopyWithGenerator(Settings(
          copyWithNull: false,
          skipFields: false,
          immutableFields: false,
        )),
        reader,
        'AnnotationFixture',
      );

      expect(output, contains("@Deprecated('deprecated field')"));
      expect(output, isNot(contains('@Obsolete')));
      expect(output, isNot(contains('@DoNotUse')));
    });

    test('custom annotations override defaults', () async {
      final reader = await initializeLibraryReaderForDirectory(
        'test',
        'settings_test.dart',
      );

      final output = await generateForElement(
        CopyWithGenerator(
          Settings(
            copyWithNull: false,
            skipFields: false,
            immutableFields: false,
            annotations: {'donotuse'},
          ),
        ),
        reader,
        'AnnotationFixture',
      );

      expect(output, contains('@DoNotUse'));
      expect(output, isNot(contains('@Deprecated')));
      expect(output, isNot(contains('@Obsolete')));
    });

    test('empty annotations disable propagation', () async {
      final reader = await initializeLibraryReaderForDirectory(
        'test',
        'settings_test.dart',
      );

      final output = await generateForElement(
        CopyWithGenerator(
          Settings(
            copyWithNull: false,
            skipFields: false,
            immutableFields: false,
            annotations: {},
          ),
        ),
        reader,
        'AnnotationFixture',
      );

      expect(output, isNot(contains('@Deprecated')));
      expect(output, isNot(contains('@Obsolete')));
      expect(output, isNot(contains('@DoNotUse')));
    });
  });

  group('Constructor field resolver', () {
    test('maps field initializers with renamed parameters', () async {
      final reader = await initializeLibraryReaderForDirectory(
        'test',
        'settings_test.dart',
      );

      final output = await generateForElement(
        CopyWithGenerator(
          Settings(
            copyWithNull: false,
            skipFields: false,
            immutableFields: false,
          ),
        ),
        reader,
        'FieldInitializerFixture',
      );

      expect(output, contains('a('));
      expect(output, isNot(contains('b(')));
    });

    test('follows parameter forwarding through super constructors', () async {
      final reader = await initializeLibraryReaderForDirectory(
        'test',
        'settings_test.dart',
      );

      final output = await generateForElement(
        CopyWithGenerator(
          Settings(
            copyWithNull: false,
            skipFields: false,
            immutableFields: false,
          ),
        ),
        reader,
        'ChainLeaf',
      );

      expect(output, contains('a('));
      expect(output, isNot(contains('b(')));
      expect(output, isNot(contains('c(')));
    });
  });

  group('Global skipFields', () {
    test('does not delegate inherited proxy methods to a skipped superclass',
        () async {
      final reader = await initializeLibraryReaderForDirectory(
        'test',
        'settings_test.dart',
      );
      final settings = Settings(
        copyWithNull: false,
        skipFields: true,
        immutableFields: false,
      );

      final rootOutput = await generateForElement(
        CopyWithGenerator(settings),
        reader,
        'ChainRoot',
      );
      final middleOutput = await generateForElement(
        CopyWithGenerator(settings),
        reader,
        'ChainMiddle',
      );

      expect(rootOutput, isNot(contains('ChainRoot a(')));
      expect(middleOutput, isNot(contains('ChainMiddle a(')));
      expect(middleOutput, isNot(contains('super.a(a) as ChainMiddle')));
    });
  });
}
