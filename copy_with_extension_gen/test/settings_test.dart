import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:copy_with_extension_gen/src/copy_with_field_annotation.dart';
import 'package:copy_with_extension_gen/src/copy_with_generator.dart';
import 'package:copy_with_extension_gen/src/settings.dart';
import 'package:source_gen/source_gen.dart' show InvalidGenerationSourceError;
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

@CopyWith()
class ShadowedClosureLeaf extends ChainRoot {
  ShadowedClosureLeaf({required int c}) : super(a: ((int c) => c + 1)(0));
}

@CopyWith()
class NameCollisionBase {
  const NameCollisionBase({required this.a, required this.b});

  final int a;
  final int b;
}

@CopyWith()
class NameCollisionLeaf extends NameCollisionBase {
  NameCollisionLeaf({required int b}) : super(a: b, b: 0);
}

@CopyWith()
class DerivedAliasBase {
  const DerivedAliasBase({required this.a});

  final String a;
}

@CopyWith()
class DerivedAliasLeaf extends DerivedAliasBase {
  DerivedAliasLeaf({required int b}) : super(a: b.toString());
}

@CopyWith()
class MixedBindingBase {
  const MixedBindingBase({required this.a});

  final int a;
}

@CopyWith()
class MixedBindingLeaf extends MixedBindingBase {
  MixedBindingLeaf({required int x}) : y = x, super(a: x);

  final int y;
}

@CopyWith()
class InitializingFormalMixedBinding extends MixedBindingBase {
  InitializingFormalMixedBinding({required this.x}) : super(a: x);

  final int x;
}

@CopyWith()
class SameNameDerivedLocal {
  SameNameDerivedLocal({required int x}) : x = x + 1;

  final int x;
}

@CopyWith()
class SameNameUnusedLocal {
  SameNameUnusedLocal({int? value}) : value = 0;

  final int value;
}

@CopyWith()
class OptionalSameNameDerivedLocal {
  OptionalSameNameDerivedLocal({int? x}) : x = x ?? 0;

  final int x;
}

@CopyWith()
class RenamedDefaultedLocal {
  RenamedDefaultedLocal({int? input}) : value = input ?? 0;

  final int value;
}

@CopyWith()
class MultipleDefaultedLocal {
  MultipleDefaultedLocal({int? input})
    : first = input ?? 0,
      second = input ?? 0;

  final int first;
  final int second;
}

@CopyWith()
class DefaultedSuperBase {
  const DefaultedSuperBase({required this.value});

  final int value;
}

@CopyWith()
class RenamedDefaultedSuper extends DefaultedSuperBase {
  RenamedDefaultedSuper({int? input}) : super(value: input ?? 0);
}

@CopyWith()
class DefaultedChainRoot {
  const DefaultedChainRoot({required this.value});

  final int value;
}

@CopyWith()
class DefaultedChainMiddle extends DefaultedChainRoot {
  DefaultedChainMiddle({int? middle}) : super(value: middle ?? 0);
}

@CopyWith()
class DefaultedChainLeaf extends DefaultedChainMiddle {
  DefaultedChainLeaf({int? leaf}) : super(middle: leaf ?? 0);
}

@CopyWith()
class PositionalDerivedSuperBase {
  const PositionalDerivedSuperBase(this.value);

  final int value;
}

@CopyWith()
class PositionalDerivedSuper extends PositionalDerivedSuperBase {
  PositionalDerivedSuper({required int input}) : super(input + 1);
}

@CopyWith()
abstract mixin class FactoryFallbackMixin {
  factory FactoryFallbackMixin({required int id}) = _FactoryFallbackMixinImpl;

  int get id;
}

class _FactoryFallbackMixinImpl with FactoryFallbackMixin {
  _FactoryFallbackMixinImpl({required this.id});

  @override
  final int id;
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
        CopyWithGenerator(
          Settings(
            copyWithNull: false,
            skipFields: false,
            immutableFields: false,
          ),
        ),
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

    test('does not treat shadowed closure identifiers as bindings', () async {
      final reader = await initializeLibraryReaderForDirectory(
        'test',
        'settings_test.dart',
      );

      await expectLater(
        generateForElement(
          CopyWithGenerator(
            Settings(
              copyWithNull: false,
              skipFields: false,
              immutableFields: false,
            ),
          ),
          reader,
          'ShadowedClosureLeaf',
        ),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (error) => error.message,
            'message',
            contains('Constructor parameter "c" in class ShadowedClosureLeaf'),
          ),
        ),
      );
    });

    test('does not bind by inherited field name alone', () async {
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
        'NameCollisionLeaf',
      );

      expect(output, contains('a('));
      expect(output, isNot(contains(' b(')));
    });

    test('rejects derived super-constructor aliases', () async {
      final reader = await initializeLibraryReaderForDirectory(
        'test',
        'settings_test.dart',
      );

      await expectLater(
        generateForElement(
          CopyWithGenerator(
            Settings(
              copyWithNull: false,
              skipFields: false,
              immutableFields: false,
            ),
          ),
          reader,
          'DerivedAliasLeaf',
        ),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (error) => error.message,
            'message',
            contains('Constructor parameter "b" in class DerivedAliasLeaf'),
          ),
        ),
      );
    });

    test('rejects parameters bound to local and super fields', () async {
      final reader = await initializeLibraryReaderForDirectory(
        'test',
        'settings_test.dart',
      );

      await expectLater(
        generateForElement(
          CopyWithGenerator(
            Settings(
              copyWithNull: false,
              skipFields: false,
              immutableFields: false,
            ),
          ),
          reader,
          'MixedBindingLeaf',
        ),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (error) => error.message,
            'message',
            contains('Constructor parameter "x" in class MixedBindingLeaf'),
          ),
        ),
      );
    });

    test('rejects initializing formals also bound to super fields', () async {
      final reader = await initializeLibraryReaderForDirectory(
        'test',
        'settings_test.dart',
      );

      await expectLater(
        generateForElement(
          CopyWithGenerator(
            Settings(
              copyWithNull: false,
              skipFields: false,
              immutableFields: false,
            ),
          ),
          reader,
          'InitializingFormalMixedBinding',
        ),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (error) => error.message,
            'message',
            contains(
              'Constructor parameter "x" in class InitializingFormalMixedBinding',
            ),
          ),
        ),
      );
    });

    test('rejects derived same-name field initializers', () async {
      final reader = await initializeLibraryReaderForDirectory(
        'test',
        'settings_test.dart',
      );

      await expectLater(
        generateForElement(
          CopyWithGenerator(
            Settings(
              copyWithNull: false,
              skipFields: false,
              immutableFields: false,
            ),
          ),
          reader,
          'SameNameDerivedLocal',
        ),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (error) => error.message,
            'message',
            contains('Constructor parameter "x" in class SameNameDerivedLocal'),
          ),
        ),
      );
    });

    test(
      'rejects same-name parameters without field binding evidence',
      () async {
        final reader = await initializeLibraryReaderForDirectory(
          'test',
          'settings_test.dart',
        );

        await expectLater(
          generateForElement(
            CopyWithGenerator(
              Settings(
                copyWithNull: false,
                skipFields: false,
                immutableFields: false,
              ),
            ),
            reader,
            'SameNameUnusedLocal',
          ),
          throwsA(
            isA<InvalidGenerationSourceError>().having(
              (error) => error.message,
              'message',
              contains(
                'Constructor parameter "value" in class SameNameUnusedLocal',
              ),
            ),
          ),
        );
      },
    );

    test('supports defaulted same-name field initializers', () async {
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
        'OptionalSameNameDerivedLocal',
      );

      expect(output, contains('x('));
      expect(output, contains('int? x'));
    });

    test('supports defaulted renamed field initializers', () async {
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
        'RenamedDefaultedLocal',
      );

      expect(output, contains('value('));
      expect(output, isNot(contains('input(')));
      expect(output, contains('input:'));
    });

    test('rejects defaulted parameters that target multiple fields', () async {
      final reader = await initializeLibraryReaderForDirectory(
        'test',
        'settings_test.dart',
      );

      await expectLater(
        generateForElement(
          CopyWithGenerator(
            Settings(
              copyWithNull: false,
              skipFields: false,
              immutableFields: false,
            ),
          ),
          reader,
          'MultipleDefaultedLocal',
        ),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (error) => error.message,
            'message',
            contains(
              'Constructor parameter "input" in class MultipleDefaultedLocal',
            ),
          ),
        ),
      );
    });

    test('supports defaulted renamed super-constructor forwarding', () async {
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
        'RenamedDefaultedSuper',
      );

      expect(output, contains('value('));
      expect(output, isNot(contains('input(')));
      expect(output, contains('input:'));
    });

    test(
      'supports multi-level defaulted super-constructor forwarding',
      () async {
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
          'DefaultedChainLeaf',
        );

        expect(output, contains('value('));
        expect(output, isNot(contains('leaf(')));
        expect(output, isNot(contains('middle(')));
        expect(output, contains('leaf:'));
      },
    );

    test('rejects positional derived super-constructor aliases', () async {
      final reader = await initializeLibraryReaderForDirectory(
        'test',
        'settings_test.dart',
      );

      await expectLater(
        generateForElement(
          CopyWithGenerator(
            Settings(
              copyWithNull: false,
              skipFields: false,
              immutableFields: false,
            ),
          ),
          reader,
          'PositionalDerivedSuper',
        ),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (error) => error.message,
            'message',
            contains(
              'Constructor parameter "input" in class PositionalDerivedSuper',
            ),
          ),
        ),
      );
    });

    test('uses same-name fallback for factory constructors', () async {
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
        'FactoryFallbackMixin',
      );

      expect(output, contains('id('));
      expect(output, contains('id:'));
    });
  });

  group('Global skipFields', () {
    test(
      'does not delegate inherited proxy methods to a skipped superclass',
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
      },
    );
  });
}
